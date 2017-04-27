//
//  NLAdminLoginViewController.swift
//  Notary
//
//  Created by Admin on 3/19/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import RestKit

class NLAdminLoginViewController: UIViewController {

//    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var txtIdNo: UITextField!
    @IBOutlet weak var txtMobile: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.btnLogin.layer.borderWidth = 0.5
        self.btnLogin.layer.borderColor = UIColor.black.cgColor
        self.btnLogin.clipsToBounds = true
        
//        self.changeBtnTitle(title: "Back", button: btnBack)
        
        self.txtMobile.placeholder =  NSLocalizedString("05xxxxxxxx", comment: "")
        self.txtIdNo.placeholder =  NSLocalizedString("ID Number Must be 10 digits", comment: "")
        

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
    @IBAction func btnLogin(_ sender: UIButton) {
        
       
        
        if self.txtMobile.text?.characters.count == 0 ||  self.txtIdNo.text?.characters.count == 0 {
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
//        postLogin()
    }
    func changeBtnTitle(title: String, button: UIButton)  {
        button.setTitle(title, for: .normal)
        button.setTitle(title, for: .highlighted)
        button.setTitle(title, for: .selected)
    }
    
    func postLogin() {
        let params = ["nationalID": self.txtIdNo.text?.filteredText, "mobile": self.txtMobile.text?.filteredText , "sp": "F7E009C286C34A6EA300C419D64EBA44"] as [AnyHashable : Any]
        
        SVProgressHUD.show()
        RKObjectManager.shared().getObject(nil, path: "RepLoginRequest", parameters: params, success: { (operation, mappingResult) in
            
            SVProgressHUD.dismiss()
            
            if NLCommon.webServiceDefaultHandlerFailed(with: operation, mappingResult: mappingResult, error: nil, view: self.view) {
                return
            }
            let user = mappingResult!.firstObject as! TUser
            if user == nil {
                return
            }
            NLCommon.shared().currentUserNationalID = user.s_national_id;
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "NLAdminVerifyLoginViewController") as! NLAdminVerifyLoginViewController
            
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
