//
//  TransitionContext.swift
//  OneBlog
//
//  Created by 杨志远 on 2018/10/26.
//  Copyright © 2018 BaQiWL. All rights reserved.
//

import UIKit


public class TransitionContext {
    var transitionContext : UIViewControllerContextTransitioning
    var fromView : UIView
    var toView : UIView
    var fromViewController : UIViewController
    var fromTopViewController : UIViewController
    var toViewController : UIViewController
    var toTopViewController : UIViewController
    var containerView : UIView
    
    init(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        self.fromViewController = transitionContext.viewController(forKey: .from)!
        self.toViewController = transitionContext.viewController(forKey: .to)!
        self.containerView = transitionContext.containerView
        
        self.fromTopViewController = fromViewController.topLevelViewController()
        self.toTopViewController = toViewController.topLevelViewController()
        
        if let fromView = transitionContext.view(forKey: .from) {
            self.fromView = fromView
        }else {
            fromView = fromViewController.view
        }
        
        if let toView = transitionContext.view(forKey: .to) {
            self.toView = toView
        }else {
            self.toView = toViewController.view
        }

    }
}
