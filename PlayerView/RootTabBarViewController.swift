//
//  RootTabBarViewController.swift
//  ZYKit_Swift
//
//  Created by 杨志远 on 2018/3/20.
//  Copyright © 2018年 BaQiWL. All rights reserved.
//

import UIKit

fileprivate struct TabbarItem {
    var image           : UIImage
    var selectedImage   : UIImage
}

class RootNavigationController: UINavigationController {
    private var themedStatusBarStyle: UIStatusBarStyle?
    
    private var backButton : UIButton?
    
    override func viewDidLoad() {
        navigationBar.isTranslucent = false
    }

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if children.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        
        super.pushViewController(viewController, animated: animated)
    }
}

class RootTabBarViewController: UITabBarController {
    
    fileprivate var items : [TabbarItem] =
        [
            TabbarItem(image: #imageLiteral(resourceName: "tab_play_back"), selectedImage: #imageLiteral(resourceName: "tab_play_back_selected")),
            TabbarItem(image: #imageLiteral(resourceName: "tab_play"), selectedImage: #imageLiteral(resourceName: "tab_play_selected")),
            TabbarItem(image: #imageLiteral(resourceName: "tab_play_forward"), selectedImage: #imageLiteral(resourceName: "tab_play_forward_selected")),
    ]
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
        
    private func createViewControllerSource() -> [UIViewController]{
        let vcs =
            [
                WindowPlanViewController(),
                PresentPlanViewController(),
                UIViewController()
        ]
        return vcs
    }
    
    private func setUp() {
        let vc = createViewControllerSource()
        var viewControllersArray = [UINavigationController]()
        
        for i in 0 ..< vc.count {
            let nav = RootNavigationController(rootViewController: vc[i])
            nav.tabBarItem.image = items[i].image.withRenderingMode(.alwaysOriginal)
            nav.tabBarItem.selectedImage = items[i].selectedImage.withRenderingMode(.alwaysOriginal)
            viewControllersArray.append(nav)
        }
        viewControllers = viewControllersArray
    }
}




extension UITabBarController {
    override open var prefersStatusBarHidden: Bool {
        return self.selectedViewController?.prefersStatusBarHidden ?? false
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.selectedViewController?.preferredStatusBarStyle ?? .default
    }
    
    override open var shouldAutorotate: Bool {
        return self.selectedViewController?.shouldAutorotate ?? false
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return self.selectedViewController?.supportedInterfaceOrientations ?? UIInterfaceOrientationMask.portrait
    }
    
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return self.selectedViewController?.preferredInterfaceOrientationForPresentation ?? UIInterfaceOrientation.portrait
    }
}


extension UINavigationController {
    override open var prefersStatusBarHidden: Bool {
        return self.topViewController?.prefersStatusBarHidden ?? false
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.topViewController?.preferredStatusBarStyle ?? .default
    }
    
    override open var shouldAutorotate: Bool {
        return self.topViewController?.shouldAutorotate ?? false
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return self.topViewController?.supportedInterfaceOrientations ?? UIInterfaceOrientationMask.portrait
    }
    
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return self.topViewController?.preferredInterfaceOrientationForPresentation ?? UIInterfaceOrientation.portrait
    }
    
}
