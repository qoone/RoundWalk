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
    var myButton:UIButton!
    var mySlider:UISlider!
    var walkStatusButton:UIButton!
    var grayView:UIView!
    var time:Int = 0
    var label:UILabel!
    var timeLabel:UILabel!
    var descriptionLabal:UILabel!
    var sliderValue:Int = 60
    var sliderValueSec:Int = 3600
    var compassValue:Int = 0
    var magnificationValue:Float = 1.00
    var flag:Bool = true
    var range:Int = 5
    var onClickFlag:Bool = false
    var walkStatus:Bool = true
    var startAppFlag:Bool = true
    var myLocation:CLLocationCoordinate2D!
    var myTimer:NSTimer!
    var lastRoute:String!
    /*
    var markerPositions1 = GMSMarker()
    var markerPositions2 = GMSMarker()
    var markerPositions3 = GMSMarker()
    */
    var session: NSURLSession {
        return NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ボタンの生成.
        myButton = UIButton()
        myButton.frame = CGRectMake(0, 0, 75, 75)
        myButton.backgroundColor = UIColor.orangeColor()
        myButton.layer.masksToBounds = true
        myButton.setTitle("ルート", forState: .Normal)
        //myButton.sizeToFit()
        myButton.layer.cornerRadius = 12.5
        myButton.layer.position = CGPoint(x: self.view.bounds.width - 50, y:self.view.bounds.height - 50)
        myButton.addTarget(self, action: "onClickMyButton:", forControlEvents: .TouchUpInside)
        
        myLocationManager = CLLocationManager()
        myLocationManager.delegate = self
        // 取得精度の設定.
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 取得頻度の設定.
        myLocationManager.distanceFilter = 0.5
        //myLocationManager.locationServicesEnabled();
        // セキュリティ認証のステータスを取得.
        let status = CLLocationManager.authorizationStatus()
        
        NSLog("\(status)")
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
        
        mySlider = UISlider()
        mySlider.frame = CGRectMake(20, self.view.bounds.height - self.view.bounds.height / 8, 200, 40)
        // 最大値・最小値を指定
        mySlider.minimumValue = 10
        mySlider.maximumValue = 120
        // 初期値を指定
        mySlider.setValue(60, animated: true)
        // 値が変わった時の処理を指定
        mySlider.addTarget(self, action: "sliderChanged:", forControlEvents: UIControlEvents.ValueChanged)
        
        // ラベルの座標と大きさを指定
        label = UILabel(frame: CGRectMake(self.view.bounds.width / 2 + 40, self.view.bounds.height - self.view.bounds.height / 8, 50, mySlider.frame.height))
        // テキストをスライダーの値に
        label.text = "\(Int(mySlider.value))分"
        
        timeLabel = UILabel(frame: CGRectMake(20, self.view.bounds.height - self.view.bounds.height / 12, mySlider.frame.width, mySlider.frame.height))
        timeLabel.text = "ルートの所要時間:"
        timeLabel.font = UIFont.systemFontOfSize(13)
        
        descriptionLabal = UILabel(frame: CGRectMake(20, self.view.bounds.height - 110, self.view.bounds.width - 40, 20))
        descriptionLabal.text = "散歩したい方向を向いてルートボタンを押してください"
        descriptionLabal.font = UIFont.systemFontOfSize(12)
        
        self.view.addSubview(googleMap)
        self.view.addSubview(myButton)
        self.view.addSubview(label)
        self.view.addSubview(timeLabel)
        self.view.addSubview(descriptionLabal)
        self.view.addSubview(mySlider)
        
        // コンパス & GPSスタート
        myLocationManager.startUpdatingHeading()
        myLocationManager.startUpdatingLocation()
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
        var nowLocation :GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(coordinate.latitude, longitude:coordinate.longitude, zoom:16)
        
        if !onClickFlag && startAppFlag {
            googleMap.camera = nowLocation
            startAppFlag = false
        }
        
        println("sliderValue(秒):\(sliderValue * 60)秒")
        
        if onClickFlag {
            googleMap.clear()
            
            marker.position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
            marker.title = "出発地点";
            marker.snippet = " lat:\(coordinate.latitude)\n lon:\(coordinate.longitude)";
            marker.map = googleMap
            
            var toPlaceCoordinate = calcNewLocationFrom(coordinate, distance:CLLocationDistance(Int(self.sliderValue * Int(12.5 * 1.41 * self.magnificationValue))), direction:CLLocationDirection(compassValue))
            self.getRoute(toPlaceCoordinate, to:coordinate)
            println("while: \(self.flag)")
            println("magnificationValue: \(self.magnificationValue)")
            onClickFlag = false
        }
        myLocation = coordinate
    }
    
    // 位置情報取得に失敗した時に呼び出されるデリゲート.
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!){
        NSLog("error")
    }
    
    func getNowLocationPath(timer:NSTimer) {
        var lat:Double
        var lon:Double
        println("myLocation.lan: \(myLocation.latitude)")
        println("myLocation.lon: \(myLocation.longitude)")
        var myCircle = GMSCircle()
        myCircle.position = CLLocationCoordinate2D(latitude:myLocation.latitude, longitude:myLocation.longitude)
        myCircle.radius = 1
        myCircle.strokeColor = UIColor.redColor()
        myCircle.strokeWidth = 5.0
        myCircle.map = self.googleMap
    }

    
    // ボタンイベントのセット.
    func onClickMyButton(sender: UIButton){
        
        myLocationManager.stopUpdatingLocation()
        // 現在位置の取得を開始.
        self.onClickFlag = true
        myLocationManager.startUpdatingLocation()
        
        NSLog("onClickMyButton")
        if walkStatus {
            walkStatusButton = UIButton()
            walkStatusButton.frame = CGRectMake(0, 0, 75, 75)
            walkStatusButton.backgroundColor = UIColor.orangeColor()
            walkStatusButton.layer.masksToBounds = true
            walkStatusButton.setTitle("START", forState: .Normal)
            walkStatusButton.layer.cornerRadius = 37.5
            walkStatusButton.tag = 1
            walkStatusButton.layer.position = CGPoint(x: self.view.bounds.width - 50, y:60)
            walkStatusButton.addTarget(self, action: "onClickWalkStatusButton:", forControlEvents: .TouchUpInside)
            walkStatus = false
            self.view.addSubview(walkStatusButton)
            NSLog("walkStatus: \(walkStatus)")
        }
    }
    
    func onClickWalkStatusButton(sender:UIButton) {
        println("onClickWalkStatusButton")
        if sender.tag == 1 {
            println("onClickStartButton")
            walkStatus = true
            self.myButton.enabled = false
            self.mySlider.enabled = false
            walkStatusButton.backgroundColor = UIColor.redColor()
            walkStatusButton.layer.masksToBounds = true
            walkStatusButton.setTitle("END", forState: .Normal)
            walkStatusButton.layer.cornerRadius = 37.5
            walkStatusButton.tag = 2
            walkStatusButton.layer.position = CGPoint(x: self.view.bounds.width - 50, y:60)
            walkStatusButton.addTarget(self, action: "onClickWalkStatusButton:", forControlEvents: .TouchUpInside)
            
            grayView = UIView(frame: CGRectMake(0, self.view.bounds.height - 120, self.view.bounds.width, 120))
            grayView.backgroundColor = UIColor.grayColor()
            grayView.alpha = 0.3;
            /*
            markerPositions1.draggable = false
            markerPositions2.draggable = false
            markerPositions3.draggable = false
            */
            
            myTimer = NSTimer.scheduledTimerWithTimeInterval(15.0, target: self, selector: "getNowLocationPath:", userInfo: nil, repeats: true)
            
            self.view.addSubview(grayView)
        
        } else if sender.tag == 2 {
            
            let alertController = UIAlertController(title: "確認", message: "散歩を終了しますか？\nOKを押すと自分が実際に歩いた経路は消えます。", preferredStyle: .ActionSheet)
            let okAction = UIAlertAction(title: "OK", style: .Default) {
                action in println("Pushed OK")
                self.myButton.enabled = true
                self.mySlider.enabled = true
                self.grayView.removeFromSuperview()
                self.walkStatusButton.removeFromSuperview()
                self.myTimer.invalidate()
                self.myTimer = nil;
                self.googleMap.clear()
                self.myLocationManager.stopUpdatingLocation()
                let path = GMSPath(fromEncodedPath: self.lastRoute)
                let line = GMSPolyline(path: path)
                line.strokeWidth = 4.0
                line.tappable = true
                line.map = self.googleMap

            }
            let cancelAction = UIAlertAction(title: "CANCEL", style: .Cancel) {
                action in println("Pushed CANCEL")
            }
            
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            
            alertController.popoverPresentationController?.sourceView = sender as UIView;
            alertController.popoverPresentationController?.sourceRect = CGRect(x: (sender.frame.width/2), y: sender.frame.height, width: 0, height: 0)
            alertController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.Up
            
            presentViewController(alertController, animated: true, completion: nil)
            println("onClickEndButton")
            
        }
    }
    
    
    func getRoute(from:CLLocationCoordinate2D, to:CLLocationCoordinate2D) {
        self.fetchDirectionsFrom(from, to:to) {
            optionalRoute in
            if let encodedRoute = optionalRoute {
                let path = GMSPath(fromEncodedPath: encodedRoute)
                let line = GMSPolyline(path: path)
                //line.geodesic = true
                var bounds:GMSCoordinateBounds = GMSCoordinateBounds(path: path)
                var camera:GMSCameraUpdate = GMSCameraUpdate.fitBounds(bounds, withPadding:20)
                self.googleMap.animateWithCameraUpdate(camera)
                
                line.strokeWidth = 4.0
                line.tappable = true
                line.map = self.googleMap
            }
            self.timeLabel.text = "ルートの所要時間:約\(Int(ceil(Float(self.time / 60))))分"
            println("time: \(ceil(Float(self.time / 60)))分")
            self.time = 0
        }
    }
    
    func fetchDirectionsFrom(from: CLLocationCoordinate2D, to:CLLocationCoordinate2D, completion: ((String?) -> Void)) -> ()
    {
        var newPosition1:CLLocationCoordinate2D!
        var newPosition2:CLLocationCoordinate2D!
        
        var dir = self.directionCalc(compassValue)
        
        newPosition1 = calcNewLocationFrom(to, distance:CLLocationDistance(Int(Float(self.sliderValue) * 12.5 * self.magnificationValue)),direction:CLLocationDirection(dir.dirA))
        
        newPosition2 = calcNewLocationFrom(from, distance:CLLocationDistance(Int(Float(self.sliderValue) * 12.5 * self.magnificationValue)), direction:CLLocationDirection(dir.dirB))
        
        var urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(from.latitude),\(from.longitude)&destination=\(from.latitude),\(from.longitude)&waypoints=\(newPosition1.latitude),\(newPosition1.longitude)|\(to.latitude),\(to.longitude)|\(newPosition2.latitude),\(newPosition2.longitude)&mode=walking"
        
        var url:NSURL = NSURL(string: urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!
        
        println("encode URL: \(url)")
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        session.dataTaskWithURL(url) {data, response, error in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            var encodedRoute: String?
            var error: NSError?
            var disFlag:Bool = false
            println("session:")
            if let json = NSJSONSerialization.JSONObjectWithData(data, options:nil, error:&error) as? [String:AnyObject] {
                if let routes = json["routes"] as AnyObject? as? [AnyObject] {
                    if let route = routes.first as? [String : AnyObject] {
                        if let polyline = route["overview_polyline"] as AnyObject? as? [String : String] {
                            if let points = polyline["points"] as AnyObject? as? String {
                                encodedRoute = points
                                self.lastRoute = encodedRoute
                                println("encodedRoute: \(encodedRoute!)")
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
        
        self.markerPosition(from, title:"チェックポイント2")
        self.markerPosition(newPosition1, title:"チェックポイント1")
        self.markerPosition(newPosition2, title:"チェックポイント3")
        /*
        self.markerPosition(from, title:"チェックポイント2", tag:2)
        self.markerPosition(newPosition1, title:"チェックポイント1", tag:1)
        self.markerPosition(newPosition2, title:"チェックポイント3", tag:3)
*/
    }
    
    /*
    func markerPosition(position:CLLocationCoordinate2D, title:String, tag:Int) -> () {
        
        switch tag {
            case 1:
                markerPositions1.position = CLLocationCoordinate2DMake(position.latitude, position.longitude)
                markerPositions1.title = "\(title)"
                markerPositions1.snippet = " lat:\(position.latitude)\n lon:\(position.longitude)"
                markerPositions1.map = googleMap
                markerPositions1.draggable = true
            case 2:
                markerPositions2.position = CLLocationCoordinate2DMake(position.latitude, position.longitude)
                markerPositions2.title = "\(title)"
                markerPositions2.snippet = " lat:\(position.latitude)\n lon:\(position.longitude)"
                markerPositions2.map = googleMap
                markerPositions2.draggable = true
            case 3:
                markerPositions3.position = CLLocationCoordinate2DMake(position.latitude, position.longitude)
                markerPositions3.title = "\(title)"
                markerPositions3.snippet = " lat:\(position.latitude)\n lon:\(position.longitude)"
                markerPositions3.map = googleMap
                markerPositions3.draggable = true
            default:
                break
        }
    }
*/
    
    func markerPosition(position:CLLocationCoordinate2D, title:String) -> () {
        var markerPositions = GMSMarker()
        markerPositions.position = CLLocationCoordinate2DMake(position.latitude, position.longitude);
        markerPositions.title = "\(title)";
        markerPositions.snippet = " lat:\(position.latitude)\n lon:\(position.longitude)";
        markerPositions.map = googleMap
        markerPositions.draggable = true

    }
    
    // 任意の中間点を決めるための方位を計算
    func directionCalc(currentDirection:Int) -> (dirA:Int, dirB:Int) {
        var dirA:Int!
        var dirB:Int!
        if (currentDirection - 45) >= 0 {
            dirA = currentDirection - 45
        } else {
            dirA = 360 + currentDirection - 45
        }
        
        if (currentDirection + 135) >= 360 {
            dirB = currentDirection + 135 - 360
        } else {
            dirB = currentDirection + 135
        }

        return (dirA, dirB)
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
        self.sliderValue = Int(sender.value)
        self.sliderValueSec = Int(sender.value) * 60
        println("sliderChanged sliderValueSec: \(self.sliderValueSec)")
    }
    
    // コンパスの値を受信
    func locationManager(manager:CLLocationManager, didUpdateHeading newHeading:CLHeading) {
        compassValue = Int(newHeading.magneticHeading)
        println(compassValue)
    }
    
    /*
    func mapView(mapView:GMSMapView, didBeginDraggingMarker marker:GMSMarker) -> (){
        println("didBeginDraggingMarker")
        println("marker.userData: \(marker.userData)")
        println("marker.userData: \(marker.position)")
    }
    
    func mapView(mapView:GMSMapView, didEndDraggingMarker marker:GMSMarker) -> (){
        println("didEndDraggingMarker")
        println("marker.userData: \(marker.userData)")
        println("marker.userData: \(marker.position)")
    }

    func mapView(mapView:GMSMapView, didDragMarker marker:GMSMarker) -> (){
        println("didDragMarker")
        println("marker.userData: \(marker.userData)")
        println("marker.userData: \(marker.position)")
    }
*/
    
}
