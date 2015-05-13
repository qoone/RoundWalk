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
    var time:Int = 0
    var label:UILabel!
    var timeLabel:UILabel!
    var descriptionLabal:UILabel!
    var timeValue:Int = 60;
    var compassValue:Int = 0;
    var session: NSURLSession {
        return NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ボタンの生成.
        let myButton = UIButton(frame: CGRect(x: 0, y: 0, width: 75, height: 75))
        myButton.backgroundColor = UIColor.orangeColor()
        myButton.layer.masksToBounds = true
        myButton.setTitle("ルート\n取得", forState: .Normal)
        //myButton.sizeToFit()
        myButton.layer.cornerRadius = 12.5
        myButton.layer.position = CGPoint(x: self.view.bounds.width - 50, y:self.view.bounds.height - 50)
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
        let camera: GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(lat, longitude:lon, zoom: zoom);
        
        googleMap = GMSMapView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height - 120))
        googleMap.camera = camera
        googleMap.myLocationEnabled = true
        /*
        var marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(lat, lon)
        marker.title = "東京タワー";
        marker.snippet = "Tokyo Tower";
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.map = googleMap
        */
        
        let sld = UISlider(frame: CGRectMake(20, self.view.bounds.height - self.view.bounds.height / 8, 200, 40))
        // 最大値・最小値を指定
        sld.minimumValue = 1
        sld.maximumValue = 120
        // 初期値を指定
        sld.setValue(60, animated: true)
        // 値が変わった時の処理を指定
        sld.addTarget(self, action: "sliderChanged:", forControlEvents: UIControlEvents.ValueChanged)
        
        // ラベルの座標と大きさを指定
        label = UILabel(frame: CGRectMake(self.view.bounds.width / 2 + 40, self.view.bounds.height - self.view.bounds.height / 8, 50, sld.frame.height))
        // テキストをスライダーの値に
        label.text = "\(Int(sld.value))分"
        
        timeLabel = UILabel(frame: CGRectMake(20, self.view.bounds.height - self.view.bounds.height / 12, sld.frame.width, sld.frame.height))
        // テキストをスライダーの値に
        timeLabel.text = "ルートの所要時間:"
        timeLabel.font = UIFont.systemFontOfSize(13)
        
        descriptionLabal = UILabel(frame: CGRectMake(20, self.view.bounds.height - 110, self.view.bounds.width - 40, 20))
        // テキストをスライダーの値に
        descriptionLabal.text = "散歩したい方向を向いてルートボタンを押してください"
        descriptionLabal.font = UIFont.systemFontOfSize(12)
        myLocationManager.startUpdatingHeading()

        self.view.addSubview(googleMap)
        self.view.addSubview(myButton)
        self.view.addSubview(label)
        self.view.addSubview(timeLabel)
        self.view.addSubview(descriptionLabal)
        self.view.addSubview(sld)
        
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
        
        googleMap.clear()
        NSLog("didUpdateLocations")

        // 配列から現在座標を取得.
        var myLocations: NSArray = locations as NSArray
        var myLastLocation: CLLocation = myLocations.lastObject as CLLocation
        
        var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude:myLastLocation.coordinate.latitude, longitude:myLastLocation.coordinate.longitude)
        var nowLocation :GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(coordinate.latitude, longitude:coordinate.longitude, zoom:17)
        
        marker.position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
        marker.title = "現在地";
        marker.snippet = " lat:\(coordinate.latitude)\n lon:\(coordinate.longitude)";
        marker.map = googleMap
        
        
        println("timeValue:\(timeValue * 30)")
        var toPlaceCoordinate =  calcNewLocationFrom(coordinate, distance:CLLocationDistance(Int(self.timeValue * Int(20 * 1.41))), direction:CLLocationDirection(compassValue))//CLLocationCoordinate2DMake(35.658599, 139.745443);
        
        self.getRoute(toPlaceCoordinate, to:coordinate, n:3)
        myLocationManager.stopUpdatingLocation()
    }
    
    func getRoute(from:CLLocationCoordinate2D, to:CLLocationCoordinate2D, n:Int = 0) {
        self.fetchDirectionsFrom(from, to:to, n:n) {
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
            self.timeLabel.text = "ルートの所要時間:\(Int(ceil(Float(self.time / 60))))分"
            println("time: \(ceil(Float(self.time / 60)))分")
            self.time = 0
        }
        
    }
    // 位置情報取得に失敗した時に呼び出されるデリゲート.
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!){
        NSLog("error")
    }
    
    func fetchDirectionsFrom(from: CLLocationCoordinate2D, to:CLLocationCoordinate2D, n:Int = 0, completion: ((String?) -> Void)) -> ()
    {
        var newPosition1:CLLocationCoordinate2D!
        var newPosition2:CLLocationCoordinate2D!
        var s:String!
        
        var dir:Int!
        if (compassValue - 45) >= 0 {
            dir = compassValue - 45
        } else {
            dir = 360 + compassValue - 45
        }
        println("compas n1:\(compassValue)")
        println("n1:\(dir)")
        newPosition1 = calcNewLocationFrom(to, distance:CLLocationDistance(Int(self.timeValue * 20)),direction:CLLocationDirection(dir))
        
        dir = 0
        if (compassValue + 135) >= 360 {
            dir = compassValue + 135 - 360
        } else {
            dir = compassValue + 135
        }
        println("compas n2:\(compassValue)")
        println("n2:\(dir)")
        
        newPosition2 = calcNewLocationFrom(from, distance:CLLocationDistance(Int(self.timeValue * 20)), direction:CLLocationDirection(dir))
        
        var urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(from.latitude),\(from.longitude)&destination=\(from.latitude),\(from.longitude)&waypoints=\(newPosition1.latitude),\(newPosition1.longitude)|\(to.latitude),\(to.longitude)|\(newPosition2.latitude),\(newPosition2.longitude)&mode=walking"

        var url:NSURL = NSURL(string: urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!
        
        println("encode URL: \(url)")
        
        self.markerPosition(from, title:"From")
        self.markerPosition(to, title:"To")
        self.markerPosition(newPosition1, title:"\(s) Middle1")
        self.markerPosition(newPosition2, title:"\(s) Middle2")
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        session.dataTaskWithURL(url) {data, response, error in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            var encodedRoute: String?
            var error: NSError?
            if let json = NSJSONSerialization.JSONObjectWithData(data, options:nil, error:&error) as? [String:AnyObject] {
                if let routes = json["routes"] as AnyObject? as? [AnyObject] {
                    if let route = routes.first as? [String : AnyObject] {
                        if let polyline = route["overview_polyline"] as AnyObject? as? [String : String] {
                            if let points = polyline["points"] as AnyObject? as? String {
                                encodedRoute = points
                            }
                        }
                        if let legs = route["legs"] as AnyObject? as? [AnyObject] {
                            for var i = 0; i < legs.count; i++ {
                                if let leg = legs[i] as? [String : AnyObject] {
                                    if let distance = leg["distance"] as? [String : AnyObject] {
                                        if let value = distance["value"] as AnyObject? as? Int {
                                            self.time += value
                                        }
                                    }
                                }
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
    
    func markerPosition(position:CLLocationCoordinate2D, title:String) -> () {
        var markerPositions = GMSMarker()
        markerPositions.position = CLLocationCoordinate2DMake(position.latitude, position.longitude);
        markerPositions.title = "\(title)";
        markerPositions.snippet = " lat:\(position.latitude)\n lon:\(position.longitude)";
        markerPositions.map = googleMap

    }
    
    
    /*
    自分の現在地から角度で決まった方角に指定した距離移動
    distance:メートル
    direction:度
    真北を0として、時計回りに 0 から 359.9 度の値をとる。つまり、
    北:0 東:90 南:180 西:270となる。マイナス値は無効。
    */
    
    func calcNewLocationFrom(current:CLLocationCoordinate2D, distance:CLLocationDistance, direction:CLLocationDirection) -> CLLocationCoordinate2D {
    
        if (!(distance > 0.0) || direction < 0) {
            return current;
        }
        var distX:CLLocationDistance = distance * sin(direction * (M_PI / 180.0))
        var distY:CLLocationDistance = -distance * cos(direction * (M_PI / 180.0))
        var currentPoint:MKMapPoint = MKMapPointForCoordinate(current)
        var mapPointsPerMeter:Double = MKMapPointsPerMeterAtLatitude(current.latitude);
        var deltaMapPointsX:Double = mapPointsPerMeter * distX;
        var deltaMapPointsY:Double = mapPointsPerMeter * distY;
        var newPoint:MKMapPoint = MKMapPointMake(currentPoint.x + deltaMapPointsX, currentPoint.y + deltaMapPointsY);
        var newPosition:CLLocationCoordinate2D = MKCoordinateForMapPoint(newPoint);
    
        return newPosition;
    }
    
    func sliderChanged(sender: UISlider) {
        // スライダーが動いた時にラベルの値を更新
        label.text = "\(Int(sender.value))分 "
        self.timeValue = Int(sender.value)
    }
    
    // コンパスの値を受信
    func locationManager(manager:CLLocationManager, didUpdateHeading newHeading:CLHeading) {
        compassValue = Int(newHeading.magneticHeading)
        println(compassValue)
    }
    
}
