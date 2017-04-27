//
//  NLHomeViewController.swift
//  Notary
//
//  Created by Admin on 3/19/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import RestKit

class NLHomeViewController: UIViewController {

    @IBOutlet var btnView: [UIView]!
    
    @IBOutlet weak var btnAbout: UIButton!
    @IBOutlet weak var btnAdminLogin: UIButton!
    @IBOutlet weak var btnMyAppointment: UIButton!
    @IBOutlet weak var btnBookingAppointment: UIButton!
    @IBOutlet weak var btnLanguage: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        RKObjectManager.shared().getObject(nil, path: "", parameters: nil, success: nil, failure: nil)
        
        for view in self.btnView {
            self.setViewBorder(view: view)
        }
        
        self.btnBookingAppointment.titleLabel?.adjustsFontSizeToFitWidth = true
        self.btnBookingAppointment.titleLabel?.minimumScaleFactor = 0.5
        self.btnBookingAppointment.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.btnBookingAppointment.titleLabel?.numberOfLines = 2
        self.btnBookingAppointment.titleLabel?.textAlignment = NSTextAlignment.center
        
        self.btnMyAppointment.titleLabel?.adjustsFontSizeToFitWidth = true
        self.btnMyAppointment.titleLabel?.minimumScaleFactor = 0.5
        self.btnMyAppointment.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.btnMyAppointment.titleLabel?.numberOfLines = 2
        self.btnMyAppointment.titleLabel?.textAlignment = NSTextAlignment.center
        
        self.btnAbout.titleLabel?.adjustsFontSizeToFitWidth = true
        self.btnAbout.titleLabel?.minimumScaleFactor = 0.5
        self.btnAbout.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.btnAbout.titleLabel?.numberOfLines = 2
        self.btnAbout.titleLabel?.textAlignment = NSTextAlignment.center
        
        self.btnLanguage.titles = NLCommon.shared().isAR ? "English" : "العربية"
        self.btnLanguage.layer.zPosition = 1
        
        if TUser.mr_countOfEntities() > 0 {
            TUser.mr_truncateAll()
        }
        if TAppointments.mr_countOfEntities() > 0 {
            TAppointments.mr_truncateAll()
        }
        if TServices.mr_countOfEntities() > 0 {
            TServices.mr_truncateAll()
        }
        NLCommon.shared().currentUserNationalID = nil
        self.changeBtnTitle(title: "Representative Sign-in", button: btnAdminLogin)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Back", comment: ""), style: .done, target: nil, action: nil)
    }
    func changeBtnTitle(title: String, button: UIButton)  {
        button.setTitle(title, for: .normal)
        button.setTitle(title, for: .highlighted)
        button.setTitle(title, for: .selected)
    }
    func setViewBorder(view: UIView)  {
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 1
        view.clipsToBounds = true
    }
    @IBAction func viewBookingAppointment_TouchUpInside(_ sender: UITapGestureRecognizer) {
        NLCommon.shared().userMainOperationEnum = UserMainOperationEnum_Booking
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NLUserInfoViewController") as! NLUserInfoViewController
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    @IBAction func viewMyAppointment_TouchUpInside(_ sender: UITapGestureRecognizer) {
        NLCommon.shared().userMainOperationEnum = UserMainOperationEnum_List
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NLUserLoginViewController") as! NLUserLoginViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func viewAboutApp_TouchUpInside(_ sender: UITapGestureRecognizer) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NLAboutAppViewController") as! NLAboutAppViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func viewRepresentativeVC_TouchUpInside(_ sender: UITapGestureRecognizer) {
        NLCommon.shared().userMainOperationEnum = UserMainOperationEnum_List
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NLAdminLoginViewController") as! NLAdminLoginViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func btnLanguage(_ sender: UIButton) {
        let alertController = UIAlertController(title: NSLocalizedString("Confirmation", comment: ""), message: NSLocalizedString("Application will terminate and change its language", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel, handler: nil)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default) { (action) in
            NLCommon.shared().appLanguage = NLCommon.shared().isAR ? ["en"] : ["ar"]
            UIApplication.shared.perform(#selector(URLSessionTask.suspend))
            Thread.sleep(forTimeInterval: 1)
            exit(0)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
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
