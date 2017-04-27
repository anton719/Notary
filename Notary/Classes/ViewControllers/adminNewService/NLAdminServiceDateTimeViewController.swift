//
//  NLAdminServiceDateTimeViewController.swift
//  Notary
//
//  Created by Admin on 3/19/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import THCalendarDatePicker
import RestKit
import ActionSheetPicker_3_0

class NLAdminServiceDateTimeViewController: UIViewController {
    
//    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnDate: UIButton!
    @IBOutlet weak var dateType: UISegmentedControl!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnSelectTimes: UIButton!
    @IBOutlet weak var btnCancel: UIButton!

    var selectedDt: NSDate? = nil
    
    var location: CLLocationCoordinate2D? = nil
    var count = ""
    var lat = ""
    var lng = ""
    var service: TServices? = nil
    var dtType: NSNumber = 0
    var selectedStrDate = ""
    var selectedStrTime = ""
    var times = [String]()
    var timesSTR = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.postGetAvailableTime()
        
        self.btnDone.layer.borderWidth = 0.5
        self.btnDone.layer.borderColor = UIColor.black.cgColor
        self.btnDone.clipsToBounds = true
        dtType = 0
        selectedDt = NSDate()
        self.changeBtnTitle(title: NSDate.string(from: selectedDt as Date!, withFormat: "yyyy-MM-dd"), button: self.btnDate)
        self.btnDate.titleEdgeInsets = UIEdgeInsetsMake(0.0, 6.0, 0.0, 6.0)
        self.btnSelectTimes.titleEdgeInsets = UIEdgeInsetsMake(0.0, 6.0, 0.0, 6.0)
        self.dateType.setTitle(NSLocalizedString("Gorgian", comment: ""), forSegmentAt: 0)
        self.dateType.setTitle(NSLocalizedString("Hijri", comment: ""), forSegmentAt: 1)
//        self.changeBtnTitle(title: NSLocalizedString("Back", comment: ""), button: self.btnBack)

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
    func changeBtnTitle(title: String, button: UIButton)  {
        button.setTitle(title, for: .normal)
        button.setTitle(title, for: .highlighted)
        button.setTitle(title, for: .selected)
    }

