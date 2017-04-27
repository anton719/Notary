//
//  NLHome2ViewController.swift
//  Notary
//
//  Created by Admin on 3/19/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class NLHome2ViewController: UIViewController {

    @IBOutlet var btnView: [UIView]!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnLoginUser: UIButton!
    
    @IBOutlet weak var btnLoginAdmin: UIButton!
    @IBOutlet weak var btnLanguage: UIButton!
    
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for view in self.btnView {
            self.setViewBorder(view: view)
        }
        
        self.btnLoginAdmin.titleLabel?.adjustsFontSizeToFitWidth = true
        self.btnLoginAdmin.titleLabel?.minimumScaleFactor = 0.5
        self.btnLoginAdmin.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.btnLoginAdmin.titleLabel?.numberOfLines = 2
        self.btnLoginAdmin.titleLabel?.textAlignment = NSTextAlignment.center
        
        self.btnLoginUser.titleLabel?.adjustsFontSizeToFitWidth = true
        self.btnLoginUser.titleLabel?.minimumScaleFactor = 0.5
        self.btnLoginUser.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.btnLoginUser.titleLabel?.numberOfLines = 2
        self.btnLoginUser.titleLabel?.textAlignment = NSTextAlignment.center
        
        self.btnLanguage.titles = NLCommon.shared().isAR ? "English" : "العربية"
        self.btnLanguage.layer.zPosition = 1
        
        self.btnBack.titles = NSLocalizedString("Back", comment: "")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        //make transparent navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
    }
    func setViewBorder(view: UIView)  {
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 1
        view.clipsToBounds = true
    }
    @IBAction func btnBack(_ sender: UIButton) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    @IBAction func viewLoginAdmin(_ sender: UITapGestureRecognizer) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NLAdminLoginViewController") as! NLAdminLoginViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func viewLoginUser(_ sender: UITapGestureRecognizer) {
        var identifier = ""
        switch NLCommon.shared().userMainOperationEnum {
        case UserMainOperationEnum_Booking:
            identifier = "NLUserInfoViewController"
            break
        case UserMainOperationEnum_List:
            identifier = "NLUserLoginViewController"
            break
        default:
            break
        }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: identifier)
        self.navigationController?.pushViewController(vc!, animated: true)
        
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
