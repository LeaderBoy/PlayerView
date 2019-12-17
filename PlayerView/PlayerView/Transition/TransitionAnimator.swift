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
//  TransitionAnimator.swift
//  PlayerView
//
//  Created by 杨志远 on 2019/12/16.
//

import UIKit

class TransitionAnimator : NSObject {
    enum State {
        case animating
        case animated
    }
    
    var sourceView : UIView
    let sourceFrame : CGRect
    var superView : UIView
    
    var isPortrait = true
    var state : State = .animated
    var sourceShotView : UIView!
    
    init(with sourceView : UIView) {
        self.sourceView = sourceView
        self.sourceFrame = sourceView.convert(sourceView.bounds, to: nil)
        self.superView = sourceView.superview!
        
        if let rootView = UIApplication.shared.keyWindow?.rootViewController?.view {
            let view = rootView.snapshotView(afterScreenUpdates: false)
            self.sourceShotView = view
        }
        super.init()
    }
}

protocol PresentAnimation {
    func presentAnimationWillBegin(for animator : Animator)
    func presentAnimationDidBegin(for animator : Animator,complete:@escaping ()->Void)
}

protocol DismissAnimation {
    func dismissAnimationWillBegin(for animator : Animator)
    func dismissAnimationDidBegin(for animator : Animator,complete:@escaping ()->Void)
    func dismissAnimationWillEnd(for animator : Animator)
    func dismissAnimationDidEnd(for animator : Animator)

}

extension PresentAnimation {
    func presentAnimationWillBegin(for animator : Animator){}
    func presentAnimationDidBegin(for animator : Animator,complete:@escaping ()->Void){}
}

extension DismissAnimation {
    func dismissAnimationWillBegin(for animator : Animator){}
    func dismissAnimationDidBegin(for animator : Animator,complete:@escaping ()->Void){}
    func dismissAnimationWillEnd(for animator : Animator){}
    func dismissAnimationDidEnd(for animator : Animator){}
}


extension TransitionAnimator : UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return playerAnimationTime
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
        let toView = context.toView
        let fromView = context.fromView
        

        /// 1.
        /// insert snapshotView as background
        sourceShotView.center = fromView.center
        sourceShotView.transform = .init(rotationAngle: .pi / -2)
        sourceShotView.frame = containerView.bounds
        containerView.addSubview(sourceShotView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.016) {
            /// 2.
            /// setup fromView's transform
            /// thought system already setup this
            fromView.frame = containerView.bounds
            fromView.transform = .init(rotationAngle: .pi / -2)
            /// 3.
            /// add toView
            toView.frame = containerView.bounds
            containerView.addSubview(toView)
            /// 4.
            /// create a new view as playerView's container
            let playerContainer = UIView()
            playerContainer.tag = 9991
            toView.addSubview(playerContainer)
            let newCenter   = CGPoint(x: self.sourceFrame.midY, y: self.sourceFrame.midX)
            playerContainer.frame    = self.sourceFrame
            playerContainer.center   = newCenter
            playerContainer.transform = .init(rotationAngle: .pi / -2)
            /// 5.
            /// remove all playerView's contraints
            self.sourceView.removeFromSuperview()
            self.sourceView.removeConstraints()
            playerContainer.addSubview(self.sourceView)
            self.sourceView.edges(to: playerContainer)
            self.sourceView.removeLayerAnimation()
            playerContainer.layoutIfNeeded()
            /// 6.
            /// animating
            let w = toView.bounds.width
            let h = toView.bounds.height
            let center = toView.center

            UIView.animate(withDuration: self.transitionDuration(using: context.transitionContext), delay: 0, options: .layoutSubviews, animations: {
                let newFrame = CGRect(x: 0, y: 0, width: h, height: w)
                playerContainer.frame = newFrame
                playerContainer.center = center
                playerContainer.transform = .identity
                fromView.layoutIfNeeded()
            }) { (_) in
                context.transitionContext.completeTransition(true)
            }
        }
    }
    
    func dismissAnimation(context : TransitionContext) {
        let containerView = context.containerView
        let fromView = context.fromView
        let toView = context.toView

        /// 1.
        /// snapshotView should transform identity
        sourceShotView.center = toView.center
        sourceShotView.transform = .identity
        sourceShotView.frame = containerView.bounds
        /// 2.
        /// toView and fromView should rotate to satisfy safearea change immediately
        /// this step is very important otherwise safearea will not work properly
        toView.transform = .identity
        toView.frame = containerView.bounds
        fromView.transform = .identity
        fromView.frame = containerView.bounds
        /// 3.
        /// player stay in current orientation should also rotate
        let playerContainer = fromView.viewWithTag(9991)!
        playerContainer.center = fromView.center
        playerContainer.transform = .init(rotationAngle: .pi / 2)
        /// 4.
        /// animating
        UIView.animate(withDuration: transitionDuration(using: context.transitionContext), delay: 0, options:.layoutSubviews, animations: {
            playerContainer.center = CGPoint(x: self.sourceFrame.midX, y: self.sourceFrame.midY)
            playerContainer.transform = .identity
            playerContainer.frame = self.sourceFrame
        }) { (_) in
            fromView.transform = .init(rotationAngle: .pi / 2)
            self.sourceShotView.removeFromSuperview()
            let superView = self.superView
            self.sourceView.removeFromSuperview()
            self.sourceView.removeConstraints()
            superView.addSubview(self.sourceView)
            self.sourceView.edges(to: superView)
            superView.layoutIfNeeded()
            playerContainer.removeFromSuperview()
            context.transitionContext.completeTransition(true)
        }
    }
        
    func swap(size : CGSize) -> CGSize {
        let newSize = CGSize(width: size.height, height: size.width)
        return newSize
    }
    
    func swap(rect : CGRect) -> CGRect {
        let newRect = CGRect(x: rect.minY, y: rect.minX, width: rect.height, height: rect.width)
        return newRect
    }
    
    
}

extension UIView {
    func remakeConstraint(offsetX : CGFloat,offsetY : CGFloat,width : CGFloat,height : CGFloat) {
        removeConstraints()
        if let superView = self.superview {
            NSLayoutConstraint.activate([
                self.centerXAnchor.constraint(equalTo: superView.centerXAnchor, constant: offsetX),
                self.centerYAnchor.constraint(equalTo: superView.centerYAnchor, constant: offsetY),
                self.widthAnchor.constraint(equalToConstant: width),
                self.heightAnchor.constraint(equalToConstant: height)
            ])
        }
    }
}

