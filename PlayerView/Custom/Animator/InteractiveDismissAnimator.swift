//
//  Copyright (C) 2020 杨志远.
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
//  InteractiveDismissAnimator.swift
//  PlayerView
//
//  Created by 杨志远 on 2020/1/1.
//

import UIKit

class InteractiveDismissAnimator : NSObject {
    
    enum AnimationOptions {
        case spring
        case liner
    }
    
    unowned var sourceView : UIView
    public let sourceFrame : CGRect
    public var superView : UIView
    private var dismissView : UIView!
    private var context : TransitionContext!
    private var presentedViewController : UIViewController!
    private var presentingViewController : UIViewController!
    
    private var presentingPresentAnimation : PresentAnimation? {
        return presentingViewController as? PresentAnimation
    }
    
    private var presentedPresentAnimation : PresentAnimation? {
        return presentedViewController as? PresentAnimation
    }
    
    private var presentingDismissAnimation : DismissAnimation? {
        return presentingViewController as? DismissAnimation
    }
    
    private var presentedDismissAnimation : DismissAnimation? {
        return presentedViewController as? DismissAnimation
    }

    let animationDuration : TimeInterval = 0.5
    var animationOptions : AnimationOptions
    
    lazy var panGesture: UIPanGestureRecognizer = {
        let gesure = UIPanGestureRecognizer()
        gesure.addTarget(self, action: #selector(panGesureDismiss(_:)))
        return gesure
    }()
    
    init(sourceView : UIView) {
        self.animationOptions = .spring
        self.sourceView = sourceView
        self.sourceFrame = sourceView.convert(sourceView.bounds, to: nil)
        if let superView = sourceView.superview {
            self.superView = superView
        } else {
            fatalError("could not find \(sourceView)'s superView")
        }
        super.init()
    }
    
    convenience init(sourceView : UIView,animationOptions : AnimationOptions) {
        self.init(sourceView : sourceView)
        self.animationOptions = animationOptions
    }
    
    func present(with context : TransitionContext) {
        
        self.context = context
        
        let container = context.containerView
        /// from
        let fromViewController = context.fromTopViewController
        presentingViewController = fromViewController
        presentingPresentAnimation?.presentAnimationWillBegin()
        /// to
        let toViewController = context.toViewController
        let toView = context.toView
        toView.backgroundColor = UIColor(white: 0, alpha: 0)
        toView.addGestureRecognizer(panGesture)
        toView.frame = container.bounds
        container.addSubview(toView)
        presentedViewController = toViewController
        presentedPresentAnimation?.presentAnimationWillBegin()
        
        dismissView = toView
        
        sourceView.removeConstraints()
        sourceView.frame = sourceFrame
        toView.addSubview(sourceView)
                
        let damping : CGFloat =  animationOptions == .spring ? 0.8 : 1

        UIView.animate(withDuration: transitionDuration(using: context.transitionContext), delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: 0.5, options: [.layoutSubviews,.curveEaseIn], animations: {
            self.presentingPresentAnimation?.presentAnimating()
            self.presentedPresentAnimation?.presentAnimating()
            toView.backgroundColor = UIColor(white: 0, alpha: 1)
            self.sourceView.frame = toView.bounds
        }) { (_) in
            context.transitionContext.completeTransition(true)
            self.presentingPresentAnimation?.presentAnimationDidEnd()
            self.presentedPresentAnimation?.presentAnimationDidEnd()
        }
    }
    
    func dismiss(with context : TransitionContext) {
        context.transitionContext.completeTransition(true)
    }
    
    @objc func panGesureDismiss(_ gesure : UIPanGestureRecognizer) {
        let translation = gesure.translation(in: dismissView)
        let velocity = gesure.velocity(in: dismissView)
        
        switch gesure.state {
        case .began:
            presentedDismissAnimation?.dismissWillBegin()
            presentingDismissAnimation?.dismissWillBegin()
            break
        case .changed:
            scale(with: translation)
        case .cancelled,.ended:
            cancelOrEndAnimation(with: translation, velocity: velocity)
        default:
            break
        }
    }
    
    func scale(with translation : CGPoint) {
        let translationX = translation.x
        let translationY = translation.y
        let totalH = dismissView.bounds.height
        let x = abs(translationY) / totalH
        // ax² + bx + c
        let alpha = max(7 * pow(x, 2) - 8 * x + 1, 0)
        
        var percent = 1 - x
        percent = max(percent, 0)
        ///
        let scale = max(percent, 0.3)
        
        let transTransform = CGAffineTransform.init(translationX: translationX / scale, y: translationY / scale)
        let scaleTransform = CGAffineTransform.init(scaleX: scale, y: scale)
        sourceView.transform = transTransform.concatenating(scaleTransform)
        dismissView.backgroundColor = UIColor(white: 0, alpha: alpha)
    }
    
    func cancelOrEndAnimation(with trans : CGPoint,velocity : CGPoint) {
        let offsetY = trans.y
        let velocityY = velocity.y
        if offsetY > 100 || velocityY > 500 {
            endAnimation()
        } else {
            cancelAnimation()
        }
    }
    
    func cancelAnimation() {
        presentedDismissAnimation?.dismissAnimationCanceled()
        presentingDismissAnimation?.dismissAnimationCanceled()
        UIView.animate(withDuration: 0.2) {
            self.dismissView.backgroundColor = UIColor(white: 0, alpha: 1)
            self.sourceView.transform = .identity
        }
    }
    
    func endAnimation() {
        presentedDismissAnimation?.dismissAnimationWillBegin()
        presentingDismissAnimation?.dismissAnimationWillBegin()
        UIView.animate(withDuration: 0.2, delay: 0, options: .layoutSubviews, animations: {
            self.presentedDismissAnimation?.dismissAnimating()
            self.presentingDismissAnimation?.dismissAnimating()
            self.sourceView.transform = .identity
            self.sourceView.frame = self.sourceFrame
        }) { (_) in
            self.sourceView.removeFromSuperview()
            self.superView.addSubview(self.sourceView)
            self.sourceView.edges(to: self.superView)
            self.presentedViewController.dismiss(animated: false) {
                self.presentedDismissAnimation?.dismissAnimationDidEnd()
                self.presentingDismissAnimation?.dismissAnimationDidEnd()
            }
        }
    }
}

extension InteractiveDismissAnimator : UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let context = TransitionContext(transitionContext)
        let isDismiss = context.fromViewController.presentingViewController == context.toViewController
        if isDismiss {
            dismiss(with: context)
        }else {
            present(with: context)
        }
    }
}