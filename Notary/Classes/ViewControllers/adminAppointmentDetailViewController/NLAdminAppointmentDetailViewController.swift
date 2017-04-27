//
//  NLAdminAppointmentDetailViewController.swift
//  Notary
//
//  Created by Admin on 3/19/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import GoogleMaps
import MapKit
import RestKit

class NLAdminAppointmentDetailViewController: UIViewController , GMSMapViewDelegate, MKMapViewDelegate{

//    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var googleMapView: UIView!
    @IBOutlet weak var operationView: UIView!
    @IBOutlet weak var lblCount: UILabel!
    @IBOutlet weak var cancelView: UIView!
    @IBOutlet weak var lblCancel: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    @IBOutlet weak var cancelViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var operationViewWidthConstraint: NSLayoutConstraint!
    
    
    var object: TAppointments? = nil
    
    var isUpcoming: NSNumber?
    
    var mapView: GMSMapView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.mapView?.delegate = self
        self.loadMapView()
//        self.btnBack.titles = NSLocalizedString("Back", comment: "")
        
        self.lblCancel.text = NSLocalizedString("Cancel", comment: "")
        self.lblCount.text = self.object?.i_beneficiaries_count
        self.lblDate.text = self.object?.dt_datetime.description
        
        if (self.isUpcoming == 0) {
            self.cancelView.isHidden = true
            self.operationViewWidthConstraint.constant = 210
            self.cancelViewWidthConstraint.constant = 0
        }
        
//        self.lblDate.text = self.object!.dt_datetime.gregorianDateStringWithFormat("MMMM EEEE, yyyy")
        

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
    @IBAction func tapCancel(_ sender: UITapGestureRecognizer) {
        let alertController = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("Do you want to cancel this operation ?", comment: ""), preferredStyle: (.alert))
        let noAction = UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: nil)
        alertController.addAction(noAction)
        let yesAction = UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default) { (action) in
            self.postCancelAppointment()
        }
        alertController.addAction(yesAction)
        
        
        self.present(alertController, animated: true, completion: nil)
    }

    func loadMapView() {
        let camera = GMSCameraPosition.camera(withLatitude: CDouble(self.object!.d_lat!)!, longitude: CDouble(self.object!.d_lng!)!, zoom: 16)
        self.mapView = GMSMapView.map(withFrame: self.view!.bounds, camera: camera)
        self.mapView?.delegate = self
        self.mapView?.isMyLocationEnabled = true
        self.googleMapView.addSubview(self.mapView!)
        
        self.drawMapMarker(lat: Double(self.object!.d_lat!)!, lon: Double(self.object!.d_lng!)!, title: NSLocalizedString("Address Here", comment: ""), desc: "", imgIcon: "icMyLocationPin", userData: AnyObject.self as AnyObject, showMap: true)
    }
    
    func drawMapMarker(lat: Double, lon: Double, title: String, desc: String, imgIcon: String, userData: AnyObject, showMap: Bool) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(lat, lon)
        marker.title = title
        marker.map = self.mapView
    }
    func postCancelAppointment()  {
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

        params["appointmentID"] = self.object?.pk_i_id
        params["sp"] = "F7E009C286C34A6EA300C419D64EBA44"
        SVProgressHUD.show()
        RKObjectManager.shared().getObject(nil, path: "RepCancelAppointment", parameters: params, success: { (operation, mappingResult) in
            SVProgressHUD.dismiss()
            
            if NLCommon.webServiceDefaultHandlerFailed(with: operation, mappingResult: mappingResult, error: nil, view: self.view) {
                return
            }
            
            NLCommon.viewToastMsg(NSLocalizedString("Cancel Confirmed", comment: ""), view: self.view)
            
            self.object?.b_cancelled = true
            
            NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
            
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
