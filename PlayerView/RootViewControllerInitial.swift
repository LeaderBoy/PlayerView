//
//  RootViewControllerInitial.swift
//  ZYKit_Swift
//
//  Created by 杨志远 on 2018/3/20.
//  Copyright © 2018年 BaQiWL. All rights reserved.
//

import UIKit
extension AppDelegate {
    func initialRootViewController() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let root = RootTabBarViewController()
        self.window?.rootViewController = root
        self.window?.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.window?.makeKeyAndVisible()
    }
}
