//
//  ViewController.swift
//  swiftexample
//
//  Created by Robert Whelan on 8/15/17.
//  Copyright © 2017 Robert Whelan. All rights reserved.
//

import UIKit
import CoreLocation
import Tune

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager!
    @IBOutlet weak var addToCart: UIButton?
    @IBOutlet weak var initiateCheckout: UIButton?
    @IBOutlet weak var readNFC: UIButton?
    
    @IBAction func addToCart(sender: UIButton) {
        
        NSLog("Add To Cart Pressed!");
        Tune.measureEventName(TUNE_EVENT_ADD_TO_CART)
        
    }
    
    @IBAction func initiateCheckout(sender: UIButton) {
        NSLog("Checkout Initiated")
        Tune.measureEventName(TUNE_EVENT_CHECKOUT_INITIATED)
        
    }
    


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Initialize Location Permissions - Would normally do this in an appropriate point
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    // do stuff
                }
            }
        }
    }


}

