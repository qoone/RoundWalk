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
    
    var myLocationManager:CLLocationManager!
    var googleMap : GMSMapView!
    var options = GMSMarker()
    
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
            println("didChangeAuthorizationStatus:\(status)");
            // まだ承認が得られていない場合は、認証ダイアログを表示.
            self.myLocationManager.requestAlwaysAuthorization()
            println("requestAlwaysAuthorization");
        }
        
        let lat: CLLocationDegrees = 35.658599
        let lon: CLLocationDegrees = 139.745443
        let zoom: Float = 17
        let camera: GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(lat,longitude: lon,zoom: zoom);
        
        googleMap = GMSMapView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height))
        googleMap.camera = camera
        googleMap.myLocationEnabled = true
        
        var options = GMSMarker()
        options.position = CLLocationCoordinate2DMake(lat, lon);
        options.title = "東京タワー";
        options.snippet = "Tokyo Tower";
        options.appearAnimation = kGMSMarkerAnimationPop
        options.map = googleMap
                
        self.view.addSubview(googleMap)
        self.view.addSubview(myButton)
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        println("didChangeAuthorizationStatus");
        
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
        println(" CLAuthorizationStatus: \(statusStr)")
    }
    
    // ボタンイベントのセット.
    func onClickMyButton(sender: UIButton){
        // 現在位置の取得を開始.
        myLocationManager.startUpdatingLocation()
        NSLog("onClickMyButton")
    }
    
    
    // 位置情報取得に成功したときに呼び出されるデリゲート.
    func locationManager(manager: CLLocationManager!,didUpdateLocations locations: [AnyObject]!){
        
        NSLog("didUpdateLocations")

        
        // 配列から現在座標を取得.
        var myLocations: NSArray = locations as NSArray
        var myLastLocation: CLLocation = myLocations.lastObject as CLLocation
        
        var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude:myLastLocation.coordinate.latitude, longitude:myLastLocation.coordinate.longitude)
        var nowLocation :GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(coordinate.latitude, longitude:coordinate.longitude, zoom:17)
        googleMap.camera = nowLocation
        
        options.position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
        options.title = "現在地";
        options.snippet = " lat:\(coordinate.latitude)\n lon:\(coordinate.longitude)";
        options.map = googleMap
        
        myLocationManager.stopUpdatingLocation()
    }
    
    // 位置情報取得に失敗した時に呼び出されるデリゲート.
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!){
        print("error")
    }
    
}
