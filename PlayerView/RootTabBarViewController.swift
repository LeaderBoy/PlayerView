//
//  RootTabBarViewController.swift
//  ZYKit_Swift
//
//  Created by 杨志远 on 2018/3/20.
//  Copyright © 2018年 BaQiWL. All rights reserved.
//

import UIKit

fileprivate struct TabbarItem {
    var title           : String
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
            TabbarItem(title: "Window", image: #imageLiteral(resourceName: "tab_play_back"), selectedImage: #imageLiteral(resourceName: "tab_play_back_selected")),
            TabbarItem(title: "Present",image: #imageLiteral(resourceName: "tab_play"), selectedImage: #imageLiteral(resourceName: "tab_play_selected")),
            TabbarItem(title: "Custom",image: #imageLiteral(resourceName: "tab_play_forward"), selectedImage: #imageLiteral(resourceName: "tab_play_forward_selected")),
            TabbarItem(title: "Image",image: #imageLiteral(resourceName: "tab_play_forward"), selectedImage: #imageLiteral(resourceName: "tab_play_forward_selected")),

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
                CollectionViewController(),
                ImageViewController()
        ]
        return vcs
    }
    
    private func setUp() {
        let vcs = createViewControllerSource()
        var viewControllersArray = [UINavigationController]()
        
        for (index,value) in vcs.enumerated() {
            let nav = RootNavigationController(rootViewController: value)
            value.navigationItem.title = items[index].title
            nav.tabBarItem.title = items[index].title
            nav.tabBarItem.image = items[index].image.withRenderingMode(.alwaysOriginal)
            nav.tabBarItem.selectedImage = items[index].selectedImage.withRenderingMode(.alwaysOriginal)
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
        return self.selectedViewController?.shouldAutorotate ?? true
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return self.selectedViewController?.supportedInterfaceOrientations ?? UIInterfaceOrientationMask.portrait
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
        return self.topViewController?.shouldAutorotate ?? true
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return self.topViewController?.supportedInterfaceOrientations ?? UIInterfaceOrientationMask.portrait
    }
    
}



extension UIViewController {
    @objc fileprivate func overrideDefaultSupportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .portrait
    }
    
    @discardableResult
    static func overrideSupportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if let orientations = class_getInstanceMethod(self, #selector(getter: supportedInterfaceOrientations)),let resetDefaultOrientations = class_getInstanceMethod(self, #selector(overrideDefaultSupportedInterfaceOrientations)) {
            method_exchangeImplementations(orientations, resetDefaultOrientations)
        }
        return .allButUpsideDown
    }
}
