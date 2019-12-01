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

let playerAnimationTime : TimeInterval =   0.5

class Animator : NSObject {
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
    func dismissAnimationDidBegin(for animator : Animator,animating: (()->Void)?,complete:@escaping ()->Void)
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


extension Animator : UIViewControllerAnimatedTransitioning {
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
        let toViewController = context.toViewController
        let toView = context.toView
        
        let fromView = context.fromView
        fromView.isHidden = true
        fromView.frame = containerView.bounds
        fromView.transform = .init(rotationAngle: .pi / -2)
    
        sourceShotView.center = fromView.center
        sourceShotView.transform = .init(rotationAngle: .pi / -2)
        sourceShotView.frame = containerView.bounds
        containerView.addSubview(sourceShotView)
        

        toView.frame = containerView.bounds
        containerView.addSubview(toView)

        if let animation = toViewController as? PresentAnimation {
            animation.presentAnimationWillBegin(for: self)
            animation.presentAnimationDidBegin(for: self) {
                fromView.isHidden = false
                fromView.transform = .identity
                context.transitionContext.completeTransition(true)
            }
        }
    }
    
    func dismissAnimation(context : TransitionContext) {
        let containerView = context.containerView
        let fromViewController = context.fromViewController
        let fromView = context.fromView
        let fromAnimation = fromViewController as? DismissAnimation
        
        let toViewController = context.toViewController
        let toView = context.toView
        let toAnimation = toViewController as? DismissAnimation
        
        
        sourceShotView.center = toView.center
        sourceShotView.transform = .identity
        sourceShotView.frame = containerView.bounds
        containerView.insertSubview(toView, at: 0)
        
        toView.transform = .identity
        toView.frame = containerView.bounds
        
        fromView.transform = .identity
        fromView.frame = containerView.bounds
                        
        fromAnimation?.dismissAnimationWillBegin(for: self)
        fromAnimation?.dismissAnimationDidBegin(for: self) {
            fromView.transform = .init(rotationAngle: .pi / 2)
            fromView.removeFromSuperview()
            fromAnimation?.dismissAnimationWillEnd(for: self)
            toAnimation?.dismissAnimationWillEnd(for: self)
            self.sourceShotView.removeFromSuperview()
            context.transitionContext.completeTransition(true)
            fromAnimation?.dismissAnimationDidEnd(for: self)
            toAnimation?.dismissAnimationDidEnd(for: self)
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
