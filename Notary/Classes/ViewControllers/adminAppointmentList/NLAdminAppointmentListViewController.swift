//
//  NLAdminAppointmentListViewController.swift
//  Notary
//
//  Created by Admin on 3/19/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import RestKit
import UITableView_Placeholder

class NLAdminAppointmentListViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnAddAppointment: UIButton!
    @IBOutlet weak var lblPreviousSelected: UILabel!
    @IBOutlet weak var lblNextSelected: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleView: UIView!

    
    var objects: [TAppointments] = []
    var isUpcoming: NSNumber?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.objects = [Any]() as! [TAppointments]
        self.tableView.delegate = self
        self.tableView.dataSource = self
        isUpcoming = 1
        self.lblNextSelected.isHidden = false
        self.titleView?.layer.cornerRadius = 10
        self.btnBack.titles = NSLocalizedString("Back", comment: "")
        self.btnBack.titles = NSLocalizedString("Booking Appointment", comment: "")
        
        self.fetchRecordsFromInternet()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        //add right bar button refresh item
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: "clickedRefresh")
        navigationItem.rightBarButtonItem = refresh

        //make transparent navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
    }
    
    func fetchRecordsFromInternet() {
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
        
        params["sp"] = "F7E009C286C34A6EA300C419D64EBA44";

        SVProgressHUD.show()
        RKObjectManager.shared().getObject(nil, path: "RepListMyAppointments", parameters: params , success: { (operation, mappingResult) in
            SVProgressHUD.dismiss()
            if NLCommon.webServiceDefaultHandlerFailed(with: operation, mappingResult: mappingResult, error: nil, view: self.view) {
                return
            }
            
            self.objects.removeAll()
            
            if (mappingResult?.dictionary().keys.contains("appointments"))! && ((mappingResult?.value(forKey: "appointments")) is [AnyObject]) {
                self.objects.append(mappingResult?.value(forKey: "appointments") as! TAppointments)
                (self.objects as NSArray).filtered(using: NSPredicate(format: "b_upcoming = %@", self.isUpcoming!))
            }
            self.tableView.reloadData()
            
            
        }) { (operation, error) in
            SVProgressHUD.dismiss()
            NLCommon.webServiceDefaultHandlerFailed(with: operation, mappingResult: nil, error: error, view: self.view)
        }
    }
    func fetchRecordsFromDatabase()  {
        self.objects.removeAll()
        let pred = NSPredicate(format: "b_upcoming = %@", self.isUpcoming!)
        self.objects = TAppointments.mr_findAllSorted(by: "pk_i_id", ascending: false, with: pred) as! [TAppointments]
        self.tableView.reloadData()
    }
    @IBAction func btnBack(_ sender: UIButton) {
        let _  = self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnRefresh(_ sender: UIBarButtonItem) {
        fetchRecordsFromInternet()
    }
    func clickedRefresh()  {
        fetchRecordsFromInternet()
    }
    func backViewController() -> UIViewController {
        let myIndex = self.navigationController!.viewControllers.index(of: self)
        if myIndex != 0 && myIndex != NSNotFound {
            return self.navigationController!.viewControllers[myIndex! - 1]
        }
        else {
            return UIViewController()
        }
    }
    @IBAction func btnAddAppointment(_ sender: UIButton) {
       NLCommon.shared().userMainOperationEnum = UserMainOperationEnum_Booking
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NLAdminNewServiceViewController") as! NLAdminNewServiceViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func btnPrevious(_ sender: UIButton) {
        isUpcoming = 0
        self.lblNextSelected.isHidden = true
        self.lblPreviousSelected.isHidden = false
        self.fetchRecordsFromInternet()
    }
    @IBAction func btnNext(_ sender: UIButton) {
        isUpcoming = 1
        self.lblNextSelected.isHidden = false
        self.lblPreviousSelected.isHidden = true
        self.fetchRecordsFromInternet()
    }

    //MARK: TableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.placeholderBase(onNumber: self.objects.count, with: FETablePlaceholderConf.default())
        
        return self.objects.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! NLAdminAppointmentListTableViewCell
        cell.object = self.objects[indexPath.row]
        cell.configureCell()
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NLAdminAppointmentDetailViewController") as! NLAdminAppointmentDetailViewController
        vc.object = self.objects[indexPath.row]
        vc.isUpcoming = self.isUpcoming
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
