//
//  AppDelegate.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/16/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    //--------------------------------------------------
    // MARK: - UIApplicationDelegate
    //--------------------------------------------------
    
    var window: UIWindow?
    
    /*
        Allow offline data persistance for firebase when application initializes
     */
    override init() {
        super.init()
        Firebase.defaultConfig().persistenceEnabled = true
    }
    
    func application(application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        if let font = UIFont(name: NAVBAR_FONT, size: BAR_BUTTON_FONT_SIZE) {
            UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
        }
        
            return FBSDKApplicationDelegate.sharedInstance()
                .application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
        //This starts updates in order to grab user Location
        let _ = UserLocation.userLocation
    }
    func application(application: UIApplication, openURL url: NSURL,
        sourceApplication: String?, annotation: AnyObject) -> Bool {
            return FBSDKApplicationDelegate.sharedInstance()
                .application(application, openURL: url,
                    sourceApplication: sourceApplication, annotation: annotation)
    }
}

