//
//  NLAdminVerifyLoginViewController.swift
//  Notary
//
//  Created by Admin on 3/19/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import RestKit

class NLAdminVerifyLoginViewController: UIViewController {
//    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.btnLogin.layer.borderWidth = 0.5
        self.btnLogin.layer.borderColor = UIColor.black.cgColor
        self.btnLogin.clipsToBounds = true
        
//        self.btnBack.titles = NSLocalizedString("Back", comment: "")
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
        
        if self.txtPassword.text?.characters.count == 0  {
            NLCommon.viewToastMsg(NSLocalizedString("All Field Required", comment: ""), view: self.view)
            return
        }

        postVerify()
    }
    func postVerify() {
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

        params["pin"] = self.txtPassword.text?.filteredText
        params["sp"] = "F7E009C286C34A6EA300C419D64EBA44"
        
        SVProgressHUD.show()
        RKObjectManager.shared().getObject(nil, path: "RepLoginComplete", parameters: params , success: { (operation, mappingResult) in
            
            SVProgressHUD.dismiss()
            
            if NLCommon.webServiceDefaultHandlerFailed(with: operation, mappingResult: mappingResult, error: nil, view: self.view) {
                return
            }
            
            if NLCommon.shared().user.pk_i_id == nil {
                return
            }
            
            var identifier = ""
            switch NLCommon.shared().userMainOperationEnum {
            case UserMainOperationEnum_Booking :
                identifier = "NLAdminNewServiceViewController"
                break
            case UserMainOperationEnum_List :
                identifier = "NLAdminAppointmentListViewController"
                break
            default:
                break
            }
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: identifier)
            
            self.navigationController?.pushViewController(vc!, animated: true)
            
            
            
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
