//
//  NLAdminNewServiceViewController.swift
//  Notary
//
//  Created by Admin on 3/19/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import THCalendarDatePicker
import RestKit
import ActionSheetPicker_3_0

class NLAdminNewServiceViewController: UIViewController , THDatePickerDelegate{

//    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnDate: UIButton!
    @IBOutlet weak var txtUserCount: UITextField!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var lblServiceTitle: UILabel!
    @IBOutlet weak var btnService: UIButton!
    @IBOutlet weak var btnTime: UIButton!
    @IBOutlet weak var segmentedDateType: UISegmentedControl!
    
    @IBOutlet weak var btnCancel: UIButton!
    
    var selectedService: TServices? = nil
    var selectedDate: NSDate? = nil
    var selectedTime: NSDate? = nil
    
    var requestParams: [AnyHashable: Any]? = nil
    
    var datePicker: THDatePickerViewController? = nil
    
    var availableTimes = [NSDate]()
    var services = [TServices]()
    var datePickerViewController : AIDatePickerController? = nil
    
    
    func setSelectedService(selectedService: TServices) {
        self.selectedService = selectedService
        if selectedService != nil {
            self.btnService.titles = self.selectedService?.s_name
        }
        self.fetchServicesFromInternet()
    }

    
    func setSelectedDate(selectedDate: NSDate) {
        self.selectedDate = selectedDate
        if selectedDate != nil {
            self.btnDate.titles = (self.segmentedDateType.selectedSegmentIndex == 0 ? selectedDate.gregorianDateString : selectedDate.hijriDateString)
        }
        else {
            self.btnDate.titles = ""
        }
    }
    func setSelectedTime(selectedTime: NSDate) {
        self.selectedTime = selectedTime
        if selectedTime != nil {
            self.btnTime.titles = selectedTime.availableTimeString
        }
        else {
            self.btnTime.titles = ""
        }
    }

   
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.btnAdd.layer.borderWidth = 1
        self.btnAdd.layer.borderColor = UIColor.black.cgColor
        self.btnAdd.clipsToBounds = true
        
        self.btnService.titleEdgeInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        
        self.segmentedDateType.setTitle(NSLocalizedString("Gorgian", comment: ""), forSegmentAt: 0)
        self.segmentedDateType.setTitle(NSLocalizedString("Hijri", comment: ""), forSegmentAt: 1)
        
//        self.btnBack.titles = NSLocalizedString("Back", comment: "")
        self.btnCancel.titles = NSLocalizedString("Cancel", comment: "")
        self.lblServiceTitle.text = NSLocalizedString("Service", comment: "")
        
        self.fetchServicesFromInternet()

        
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
        let _ = self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnDate(_ sender: UIButton) {
        clickedBtnDate()
    }
    func clickedBtnDate() {
        if self.availableTimes.count == 0 {
            NLCommon.viewToastMsg(NSLocalizedString("No Available Dates", comment: ""), view: self.view)
            return
        }
        
        self.view.endEditing(true)
        self.presentSemiView(self.datePicker?.view, withOptions: [KNSemiModalOptionKeys.pushParentBack as! AnyHashable: false,
                                                                  KNSemiModalOptionKeys.animationDuration as! AnyHashable: 0.3,
                                                                  KNSemiModalOptionKeys.shadowOpacity as! AnyHashable: 0.3])
        
    }

    @IBAction func btnAdd(_ sender: UIButton) {
        if self.selectedService == nil {
            NLCommon.viewToastMsg(NSLocalizedString("All Field Required", comment: ""), view: self.view)
            return
        }
        if (self.btnDate.titleLabel?.text?.characters.count)! == 0 {
            NLCommon.viewToastMsg(NSLocalizedString("All Field Required", comment: ""), view: self.view)
            return
        }
        if (self.btnTime.titleLabel?.text?.characters.count)! == 0 {
            NLCommon.viewToastMsg(NSLocalizedString("All Field Required", comment: ""), view: self.view)
            return
        }
        submitAppointment()
    }
    
