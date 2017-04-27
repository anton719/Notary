//
//  NLAdminLocationViewController.swift
//  Notary
//
//  Created by Admin on 3/19/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import GoogleMaps
import MapKit
import RestKit
import MBLocationManager

class NLAdminLocationViewController: UIViewController, GMSMapViewDelegate ,MKMapViewDelegate {
//    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var googleMapView: UIView!

    var service: TServices? = nil
    var mapView: GMSMapView? = nil
    var count = ""
    var locationPoint: CLLocationCoordinate2D? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.loadMapView()
        
        self.btnNext.layer.borderWidth = 1
        self.btnNext.layer.borderColor = UIColor.black.cgColor
        self.btnNext.clipsToBounds = true
        self.btnNext.titles = NSLocalizedString("Next", comment: "")
        
      
//        self.changeBtnTitle(title: NSLocalizedString("Back", comment: ""), button: self.btnBack)
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
    func changeBtnTitle(title: String, button: UIButton)  {
        button.setTitle(title, for: .normal)
        button.setTitle(title, for: .highlighted)
        button.setTitle(title, for: .selected)
    }
    func loadMapView() {
        let myLat = MBLocationManager.shared().currentLocation.coordinate.latitude
        let mylLon = MBLocationManager.shared().currentLocation.coordinate.longitude
        let camera = GMSCameraPosition.camera(withLatitude: myLat, longitude: mylLon, zoom: 16)
        self.mapView = GMSMapView.map(withFrame: self.view!.bounds, camera: camera)
        self.mapView?.delegate = self
        self.mapView?.isMyLocationEnabled = true
        self.googleMapView.addSubview(self.mapView!)
        self.googleMapView.addSubview(self.btnNext)
    }

    @IBAction func btnBack(_ sender: UIButton) {
        let _ = self.navigationController!.popViewController(animated: true)!
    }
    @IBAction func btnNext(_ sender: UIButton) {
        self.postCheckLocationElegibility()
    }

    func postCheckLocationElegibility()  {
        var params = [AnyHashable: Any]()
        params["serviceID"] = self.service?.pk_i_id
        params["lat"] = NSString(format: "%f", (self.locationPoint?.latitude)!)
        params["lng"] = NSString(format: "%f", (self.locationPoint?.longitude)!)
        params["sp"] = "F7E009C286C34A6EA300C419D64EBA44"
        SVProgressHUD.show()
        RKObjectManager.shared().getObject(nil, path: "ValidateLocation", parameters: params, success: { (operation, mappingResult) in
            SVProgressHUD.dismiss()
            
            let json = try! JSONSerialization.jsonObject(with: (operation?.httpRequestOperation.responseData)!, options: .mutableLeaves) as! NSDictionary
            if json != nil && json.value(forKey: "result") != nil {
                let result = json.value(forKey: "result") as! String
                if result == "1" {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "NLAdminServiceDateTimeViewController") as! NLAdminServiceDateTimeViewController
                    vc.service = self.service
                    vc.count = self.count
                    vc.lat = NSString(format: "%f", (self.locationPoint?.latitude)!) as String
                    vc.lng = NSString(format: "%f", (self.locationPoint?.longitude)!) as String
                    self.navigationController?.pushViewController(vc, animated: true)
    
                } else {
                    
                }
            }
            
        }) { (operation, error) in
            SVProgressHUD.dismiss()
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "NLAdminServiceDateTimeViewController") as! NLAdminServiceDateTimeViewController
            vc.service = self.service
            vc.count = self.count
            vc.lat = NSString(format: "%f", (self.locationPoint?.latitude)!) as String
            vc.lng = NSString(format: "%f", (self.locationPoint?.longitude)!) as String
            self.navigationController?.pushViewController(vc, animated: true)
            

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
