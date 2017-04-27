//
//  NLUserLoginViewController.swift
//  Notary
//
//  Created by Admin on 3/19/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import RestKit

class NLUserLoginViewController: UIViewController {

//    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnDate: UIButton!
    @IBOutlet weak var txtIdNo: UITextField!
    
    @IBOutlet weak var txtMobile: UITextField!
    
    @IBOutlet weak var btnViewSchedule: UIButton!
    @IBOutlet weak var segmentedDateType: UISegmentedControl!
    
    var selectedDate: NSDate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.btnViewSchedule.layer.borderWidth = 0.5
        self.btnViewSchedule.layer.borderColor = UIColor.black.cgColor
        self.btnViewSchedule.clipsToBounds = true
        
        self.btnDate.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 6.0, bottom: 0.0, right: 6.0)
        self.txtIdNo.editingRect(forBounds: self.txtIdNo.bounds)
        self.txtMobile.editingRect(forBounds: self.txtMobile.bounds)
        
        self.segmentedDateType.setTitle(NSLocalizedString("Gorgian", comment: ""), forSegmentAt: 0)
        self.segmentedDateType.setTitle(NSLocalizedString("Hijri", comment: ""), forSegmentAt: 1)
        
//        self.btnBack.titles = NSLocalizedString("Back", comment: "")
        self.txtMobile.placeholder =  NSLocalizedString("05xxxxxxxx", comment: "")
        self.txtIdNo.placeholder =  NSLocalizedString("ID Number Must be 10 digits", comment: "")
        
        self.selectedDate = NSDate()
        self.segmentedDateType.selectedSegmentIndex = 1
    }
    func setSelecetedDate(selectedDate: NSDate)  {
        self.selectedDate = selectedDate
        if (selectedDate != nil) {
            
            self.btnDate.titles = self.segmentedDateType.selectedSegmentIndex == 0 ? selectedDate.gregorianDateString : selectedDate.hijriDateString
            
        } else {
            self.btnDate.titles = ""
        }
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

    @IBAction func btnBack(_ sender: UIButton) {
        let _  = self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnDate(_ sender: UIButton) {
        clickedDate()
    }
    func clickedDate()  {
        let datePickerViewController = AIDatePickerController.picker(with: nil, type: self.segmentedDateType.selectedSegmentIndex as NSNumber!, useMinMax: true, selectedBlock: { (selectedDate) in
            self.dismiss(animated: true, completion: nil)
            self.selectedDate = selectedDate as NSDate?
        }) {
            self.dismiss(animated: true, completion: nil)
        }
        self.present(datePickerViewController as! UIViewController, animated: true, completion: nil)
    }
    @IBAction func btnViewSchedule(_ sender: UIButton) {
        
        
        if self.txtMobile.text?.characters.count == 0 || !(self.selectedDate != nil) || self.txtIdNo.text?.characters.count == 0 {
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
        self.fetchAppointmentList()
    }
    @IBAction func segmentedDateType(_ sender: UISegmentedControl) {
        self.selectedDate = nil
        self.clickedDate()
    }

    func fetchAppointmentList() {
        var params = ["nationalID": self.txtIdNo.text, "mobile": self.txtMobile.text , "sp": "F7E009C286C34A6EA300C419D64EBA44"] as [AnyHashable : Any]
        
        params["useHijri"] = self.segmentedDateType.selectedSegmentIndex == 0 ? "false" : "true"
        if self.segmentedDateType.selectedSegmentIndex == 0 {
            params["dateOfBirthG"] = self.selectedDate?.gregorianDateString(withFormat: "yyyyMMdd")
        }
        if self.segmentedDateType.selectedSegmentIndex == 1 {
            params["dateOfBirthH"] = self.selectedDate?.hijriDateString(withFormat: "yyyyMMdd")
        }
        SVProgressHUD.show()
        RKObjectManager.shared().getObject(nil, path: "ClientListMyAppointments", parameters: params, success: { (operation, mappingResult) in
            SVProgressHUD.dismiss()
            if NLCommon.webServiceDefaultHandlerFailed(with: operation, mappingResult: mappingResult, error: nil, view: self.view) {
                return
            }
            let user = mappingResult!.firstObject as! TUser
            if user == nil {
                return
            }
            NLCommon.shared().currentUserNationalID = user.s_national_id;
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "NLUserAppointmentListViewController") as! NLUserAppointmentListViewController
            vc.requestParams = params
            self.navigationController?.pushViewController(vc, animated: true)
        
            
            
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
