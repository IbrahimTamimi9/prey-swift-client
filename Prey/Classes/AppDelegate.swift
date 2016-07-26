//
//  AppDelegate.swift
//  Prey
//
//  Created by Javier Cala Uribe on 5/8/14.
//  Copyright (c) 2014 Fork Ltd. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: Properties
    
    var window: UIWindow?

    // MARK: UIApplicationDelegate
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Config Google Analytics
        GAI.sharedInstance().trackerWithTrackingId(GAICode)
        GAI.sharedInstance().trackUncaughtExceptions                = true
        GAI.sharedInstance().dispatchInterval                       = 120
        GAI.sharedInstance().logger.logLevel                        = GAILogLevel.None
        GAI.sharedInstance().defaultTracker.allowIDFACollection     = true

        
        // Check notification_id with server
        if PreyConfig.sharedInstance.isRegistered {
            PreyNotification.sharedInstance.registerForRemoteNotifications()
        } else {
            PreyDeployment.sharedInstance.runPreyDeployment()
        }
        
        // Check CLRegion In/Out
        if let locationLaunch = launchOptions?[UIApplicationLaunchOptionsLocationKey] {
            PreyLogger("Prey Geofence received while not running: \(locationLaunch)")
            GeofencingManager.sharedInstance
        }
 
        // Check user is Pro
        if PreyConfig.sharedInstance.isPro {
            // Init geofencing region
            GeofencingManager.sharedInstance
        }
        
        // Config init UIViewController
        self.window                         = UIWindow(frame: UIScreen.mainScreen().bounds)
        let mainStoryboard: UIStoryboard    = UIStoryboard(name:StoryboardIdVC.PreyStoryBoard.rawValue, bundle: nil)
        let rootVC: UINavigationController  = mainStoryboard.instantiateViewControllerWithIdentifier(StoryboardIdVC.navigation.rawValue) as! UINavigationController
        let controller: UIViewController    = (PreyConfig.sharedInstance.isRegistered) ? mainStoryboard.instantiateViewControllerWithIdentifier(StoryboardIdVC.home.rawValue) :
                                                                                         mainStoryboard.instantiateViewControllerWithIdentifier(StoryboardIdVC.welcome.rawValue)
        
        rootVC.pushViewController(controller, animated:false)
        
        self.window?.rootViewController = rootVC
        self.window?.makeKeyAndVisible()
        
        // Config UINavigationBar
        PreyConfig.sharedInstance.configNavigationBar()
        
        return true
    }    
    
    func applicationWillResignActive(application: UIApplication) {
        
        // Hide mainView for multitasking preview
        let backgroundImg   = UIImageView(image:UIImage(named:"BgWelcome"))
        backgroundImg.frame = UIScreen.mainScreen().bounds
        backgroundImg.alpha = 0
        backgroundImg.tag   = 1985
        
        window?.addSubview(backgroundImg)
        window?.bringSubviewToFront(backgroundImg)
        
        UIView.animateWithDuration(0.5, animations:{() in backgroundImg.alpha = 1.0})
        
    }

    func applicationDidEnterBackground(application: UIApplication) {
        PreyLogger("Prey is in background")
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {

        // Show mainView
        let backgroundImg   = window?.viewWithTag(1985)
        
        UIView.animateWithDuration(0.5, animations:{() in backgroundImg?.alpha = 0},
                                   completion:{(Bool)  in backgroundImg?.removeFromSuperview()})
    }

    func applicationWillTerminate(application: UIApplication) {
    }
    
    // MARK: Notification
    
    // Did register notifications
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        PreyNotification.sharedInstance.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken)
    }
    
    // Fail register notifications
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        PreyLogger("Error Register Notification: \(error)")
    }
    
    // Did receive remote notification
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        PreyNotification.sharedInstance.didReceiveRemoteNotifications(userInfo, completionHandler:completionHandler)
    }
    
    // Did receiveLocalNotification
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        PreyLogger("Local notification received")
    }
}

