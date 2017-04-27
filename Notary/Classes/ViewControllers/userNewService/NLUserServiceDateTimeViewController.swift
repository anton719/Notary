//
//  NLUserServiceDateTimeViewController.swift
//  Notary
//
//  Created by Admin on 3/19/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import THCalendarDatePicker
import RestKit
import ActionSheetPicker_3_0

class NLUserServiceDateTimeViewController: UIViewController , THDatePickerDelegate{
//    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblSelectDate: UILabel!
    @IBOutlet weak var btnDate: UIButton!
    @IBOutlet weak var segmentedDateType: UISegmentedControl!

    @IBOutlet weak var btnTime: UIButton!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    var selectedDate: NSDate? = nil
    var selectedTime: NSDate? = nil
    
    var requestParams: [AnyHashable: Any]? = nil
    
    var datePicker: THDatePickerViewController? = nil
    
    var availableTimes = [NSDate]()
    
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
        self.btnDone.layer.borderWidth = 0.5
        self.btnDone.layer.borderColor = UIColor.black.cgColor
        self.btnDone.clipsToBounds = true
        self.btnDate.titleEdgeInsets = UIEdgeInsetsMake(0.0, 6.0, 0.0, 6.0)
        self.btnTime.titleEdgeInsets = UIEdgeInsetsMake(0.0, 6.0, 0.0, 6.0)
        self.segmentedDateType.setTitle(NSLocalizedString("Gorgian", comment: ""), forSegmentAt: 0)
        self.segmentedDateType.setTitle(NSLocalizedString("Hijri", comment: ""), forSegmentAt: 1)
//        self.btnBack.titles = NSLocalizedString("Back", comment: "")
        self.lblSelectDate.text = NSLocalizedString("Select Date", comment: "")
        self.fetchListAvailableTimesFromInternet()

    }
    
    func fetchListAvailableTimesFromInternet() {
        var params = self.requestParams
        params?["sp"] = "F7E009C286C34A6EA300C419D64EBA44"
        SVProgressHUD.show()
       
        RKObjectManager.shared().getObject(nil, path: "ClientListAvailableTimes", parameters: params, success: { (operation, mappingResult) in
            SVProgressHUD.dismiss()
            
            let json = try! JSONSerialization.jsonObject(with: (operation?.httpRequestOperation.responseData)!, options: .mutableLeaves) as! NSDictionary
            self.availableTimes.removeAll()
            
            let arr = json["availability"] as! [String]
            
            
            if arr.count > 0 {
                for str: String in arr {
                    self.availableTimes.append(NSDate(fromAvailableTime: str))
                }
            }
        }) { (operation, error) in
            SVProgressHUD.dismiss()
        }

    }
    @IBAction func btnBack(_ sender: UIButton) {
        let _ = self.navigationController?.popViewController(animated: true)
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

    @IBAction func btnDate(_ sender: UIButton) {
        self.clickedBtnDate()
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
    @IBAction func segmentedDateType(_ sender: UISegmentedControl) {
        self.lblSelectDate = nil
        self.clickedBtnDate()
    }
    @IBAction func btnTime(_ sender: UIButton) {
        if self.availableTimes.count == 0 {
            NLCommon.viewToastMsg(NSLocalizedString("No Available Dates", comment: ""), view: self.view)
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
    @IBAction func btnDone(_ sender: UIButton) {
        if self.selectedDate != nil || self.selectedTime != nil {
            NLCommon.viewToastMsg(NSLocalizedString("All Field Required", comment: ""), view: self.view)
            return
        }
        self.submitAppoitmentConfirmation()
    }
    @IBAction func btnCancel(_ sender: UIButton) {
        let alertController = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("Do you want to cancel this operation ?", comment: ""), preferredStyle: (.alert))
        let noAction = UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: nil)
        alertController.addAction(noAction)
        let yesAction = UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default) { (action) in
            self.navigationController?.setViewControllers([(self.storyboard?.instantiateViewController(withIdentifier: "NLHomeViewController"))!], animated: true)
        }
        alertController.addAction(yesAction)
        
        
        self.present(alertController, animated: true, completion: nil)

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
    
    func submitAppoitmentConfirmation() {
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
        var params = self.requestParams
        params?["dt"] = dt
        params?["sp"] = "F7E009C286C34A6EA300C419D64EBA44"
        SVProgressHUD.show()
        RKObjectManager.shared().getObject(nil, path: "ConifromAppointment", parameters: params, success: { (operation, mappingResult) in
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
