//
//  NLAdminSuccessViewController.swift
//  Notary
//
//  Created by Admin on 3/19/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class NLAdminSuccessViewController: UIViewController {
    @IBOutlet weak var btnGoHome: UIButton!
    @IBOutlet weak var lblReceiveMsg: UILabel!

    var isAdmin = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.btnGoHome.layer.borderWidth = 1
        self.btnGoHome.layer.borderColor = UIColor.black.cgColor
        self.btnGoHome.clipsToBounds = true
        let str = NSLocalizedString("You will recieve a confirmation on", comment: "") + NLCommon.shared().user!.s_mobile!
        self.lblReceiveMsg.text = str

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.isHidden = true
        
    }
    @IBAction func btnGoHome(_ sender: UIButton) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "NLHomeViewController")
        self.navigationController!.setViewControllers([vc], animated: true)

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
