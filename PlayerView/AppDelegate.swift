//
//  AppDelegate.swift
//  PlayerView
//
//  Created by 杨志远 on 2019/11/20.
//  Copyright © 2019 BaQiWL. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        initialRootViewController()
        // Override point for customization after application launch.
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return PlayerUIInterfaceOrientation.shared.current
    }
    
}

