//
//  NLAdminFailViewController.swift
//  Notary
//
//  Created by Admin on 3/19/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class NLAdminFailViewController: UIViewController {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnGoHome: UIButton!
    
    var isAdmin = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.btnGoHome.layer.borderWidth = 1
        self.btnGoHome.layer.borderColor = UIColor.black.cgColor
        self.btnGoHome.clipsToBounds = true
        self.btnBack.layer.borderWidth = 1
        self.btnBack.layer.borderColor = UIColor.black.cgColor
        self.btnBack.clipsToBounds = true

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.isHidden = true

    }

    @IBAction func btnBack(_ sender: UIButton) {
        let _ = self.navigationController!.popViewController(animated: true)!

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
