//
//  AppDelegate.swift
//  swiftexample
//
//  Created by Robert Whelan on 8/15/17.
//  Copyright © 2017 Robert Whelan. All rights reserved.
//

import UIKit
import Tune
import AdSupport
import CoreSpotlight
import CoreTelephony
import iAd
import MobileCoreServices
import QuartzCore
import Security
import StoreKit
import SystemConfiguration
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var lastEvent: SWNotification?
    var currentEvent: SWNotification?
    var action: SWAction?
    var smartwhere: SmartWhere!
    
    

    let Tune_Advertiser_Id   = "your Tune Advertiser ID"
    let Tune_Conversion_Key  = "your Tune Conversion Key"
    let Tune_Package_Name = "your Package Name - should match Tune TMC settings"


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Initialize UserNotifications
        //
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (permissionGranted, error) in
                print(error as Any)
            }
             UNUserNotificationCenter.current().delegate = self
        } else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
            
        }
                
        // Note: to set self as the delegate, this class needs to implement the TuneDelegate protocol
        Tune.setDelegate(self)
        
        // call one of the Tune init methods
        Tune.initialize(withTuneAdvertiserId: Tune_Advertiser_Id, tuneConversionKey: Tune_Conversion_Key, tunePackageName: Tune_Package_Name, wearable: false)
        
        
        // Note: only for debugging
        Tune.setDebugMode(true)
        
        // Register this class as a deeplink listener to handle deferred deeplinks and Tune Universal Links.
        // This class must conform to the TuneDelegate protocol, implementing the tuneDidReceiveDeeplink: and tuneDidFailDeeplinkWithError: callbacks.
        
        Tune.registerDeeplinkListener(self)
        
        // Uncomment this line to enable auto-measurement of successful in-app-purchase (IAP) transactions as "purchase" events
        //[Tune automateIapEventMeasurement:YES];
        
        
        // Check if a deferred deeplink is available and handle opening of the deeplink as appropriate in the success tuneDidReceiveDeeplink: callback.
        // Uncomment this line if your TUNE account has enabled deferred deeplinks
        //Tune.checkForDeferredDeeplink(self)
        
        // Uncomment this line to enable auto-measurement of successful in-app-purchase (IAP) transactions as "purchase" events
        //Tune.automateIapEventMeasurement(true)
        
        // Enable Smartwhere Proximity functionality
        Tune.enableSmartwhereIntegration()
        // Enable Mapped Events
        Tune.configureSmartwhereIntegration(withOptions: Int(TuneSmartwhereShareEventData.rawValue))
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        Tune.measureSession()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        // when the app is opened due to a deep link, call the Tune deep link setter
        //Tune.handleOpenURL(url, sourceApplication: sourceApplication)
        
        return true;
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        
        smartwhere = TuneSmartWhereHelper.getInstance().getSmartWhere() as! SmartWhere
        
        currentEvent = smartwhere.didReceiveLocalNotificationSW(notification)
        if (currentEvent != nil) {
            smartWhere(smartwhere, didReceiveLocalNotification: currentEvent!)
        }
        
        
    }
    
    //MARK - UNNotification Delegate Methods
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        smartwhere = TuneSmartWhereHelper.getInstance().getSmartWhere() as! SmartWhere
        if (!smartwhere.didReceive(response)) {
            // Error
        }
        NSLog("User Info : %",response.notification.request.content.userInfo)
        completionHandler()
    }
    
    
    


}

extension AppDelegate:SmartWhereDelegate {
    func smartWhere(_ smartwhere: SmartWhere, didReceiveLocalNotification notification: SWNotification) {
        NSLog("SWNotification came in while in the foreground, alerting the user");
        lastEvent = notification
        
        let alertController = UIAlertController(title: notification.title, message: notification.message, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (result : UIAlertAction) -> Void in
            //action when pressed button
        }
        let okAction = UIAlertAction(title: "Okay", style: .default) { (result : UIAlertAction) -> Void in
            //action when pressed button
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
        
        
    }
    
}

extension AppDelegate:TuneDelegate {
    func tuneDidSucceed(with data: Data!) {
        //let str = String(data: data, encoding: String.Encoding.utf8)
        print("Tune success:")
    }
    
    func tuneDidFailWithError(_ error: Error!) {
        print("Tune failed: \(error)")
    }
    
    func tuneEnqueuedRequest(_ url: String!, postData post: String!) {
        print("Tune request enqueued: \(url), post data = \(post)")
    }
}

