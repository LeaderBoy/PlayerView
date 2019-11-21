//
//  Copyright (C) 2019 杨志远.
//
//  Permission is hereby granted, free of charge, to any person obtaining a 
//  copy of this software and associated documentation files (the "Software"), 
//  to deal in the Software without restriction, including without limitation 
//  the rights to use, copy, modify, merge, publish, distribute, sublicense, 
//  and/or sell copies of the Software, and to permit persons to whom the 
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in 
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
//  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
//  DEALINGS IN THE SOFTWARE.
//
//
//  Animator.swift
//  PlayerView
//
//  Created by 杨志远 on 2019/11/21.
//

import UIKit

class Animator : NSObject {
    var sourceView : UIView
    init(with sourceView : UIView) {
        self.sourceView = sourceView
        super.init()
    }
}


extension Animator : UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let context = TransitionContext(transitionContext)
        
        let isDismiss = context.fromViewController.presentingViewController == context.toViewController
        
        if isDismiss {
            dismissAnimation(context: context)
        }else {
            presentAnimation(context: context)
        }
    }
    
    func presentAnimation(context : TransitionContext) {
        let containerView = context.containerView
        let fromView = context.fromView
        let toView = context.toView
        
        let smallFrame = containerView.convert(sourceView.bounds, from: sourceView)
        print(smallFrame)
        // 将toView 缩小
        toView.bounds = sourceView.bounds
        // 设置位置
        toView.center = CGPoint(x: smallFrame.midX, y: smallFrame.midY)
        // 旋转
        toView.transform = CGAffineTransform(rotationAngle: -(.pi / 2))
        // 添加到视图上
        containerView.addSubview(toView)
        
        let finalFrame = context.transitionContext.finalFrame(for: context.toViewController)
        
        UIView.animate(withDuration: transitionDuration(using: context.transitionContext), animations: {
            toView.transform = CGAffineTransform.identity
            toView.frame = finalFrame
            self.sourceView.frame = finalFrame
        }) { (done) in
            context.transitionContext.completeTransition(true)
        }
    }
    
    func dismissAnimation(context : TransitionContext) {
        context.transitionContext.completeTransition(true)
    }
}
