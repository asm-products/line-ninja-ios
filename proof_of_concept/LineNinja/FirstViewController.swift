//
//  FirstViewController.swift
//  LineNinja
//
//  Created by David Sandor on 8/9/14.
//  Copyright (c) 2014 David Sandor. All rights reserved.
//

import UIKit
import MapKit

class FirstViewController: ResponsiveTextFieldViewController, MKMapViewDelegate, UIGestureRecognizerDelegate,
        CLLocationManagerDelegate
    {
                            
    @IBOutlet weak var theMapView: MKMapView!
    
    @IBOutlet weak var myLabel: UILabel!
    
    @IBOutlet weak var myTableView: UITableView!
    
    @IBOutlet weak var btnSell: UIButton!
    
    @IBOutlet weak var txtEventDescription: UITextField!
    
    @IBOutlet weak var txtSellerDescription: UITextField!
    
    @IBOutlet weak var txtAmount: UITextField!
    
    @IBOutlet weak var txtUserId: UITextField!
    
    var locationManager = CLLocationManager()
    
    var timeOfLastTouch: NSDate!
    
    var previousAnnotation: MKPointAnnotation!
    
    var touchLocation:CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.timeOfLastTouch = NSDate()
        self.startLocation()

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        longPressGesture.minimumPressDuration = 1.0
        longPressGesture.delegate = self
    
        self.theMapView.addGestureRecognizer(longPressGesture)
       
        self.theMapView.showsUserLocation = false
        
        self.watchTextField(txtAmount)
        self.watchTextField(txtEventDescription)
        self.watchTextField(txtSellerDescription)
        self.watchTextField(txtUserId)
    }

    func handleLongPress(sender:UILongPressGestureRecognizer) {
        
        /*
        let tapAlert = UIAlertController(title: "Long Pressed", message: "You just long pressed the long press view", preferredStyle: UIAlertControllerStyle.Alert)
        tapAlert.addAction(UIAlertAction(title: "OK", style: .Destructive, handler: nil))
        self.presentViewController(tapAlert, animated: true, completion: nil)
        */
      var dateObject = NSDate()
        
        var timeSinceLastTouch = dateObject.timeIntervalSinceDate(self.timeOfLastTouch)
        
        if (timeSinceLastTouch > 3)  {
            
            self.timeOfLastTouch = dateObject
        
            self.myLabel.text = "Last Touch: \(timeSinceLastTouch)"
        
            var touchPoint = sender.locationInView(self.theMapView)
            touchLocation = self.theMapView.convertPoint(touchPoint, toCoordinateFromView: self.theMapView)
        
            var newAnnotation = MKPointAnnotation()
            newAnnotation.coordinate = touchLocation
            newAnnotation.title = "Touch Location"
            newAnnotation.subtitle = "lon: \(touchLocation.longitude), lat: \(touchLocation.latitude)"
            
            if (self.previousAnnotation != nil) {
                self.theMapView.removeAnnotation(self.previousAnnotation)
            }
            
            self.theMapView.addAnnotation(newAnnotation)
            
            self.previousAnnotation = newAnnotation;
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startLocation()
    {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        locationManager.distanceFilter = 50
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var theSpan:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)

        var theRegion:MKCoordinateRegion = MKCoordinateRegionMake(locationManager.location.coordinate, theSpan)
        
        self.theMapView.setRegion(theRegion, animated: true)
    }
    
    @IBAction func postOffer(sender: AnyObject!)
    {
        if (self.touchLocation == nil) {
            return
        }
        
        var url = "http://rest.line.ninja:8080/postoffer"
        var request = NSMutableURLRequest()
        
        request.URL = NSURL(string: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = "{ \"location\": [\(self.touchLocation.longitude), \(self.touchLocation.latitude)], \"userid\": \(self.txtUserId.text), \"locationDescription\": \"\(self.txtEventDescription.text)\", \"userDescription\": \"\(self.txtSellerDescription.text)\", \"Price\": \(self.txtAmount.text), \"PositionInLine\": 0}".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
            
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler: {
            (response:NSURLResponse!, data:NSData!, error:NSError!) -> Void in
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            
            // http://www.binpress.com/tutorial/swiftyjson-how-to-handle-json-in-swift/111
            // https://github.com/lingoer/SwiftyJSON
            // Use swiftyJSON to convert the data string to json then parse.
            
            var json = JSONValue(data)
            
            
            println("Starting JSON dump...")
            var success = json["success"]
            
            println("successful: \(success)")
            
            println("End of JSON dump...")
            
        })
    }

}

