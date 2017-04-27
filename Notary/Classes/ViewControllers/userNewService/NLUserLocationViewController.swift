//
//  NLUserLocationViewController.swift
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

class NLUserLocationViewController: UIViewController, GMSMapViewDelegate , GMDraggableMarkerManagerDelegate {
    
//    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var googleMapView: UIView!

    var service: TServices? = nil
    var requestParams: [AnyHashable: Any]? = nil
    
    var mapView: GMSMapView? = nil
    
    var draggableMarkerManager: GMDraggableMarkerManager? = nil

    var locationPoint: CLLocationCoordinate2D? = nil
    var movingMarker: GMSMarker? = nil
    var myLat: Double = 0, mylLon: Double = 0
    var availableTimes = [NSDate]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.mapView?.delegate = self
        
        myLat = MBLocationManager.shared().currentLocation.coordinate.latitude
        mylLon = MBLocationManager.shared().currentLocation.coordinate.longitude
        self.loadMapView()
        self.btnNext.layer.borderWidth = 1
        self.btnNext.layer.borderColor = UIColor.black.cgColor
        self.btnNext.clipsToBounds = true
//        self.btnBack.titles = NSLocalizedString("Back", comment: "")
        self.draggableMarkerManager = GMDraggableMarkerManager(mapView: self.mapView, delegate: self)
        movingMarker = GMSMarker()
        movingMarker?.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        movingMarker?.icon = UIImage(named: "icPin")!
        movingMarker?.position = CLLocationCoordinate2DMake(myLat, mylLon)
        //    movingMarker.tracksInfoWindowChanges = YES;
        self.draggableMarkerManager?.addDraggableMarker(movingMarker)
        movingMarker?.map = self.mapView
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Back", comment: ""), style: .done, target: nil, action: nil)
        //make transparent navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear

    }
    func loadMapView() {
        let camera = GMSCameraPosition.camera(withLatitude: myLat, longitude: mylLon, zoom: 16)
        self.mapView = GMSMapView.map(withFrame: self.view!.bounds, camera: camera)
        self.mapView?.delegate = self
        self.mapView?.isMyLocationEnabled = true
        self.googleMapView.addSubview(self.mapView!)
        
        self.googleMapView.addSubview(self.btnNext)
    }

    @IBAction func btnBack(_ sender: UIButton) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnNext(_ sender: UIButton) {
        self.requestParams?["lat"] = movingMarker?.position.latitude
        self.requestParams?["lng"] = movingMarker?.position.longitude
        fetchListAvailableTimesFromInternet()
    }

    func fetchListAvailableTimesFromInternet()  {
        var params = self.requestParams
        params?["sp"] = "F7E009C286C34A6EA300C419D64EBA44"
        SVProgressHUD.show()
        
        RKObjectManager.shared().getObject(nil, path: "ClientListAvailableTimes", parameters: params, success: { (operation, mappingResult) in
            SVProgressHUD.dismiss()
            if NLCommon.webServiceDefaultHandlerFailed(with: operation, mappingResult: mappingResult, error: nil, view: self.view) {
                return
            }
            let json = try! JSONSerialization.jsonObject(with: (operation?.httpRequestOperation.responseData)!, options: .mutableLeaves) as! NSDictionary
            self.availableTimes.removeAll()
            
            let arr = json["availability"] as! [String]
            
            
            if arr.count > 0 {
                for str: String in arr {
                    self.availableTimes.append(NSDate(fromAvailableTime: str))
                }
                
                let detailPostViewController = self.storyboard?.instantiateViewController(withIdentifier: "NLUserServiceDateTimeViewController") as! NLUserServiceDateTimeViewController
                detailPostViewController.requestParams = self.requestParams
                self.navigationController?.pushViewController(detailPostViewController, animated: true)

            } else {
                
            }

            
        }) { (operation, error) in
            SVProgressHUD.dismiss()
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
