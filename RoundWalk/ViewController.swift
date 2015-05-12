//
//  ViewController.swift
//  RoundWalk
//
//  Created by Daichi.T on 2015/05/11.
//  Copyright (c) 2015年 Daichi.T. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    let apiKey = "AIzaSyAsWaICEUOcyRjz-jMyNzpicDG3O2OtTgs"
    var myLocationManager:CLLocationManager!
    var googleMap : GMSMapView!
    var marker = GMSMarker()
    
    var session: NSURLSession {
        return NSURLSession.sharedSession()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ボタンの生成.
        let myButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        myButton.backgroundColor = UIColor.orangeColor()
        myButton.layer.masksToBounds = true
        myButton.setTitle("GET", forState: .Normal)
        myButton.layer.cornerRadius = 50.0
        myButton.layer.position = CGPoint(x: self.view.bounds.width - self.view.bounds.width / 6, y:self.view.bounds.height - self.view.bounds.height / 10)
        myButton.addTarget(self, action: "onClickMyButton:", forControlEvents: .TouchUpInside)
        
        // 現在地の取得.
        myLocationManager = CLLocationManager()
        
        myLocationManager.delegate = self
        // 取得精度の設定.
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 取得頻度の設定.
        myLocationManager.distanceFilter = 100
        
        // セキュリティ認証のステータスを取得.
        let status = CLLocationManager.authorizationStatus()
        
        NSLog("\(status)")
        // まだ認証が得られていない場合は、認証ダイアログを表示.
        if status == CLAuthorizationStatus.NotDetermined {
            NSLog("didChangeAuthorizationStatus:\(status)");
            // まだ承認が得られていない場合は、認証ダイアログを表示.
            self.myLocationManager.requestAlwaysAuthorization()
            NSLog("requestAlwaysAuthorization");
        }
        
        let lat: CLLocationDegrees = 35.658599
        let lon: CLLocationDegrees = 139.745443
        let zoom: Float = 17
        let camera: GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(lat,longitude: lon,zoom: zoom);
        
        googleMap = GMSMapView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height))
        googleMap.camera = camera
        googleMap.myLocationEnabled = true
        
        var marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(lat, lon)
        marker.title = "東京タワー";
        marker.snippet = "Tokyo Tower";
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.map = googleMap
        
        self.view.addSubview(googleMap)
        self.view.addSubview(myButton)
    }
    
    // ボタンイベントのセット.
    func onClickMyButton(sender: UIButton){
        // 現在位置の取得を開始.
        myLocationManager.startUpdatingLocation()
        NSLog("onClickMyButton")
    }
    
    // 位置情報取得の認証ステータスを取得するときに呼び出される
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        NSLog("didChangeAuthorizationStatus");
        
        // 認証のステータスをログで表示.
        var statusStr = "";
        switch status {
        case .NotDetermined:
            statusStr = "NotDetermined"
        case .Restricted:
            statusStr = "Restricted"
        case .Denied:
            statusStr = "Denied"
        case .AuthorizedWhenInUse:
            statusStr = "AuthorizedWhenInUse"
        default:
            statusStr = "etc"
        }
        NSLog(" CLAuthorizationStatus: \(statusStr)")
    }
    
    
    // 位置情報取得に成功したときに呼び出されるデリゲート.
    func locationManager(manager: CLLocationManager!,didUpdateLocations locations: [AnyObject]!){
        
        NSLog("didUpdateLocations")

        
        // 配列から現在座標を取得.
        var myLocations: NSArray = locations as NSArray
        var myLastLocation: CLLocation = myLocations.lastObject as CLLocation
        
        var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude:myLastLocation.coordinate.latitude, longitude:myLastLocation.coordinate.longitude)
        var nowLocation :GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(coordinate.latitude, longitude:coordinate.longitude, zoom:17)
        //googleMap.camera = nowLocation
        
        marker.position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
        marker.title = "現在地";
        marker.snippet = " lat:\(coordinate.latitude)\n lon:\(coordinate.longitude)";
        marker.map = googleMap
        
        var toPlaceCoordinate =  CLLocationCoordinate2DMake(35.658599, 139.745443);
        
        self.fetchDirectionsFrom(coordinate, to: toPlaceCoordinate) {
            optionalRoute in
            if let encodedRoute = optionalRoute {
                // 3
                let path = GMSPath(fromEncodedPath: encodedRoute)
                let line = GMSPolyline(path: path)
                
                var bounds:GMSCoordinateBounds = GMSCoordinateBounds(path: path)
                var camera:GMSCameraUpdate = GMSCameraUpdate.fitBounds(bounds, withPadding:20)
                self.googleMap.animateWithCameraUpdate(camera)
                
                // 4
                line.strokeWidth = 4.0
                line.tappable = true
                line.map = self.googleMap
                
            }
        }
        

        myLocationManager.stopUpdatingLocation()
    }
    
    // 位置情報取得に失敗した時に呼び出されるデリゲート.
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!){
        NSLog("error")
    }
    
    func fetchDirectionsFrom(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, completion: ((String?) -> Void)) -> ()
    {
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(from.latitude),\(from.longitude)&destination=\(to.latitude),\(to.longitude)&mode=walking"
        
        NSLog("urlString: \(urlString)")
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        session.dataTaskWithURL(NSURL(string: urlString)!) {data, response, error in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            var encodedRoute: String?
            if let json = NSJSONSerialization.JSONObjectWithData(data, options:nil, error:nil) as? [String:AnyObject] {
                if let routes = json["routes"] as AnyObject? as? [AnyObject] {
                    if let route = routes.first as? [String : AnyObject] {
                        if let polyline = route["overview_polyline"] as AnyObject? as? [String : String] {
                            if let points = polyline["points"] as AnyObject? as? String {
                                encodedRoute = points
                            }
                        }
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                completion(encodedRoute)
            }
        }.resume()
    }
    
}