    @IBAction func btnService(_ sender: UIButton) {
        var servicesSTR = [String]()
        self.btnDate.setTitle("", for: .normal)
        for serv in self.services {
            servicesSTR.append(serv.s_name)
        }
        
        ActionSheetStringPicker.show(withTitle: NSLocalizedString("Select Services", comment: ""), rows: servicesSTR, initialSelection: 0, doneBlock: { (picker, selectedIndex, selectedValue) in
            self.selectedService = self.services[selectedIndex]
        }, cancel: { (picker) in
            
        }, origin: sender)
        self.view.endEditing(true)

    }
    @IBAction func btnTime(_ sender: UIButton) {
        if self.availableTimes.count == 0 {
            
            return
        }
        var strings = [String]()
        for date in self.availableTimes {
            strings.append(date.availableTimeString)
        }
        
        ActionSheetStringPicker.show(withTitle: NSLocalizedString("Select Time", comment: ""), rows: strings, initialSelection: 0, doneBlock: { (picker, selectedIndex, selectedValue) in
            self.selectedTime = self.availableTimes[selectedIndex]
        }, cancel: { (picker) in
            
        }, origin: sender)
        self.view.endEditing(true)

    }
    @IBAction func segmentedDateType(_ sender: UISegmentedControl) {
        self.btnDate.titles = ""
    }
    @IBAction func btnCancel(_ sender: UIButton) {
        let alertController = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("Do you want to cancel this operation ?", comment: ""), preferredStyle: (.alert))
        let noAction = UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: nil)
        alertController.addAction(noAction)
        let yesAction = UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default) { (action) in
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(yesAction)
        
        
        self.present(alertController, animated: true, completion: nil)

    }
    func fetchServicesFromInternet() {
       
        SVProgressHUD.show()
        
        RKObjectManager.shared().getObject(nil, path: "ListServices", parameters: nil, success: { (operation, mappingResult) in
            SVProgressHUD.dismiss()
           
        }) { (operation, error) in
            SVProgressHUD.dismiss()
        }
        
    }
    func fetchListAvailableTimesFromInternet() {
        if self.selectedService == nil {
            return
        }
        var params = [AnyHashable: Any]()
        if (NLCommon.shared().user.pk_i_id?.characters.count)! > 0 {
            params["repID"] = NLCommon.shared().user.pk_i_id;
        }
        if (NLCommon.shared().user.s_national_id?.characters.count)! > 0 {
            params["nationalID"] = NLCommon.shared().user.s_national_id;
        }
        if (NLCommon.shared().user.s_mobile?.characters.count)! > 0 {
            params["mobile"] = NLCommon.shared().user.s_mobile;
        }
        if (NLCommon.shared().user.s_access_token?.characters.count)! > 0 {
            params["refGuid"] = NLCommon.shared().user.s_access_token;
        }
        params["serviceID"] = self.selectedService?.pk_i_id
        params["sp"] = "F7E009C286C34A6EA300C419D64EBA44"
        SVProgressHUD.show()
        
        RKObjectManager.shared().getObject(nil, path: "RepListAvailableTimes", parameters: params, success: { (operation, mappingResult) in
            SVProgressHUD.dismiss()
            
            let json = try! JSONSerialization.jsonObject(with: (operation?.httpRequestOperation.responseData)!, options: .mutableLeaves) as! NSDictionary
            self.availableTimes.removeAll()
            
            let arr = json["availability"] as! [String]
            
            
            if arr.count > 0 {
                for str: String in arr {
                    self.availableTimes.append(NSDate(fromAvailableTime: str))
                }
            }
            self.datePickerSetup()
        }) { (operation, error) in
            SVProgressHUD.dismiss()
        }

    }
    
    func datePickerSetup() {
        if !(self.datePicker != nil) {
            self.datePicker = THDatePickerViewController.datePicker()
        }
        
        self.datePicker?.delegate = self
        self.datePicker?.setAllowClearDate(false)
        self.datePicker?.setClearAsToday(true)
        self.datePicker?.setAutoCloseOnSelectDate(false)
        self.datePicker?.setAllowSelectionOfSelectedDate(true)
        self.datePicker?.setDisableYearSwitch(true)
        self.datePicker?.setDisableFutureSelection(false)
        self.datePicker?.setDaysInHistorySelection(12)
        self.datePicker?.setDaysInFutureSelection(0)
        self.datePicker?.setDateTimeZoneWithName("UTC")
        self.datePicker?.setAllowMultiDaySelection(false)
        self.datePicker?.autoCloseCancelDelay = 0.3
        self.datePicker?.selectedBackgroundColor = UIColor(red: 125 / 255.0, green: 208 / 255.0, blue: 0 / 255.0, alpha: 1.0)
        self.datePicker?.currentDateColor = UIColor(red: 242 / 255.0, green: 121 / 255.0, blue: 53 / 255.0, alpha: 1.0)
        self.datePicker?.currentDateColorSelected = UIColor.yellow
        var availableDates = [NSDate]()
        for dt in self.availableTimes {
            availableDates.append(NLCommon.returnFormatedDt(dt as Date!, dtFormat: "yyyy-MM-dd") as NSDate)
        }
        //        self.datePicker?.availableDates = availableDates
    }
    
    
    func submitAppointment() {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US") as Locale!
        dateFormatter.calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian) as Calendar!
        dateFormatter.timeZone = NSTimeZone(name: "Asia/Riyadh") as TimeZone!
        dateFormatter.dateFormat = "yyMMdd"
        let timeFormatter = DateFormatter()
        timeFormatter.locale = NSLocale(localeIdentifier: "en_US") as Locale!
        timeFormatter.calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian) as Calendar!
        timeFormatter.timeZone = NSTimeZone(name: "Asia/Riyadh") as TimeZone!
        timeFormatter.dateFormat = "HHss"
        let dt = "\(dateFormatter.string(from: self.selectedDate as! Date))\(timeFormatter.string(from: self.selectedTime as! Date))"
        
        
        var params = [AnyHashable: Any]()
        if (NLCommon.shared().user.pk_i_id?.characters.count)! > 0 {
            params["repID"] = NLCommon.shared().user.pk_i_id;
        }
        if (NLCommon.shared().user.s_national_id?.characters.count)! > 0 {
            params["nationalID"] = NLCommon.shared().user.s_national_id;
        }
        if (NLCommon.shared().user.s_mobile?.characters.count)! > 0 {
            params["mobile"] = NLCommon.shared().user.s_mobile;
        }
        if (NLCommon.shared().user.s_access_token?.characters.count)! > 0 {
            params["refGuid"] = NLCommon.shared().user.s_access_token;
        }
        params["serviceID"] = self.selectedService?.pk_i_id
        params["dt"] = dt
        params["count"] = Int(self.txtUserCount.text!)
        params["sp"] = "F7E009C286C34A6EA300C419D64EBA44"
        SVProgressHUD.show()
        
        RKObjectManager.shared().getObject(nil, path: "RepConfirmAppointment", parameters: params, success: { (operation, mappingResult) in
            SVProgressHUD.dismiss()
            
            if NLCommon.webServiceDefaultHandlerFailed(with: operation, mappingResult: mappingResult, error: nil, view: self.view) {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "NLAdminFailViewController") as! NLAdminFailViewController
                self.navigationController?.pushViewController(vc, animated: true)
                return
            }
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "NLAdminSuccessViewController") as! NLAdminSuccessViewController
            self.navigationController?.pushViewController(vc, animated: true)
            
            
        }) { (operation, error) in
            SVProgressHUD.dismiss()
            
            NLCommon.webServiceDefaultHandlerFailed(with: operation, mappingResult: nil, error: error, view: self.view)
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "NLAdminFailViewController") as! NLAdminFailViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    //MARK: THDatePickerDelegate
    func datePicker(_ datePicker: THDatePickerViewController!, selectedDate: Date!) {
        self.selectedDate = selectedDate as NSDate?
        self.datePicker?.dismissSemiModalView()
        
    }
    func datePickerDonePressed(_ datePicker: THDatePickerViewController!) {
        self.datePicker?.dismissSemiModalView()
    }
    func datePickerCancelPressed(_ datePicker: THDatePickerViewController!) {
        self.datePicker?.dismissSemiModalView()
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
