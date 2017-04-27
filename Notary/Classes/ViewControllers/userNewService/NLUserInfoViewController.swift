//
//  NLUserInfoViewController.swift
//  Notary
//
//  Created by Admin on 3/19/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import RestKit

class NLUserInfoViewController: UIViewController {

//    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var txtIdNo: UITextField!
    @IBOutlet weak var btnDate: UIButton!
    @IBOutlet weak var segmentedDateType: UISegmentedControl!
    
    @IBOutlet weak var txtMobile: UITextField!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var lblServiceTitle: UILabel!
    @IBOutlet weak var btnSelectService: UIButton!
    
    var selectedDate: NSDate? = nil
    var selectedService: TServices? = nil
    var services = [TServices]()
    
    func setSelectedService(selectedService: TServices) {
        self.selectedService = selectedService
        if  selectedService != nil {
            self.btnSelectService.titles = self.selectedService?.s_name
        }
    }
    
    func setSelectedDate(selectedDate: NSDate) {
        self.selectedDate = selectedDate
        if selectedDate != nil  {
            self.btnDate.titles = (self.segmentedDateType.selectedSegmentIndex == 0 ? selectedDate.gregorianDateString : selectedDate.hijriDateString)
        }
        else {
            self.btnDate.titles = ""
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //  The converted code is limited by 2 KB.
        //  Upgrade your plan to remove this limitation.
        
        services = TServices.mr_findAll() as! [TServices]
        self.btnNext.layer.borderWidth = 1.0
        self.btnNext.layer.borderColor = UIColor.black.cgColor
        self.btnNext.clipsToBounds = true
        self.btnDate.titleEdgeInsets = UIEdgeInsetsMake(0.0, 6.0, 0.0, 6.0)
        self.btnSelectService.titleEdgeInsets = UIEdgeInsetsMake(0.0, 30.0, 0.0, 30.0)
        self.txtIdNo.editingRect(forBounds: self.txtIdNo.bounds)
        self.txtMobile.editingRect(forBounds: self.txtMobile.bounds)
        self.segmentedDateType.setTitle(NSLocalizedString("Gorgian", comment: ""), forSegmentAt: 0)
        self.segmentedDateType.setTitle(NSLocalizedString("Hijri", comment: ""), forSegmentAt: 1)
//        self.btnBack.titles = NSLocalizedString("Back", comment: "")
        self.lblServiceTitle.text = NSLocalizedString("Service", comment: "")
        self.txtMobile.placeholder = NSLocalizedString("05xxxxxxxx", comment: "")
        self.txtIdNo.placeholder = NSLocalizedString("ID Number Must be 10 digits", comment: "")
    }
    
    @IBAction func btnBack(_ sender: Any) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnDate(_ sender: UIButton) {
        clickedBtnDate()
    }
    func clickedBtnDate() {
        let datePickerViewController = AIDatePickerController.picker(with: nil, type: self.segmentedDateType.selectedSegmentIndex as NSNumber!, useMinMax: true, selectedBlock: { (selectedDate) in
            self.dismiss(animated: true, completion: nil)
            self.selectedDate = selectedDate as NSDate?
        }) { 
            self.dismiss(animated: true, completion: nil)
        }
        self.present(datePickerViewController as! UIViewController, animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Back", comment: ""), style: .done, target: nil, action: nil)
        //make transparent navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
    }

    @IBAction func segmentedDateType(_ sender: UISegmentedControl) {
        self.selectedDate = nil
        clickedBtnDate()
    }
    @IBAction func btnNext(_ sender: UIButton) {
        if self.txtMobile.text?.characters.count == 0 || self.selectedDate == nil || self.txtIdNo.text?.characters.count == 0 {
            NLCommon.viewToastMsg(NSLocalizedString("All Field Required", comment: ""), view: self.view)
            return
        }
        if !NLCommon.isIDNumberValid(self.txtIdNo.text?.filteredText) {
            NLCommon.viewToastMsg(NSLocalizedString("ID Number Invalid", comment: ""), view: self.view)
            return
        }
        if !NLCommon.isMobileNumberValid(self.txtMobile.text?.filteredText) {
            NLCommon.viewToastMsg(NSLocalizedString("Mobile Number Invalid", comment: ""), view: self.view)
            return
        }

        postCheckElegibility()
    }
    @IBAction func btnSelectService(_ sender: UIButton) {
        var servicesSTR = [String]()
        for serv in self.services {
            servicesSTR.append(serv.s_name)
        }
        
        ActionSheetStringPicker.show(withTitle: NSLocalizedString("Select Services", comment: ""), rows: servicesSTR, initialSelection: 0, doneBlock: { (picker, selectedIndex, selectedValue) in
            if self.services.count > 0 {
                self.selectedService = self.services[selectedIndex]    
            }
            
        }, cancel: { (picker) in
            
        }, origin: sender)
        self.view.endEditing(true)
    }

    func postCheckElegibility()  {
        var params = [AnyHashable: Any]()
        params["serviceID"] = self.selectedService?.pk_i_id
        params["nationalID"] = self.txtIdNo.text
        params["mobile"] = self.txtMobile.text
        params["sp"] = "F7E009C286C34A6EA300C419D64EBA44"
        params["useHijri"] = self.segmentedDateType.selectedSegmentIndex == 0 ? "false" : "true"
            
        SVProgressHUD.show()
        
        RKObjectManager.shared().getObject(nil, path: "ClientCheckEligibility", parameters: params, success: { (operation, mappingResult) in
            SVProgressHUD.dismiss()
            if NLCommon.webServiceDefaultHandlerFailed(with: operation, mappingResult: mappingResult, error: nil, view: self.view) {
                return
            }
            let detailPostViewController = self.storyboard?.instantiateViewController(withIdentifier: "NLUserLocationViewController") as! NLUserLocationViewController
            detailPostViewController.requestParams = params
            self.navigationController?.pushViewController(detailPostViewController, animated: true)
            
        }) { (operation, error) in
            SVProgressHUD.dismiss()
            NLCommon.webServiceDefaultHandlerFailed(with: operation, mappingResult: nil, error: error, view: self.view)
        }

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
