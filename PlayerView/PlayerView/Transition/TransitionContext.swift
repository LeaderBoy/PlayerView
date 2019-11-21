//
//  TransitionContext.swift
//  OneBlog
//
//  Created by 杨志远 on 2018/10/26.
//  Copyright © 2018 BaQiWL. All rights reserved.
//

import UIKit


class TransitionContext {
    var transitionContext : UIViewControllerContextTransitioning
    var fromView : UIView
    var toView : UIView
    var fromViewController : UIViewController
    var toViewController : UIViewController
    var containerView : UIView
    
    init(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        self.fromViewController = transitionContext.viewController(forKey: .from)!
        self.toViewController = transitionContext.viewController(forKey: .to)!
        self.containerView = transitionContext.containerView
        self.fromView = transitionContext.view(forKey: .from)!
        self.toView = transitionContext.view(forKey: .to)!
    }
}