    @IBAction func btnBack(_ sender: UIButton) {
        let _ = self.navigationController!.popViewController(animated: true)!
    }
    @IBAction func btnDate(_ sender: UIButton) {
        let datePicker = AIDatePickerController.picker(with: nil, type: dtType, useMinMax: true, selectedBlock: { (selectedDate) in
            self.dismiss(animated: true, completion: nil)
            self.selectedStrDate = self.convertDateToString(isHijri: Int(self.dtType), date: selectedDate! )
            self.changeBtnTitle(title: self.selectedStrDate, button: self.btnDate)
            
        }) {
            self.dismiss(animated: true, completion: nil)
        }
        self.present(datePicker as! UIViewController, animated: true, completion: nil)
    }
    @IBAction func dateType(sender: UISegmentedControl) {
        let num = sender.selectedSegmentIndex
//        dtType = (NSNumber(sender.selectedSegmentIndex))
        dtType = NSNumber(integerLiteral: num)
    }
    @IBAction func btnDone(_ sender: UIButton) {
        if selectedStrDate.characters.count > 0 && selectedStrTime.characters.count > 0 {
            self.postCheckElegibility()
            //        [self insertNewRecord];
        }
        else {
            NLCommon.viewToastMsg("البيانات مطلوبة", view: self.view!)
        }

    }
    @IBAction func btnSelectTimes(_ sender: UIButton) {
        ActionSheetStringPicker.show(withTitle: "اختر الوقت", rows: timesSTR, initialSelection: 0, doneBlock: { (picker, selectedIndex, selectedValue) in
            self.selectedStrTime = self.timesSTR[selectedIndex]
            self.changeBtnTitle(title: self.timesSTR[selectedIndex], button: self.btnSelectTimes)
        }, cancel: { (picker) in
            
        }, origin: sender)
        self.view.endEditing(true)
    }
    @IBAction func btnCancel(_ sender: UIButton) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "NLUserAppointmentListViewController")
        self.navigationController!.pushViewController(vc, animated: true)

    }
    
    func convertDateToString(isHijri: Int, date: Date) -> String {
        let df = DateFormatter()
        var cal: NSCalendar?
        if isHijri == 0 {
            cal = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        }
        else {
            cal = NSCalendar(calendarIdentifier: NSCalendar.Identifier.islamicCivil)
        }
        df.calendar = cal as Calendar!
        df.dateFormat = "yyyy-MM-dd"
        let str = df.string(from: date as Date)
        return str
    }
    
    
    func timesSetup() {
        for str in times {
            let dt = NSDate(from: str, withFormat: "yyyyMMddHHmmss")
            let str = dt?.string(withFormat: "yyyy-MM-dd HH:mm:ss")
            timesSTR.append(str!)
        }
    }
    func postGetAvailableTime() {
        var params = [AnyHashable: Any]()
        
        params["serviceID"] = self.service?.pk_i_id
        params["lat"] = NSString(format: "%f", (self.location?.latitude)!)
        params["lng"] = NSString(format: "%f", (self.location?.longitude)!)
        params["sp"] = "F7E009C286C34A6EA300C419D64EBA44"
        SVProgressHUD.show()
        
        RKObjectManager.shared().getObject(nil, path: "RepListAvailableTimes", parameters: params, success: { (operation, mappingResult) in
            SVProgressHUD.dismiss()
            
            let json = try! JSONSerialization.jsonObject(with: (operation?.httpRequestOperation.responseData)!, options: .mutableLeaves) as! NSDictionary
            if json != nil && json.value(forKey: "result") != nil {
                let result = json.value(forKey: "result") as! String
                if result == "2" {
                    self.times = json.value(forKey: "availability") as! [String]
                    self.timesSetup()
                } else {
                    self.timesSetup()
                }
            }
            self.timesSetup()
        }) { (operation, error) in
            SVProgressHUD.dismiss()
            
            self.times.append("20170301113311")
            self.times.append("20170302103311")
            self.times.append("20170303114511")
            self.timesSetup()

        }

    }
    func postCheckElegibility() {
        var params = [AnyHashable: Any]()
        var useHijri: String
        if dtType.isEqual(1) {
            useHijri = "true"
        }
        else {
            useHijri = "false"
        }
        params["serviceID"] = self.service?.pk_i_id
        params["nationalID"] = NLCommon.shared().user!.s_national_id
        params["useHijri"] = useHijri
        params["dateOfBirthH"] = selectedStrDate
        params["mobile"] = NLCommon.shared().user!.s_mobile
        params["NumberOfBeneficiaries"] = self.count.filteredText
        params["sp"] = "F7E009C286C34A6EA300C419D64EBA44"
        SVProgressHUD.show()
        
        RKObjectManager.shared().getObject(nil, path: "CheckElegibility", parameters: params, success: { (operation, mappingResult) in
            SVProgressHUD.dismiss()
            
            let json = try! JSONSerialization.jsonObject(with: (operation?.httpRequestOperation.responseData)!, options: .mutableLeaves) as! NSDictionary
            if json != nil && json.value(forKey: "result") != nil {
                let result = json.value(forKey: "result") as! String
                if result == "2" {
                    self.postConfirmation()
                } else {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "NLAdminFailViewController") as! NLAdminFailViewController
                    vc.isAdmin = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            self.timesSetup()
        }) { (operation, error) in
            SVProgressHUD.dismiss()
            NLCommon.viewToastMsg("فشلت العملية", view: self.view)
            
        }
        

    }
    
    
    func postConfirmation() {
        var params = [AnyHashable: Any]()
        var useHijri: String
        
        if dtType.isEqual(1) {
            useHijri = "true"
        }
        else {
            useHijri = "false"
        }
        params["serviceID"] = self.service?.pk_i_id
        params["nationalID"] = NLCommon.shared().user!.s_national_id
        params["useHijri"] = useHijri
        params["dateOfBirthH"] = selectedStrDate
        params["mobile"] = NLCommon.shared().user!.s_mobile
        params["NumberOfBeneficiaries"] = self.count.filteredText
        params["lat"] = self.lat
        params["lng"] = self.lng
        params["dt"] = selectedStrDate
        params["sp"] = "F7E009C286C34A6EA300C419D64EBA44"
        SVProgressHUD.show()
        
        RKObjectManager.shared().getObject(nil, path: "ConifromAppointment", parameters: params, success: { (operation, mappingResult) in
            SVProgressHUD.dismiss()
            
            let json = try! JSONSerialization.jsonObject(with: (operation?.httpRequestOperation.responseData)!, options: .mutableLeaves) as! NSDictionary
            if json != nil && json.value(forKey: "result") != nil {
                let result = json.value(forKey: "result") as! String
                if result == "1" {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "NLAdminSuccessViewController") as! NLAdminSuccessViewController
                    vc.isAdmin = true
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "NLAdminFailViewController") as! NLAdminFailViewController
                    vc.isAdmin = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            self.timesSetup()
        }) { (operation, error) in
            SVProgressHUD.dismiss()
            NLCommon.viewToastMsg("فشلت العملية", view: self.view)
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "NLAdminFailViewController") as! NLAdminFailViewController
            vc.isAdmin = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    func insertNewRecord() {
        var appointment = TAppointments.mr_createEntity()
        appointment?.pk_i_id = NLCommon.randomString(withLength: 10)
        appointment?.d_lat = self.lat
        appointment?.d_lng = self.lng
        appointment?.fk_i_service_id = self.service?.pk_i_id
        appointment?.s_datetime = selectedStrDate
        appointment?.i_beneficiaries_count = self.count
        appointment?.b_upcoming = true
        appointment?.b_cancelled = false
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NLAdminSuccessViewController") as! NLAdminSuccessViewController
        vc.isAdmin = true
        self.navigationController?.pushViewController(vc, animated: true)
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
