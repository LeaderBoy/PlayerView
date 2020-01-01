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

/// present and dismiss animation duration
public let playerTransitionDuration : TimeInterval = 0.5

class Animator : NSObject {
    enum State {
        case animating
        case animated
    }
    
    public unowned var sourceView : UIView
    public var plan : Plan
    public let sourceFrame : CGRect
    public var superView : UIView
    public var sourceShotView : UIView!
    public var keyView : UIView
    public var keyWindow : UIWindow!
    public var state : State = .animated
    public var mode : PlayerModeState = .portrait
    /// before full screen
    /// the orientation of the device will rotate to
    public var aimOrientation : UIInterfaceOrientationMask?
    
    fileprivate let flashTime : TimeInterval = 0.02
    fileprivate let portraitSnapshotViewTag = 9991
    fileprivate let windowDismissSnapshotViewTag = 9992
    fileprivate let playerContrainerTag = 9993
    
    typealias Completed = (()->Void)?
    
    fileprivate lazy var lanVC : PlayerViewController = {
        let vc = PlayerViewController()
        if plan == .present {
            vc.transitioningDelegate = transition
            vc.modalPresentationStyle = .overFullScreen
        }
        return vc
    }()
    
    fileprivate lazy var destinationView : UIView = {
        return lanVC.view
    }()

    /// Present Plan
    public lazy var transition: Transition = {
        let t = Transition()
        t.animator = self
        return t
    }()
        
    /// Window Plan
    fileprivate lazy var lanWindow : UIWindow = {
        let size = UIScreen.main.bounds.size
        let window = UIWindow(frame: CGRect(origin: .zero, size: CGSize(width: size.height, height: size.width)))
        window.windowLevel = .statusBar
        window.backgroundColor = .clear
        window.rootViewController = lanVC
        return window
    }()

    init(with sourceView : UIView,plan : Plan) {
        self.sourceView = sourceView
        self.plan = plan
        self.sourceFrame = sourceView.convert(sourceView.bounds, to: nil)
        if let superView = sourceView.superview {
            self.superView = superView
        } else {
            fatalError("could not find playerView's superView")
        }
        
        var keyWindow : UIWindow?
        
        if #available(iOS 13.0, *) {
            keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        } else {
            keyWindow = UIApplication.shared.keyWindow
        }
        
        if let window = keyWindow,let rootView = window.rootViewController?.view {
            let view = rootView.snapshotView(afterScreenUpdates: false)
            self.sourceShotView = view
            self.keyWindow = window
            self.keyView = rootView
        } else {
            fatalError("key window not found")
        }
        
        super.init()
    }
    
    func present(animated : Bool,completed:Completed = nil) {
        if state == .animating || mode == .landscape {
            return
        }
        switch plan {
        case .window:
            windowPresent(animated: animated, completed: completed)
        case .present:
            controllerPresent(animated: animated, completed: completed)
        }
    }
    
    func dismiss(animated:Bool,completed:Completed = nil) {
        if state == .animating || mode == .portrait {
            return
        }
        
        switch plan {
        case .window:
            windowDismiss(animated: animated, completed: completed)
        case .present:
            controllerDismiss(animated: animated, completed: completed)
        }
    }
    
    fileprivate func windowPresent(animated : Bool,completed:Completed = nil) {
        windowPresentBegin(animated: animated, completed: completed)
    }
    
    fileprivate func windowDismiss(animated : Bool,completed:Completed = nil) {
        windowDismissBegin(animated: animated, completed: completed)
    }
    
    fileprivate func controllerPresent(animated : Bool,completed:Completed = nil) {
        insertSnapshotViewForKeyView()
        if let top = keyWindow.rootViewController?.topLevelViewController() {
            top.present(lanVC, animated: animated, completion: completed)
        }else {
            print("Warn : present failed,could not find the most top viewcontroller")
        }
    }
    
    fileprivate func controllerDismiss(animated : Bool,completed:Completed = nil) {
        lanVC.dismiss(animated: animated, completion: completed)
    }
}

extension Animator {
    /// insert SnapshotView as background
    fileprivate func insertSnapshotViewForKeyView() {
        sourceShotView.frame = keyView.bounds
        keyView.addSubview(sourceShotView)
    }
    
    fileprivate func removeSnapshotViewForKeyView() {
        sourceShotView.removeFromSuperview()
    }
}

// MARK: - Window
extension Animator {
    // MARK: - Application
    func windowDismissInsertTempSnapshotView() {
        if let snapshotView = lanVC.view.snapshotView(afterScreenUpdates: true) {
            snapshotView.tag = portraitSnapshotViewTag
            snapshotView.frame = sourceView.frame
            snapshotView.center = keyWindow.center
            snapshotView.transform = .init(rotationAngle: .pi / 2)
            keyView.addSubview(snapshotView)
            keyView.bringSubviewToFront(snapshotView)
        }
    }

    func windowDismissRemoveTempSnapshotView() {
        let view = keyWindow.viewWithTag(portraitSnapshotViewTag)
        view?.removeFromSuperview()
    }
    
    // MARK: - Present
    /// 2.
    ///
    func windowPresentBegin(animated : Bool,completed:Completed = nil) {
        
        self.state = .animating
        self.mode = .landscape
        /// 1.
        insertSnapshotViewForKeyView()
        /// 2.
        /// remove from old superView and move to new superView
        sourceView.removeConstraints()
        
        if let aim = aimOrientation,aim == .landscapeLeft {
            let width = lanWindow.bounds.width
            let height = lanWindow.bounds.height
        
            sourceView.frame = CGRect(x:sourceFrame.origin.y, y:sourceFrame.origin.x, width: sourceFrame.width, height: sourceFrame.height)
            sourceView.center = CGPoint(x: width - sourceFrame.midY, y: height - sourceFrame.midX)
            sourceView.transform = .init(rotationAngle:  .pi / 2.0)
        } else {
            sourceView.frame = CGRect(x: sourceFrame.origin.y, y: sourceFrame.origin.x, width: sourceFrame.width, height: sourceFrame.height)
            sourceView.center = CGPoint(x: sourceFrame.midY, y: sourceFrame.midX)
            sourceView.transform = .init(rotationAngle: .pi / -2)
        }
        /// apply superView's configuation
        sourceView.layer.cornerRadius = superView.layer.cornerRadius
        sourceView.layer.masksToBounds = superView.layer.masksToBounds
        destinationView.addSubview(sourceView)

        let complete = {
            self.removeSnapshotViewForKeyView()
            self.windowPresentAnimating(animated: animated, completed: completed)
        }

        lanWindow.makeKeyAndVisible()

        /// 3. animating
        if animated {
            lanWindow.alpha = 0
            /// When sourceView removeFromSuperView and add to destinationView,view will flash
            /// so I add an fade animation to prevent the flash
            UIView.animate(withDuration: flashTime, animations: {
                self.lanWindow.alpha = 1
            }) { (_) in
                complete()
            }
        }else {
            complete()
        }
    }
    
    /// 3.
    /// present animation
    func windowPresentAnimating(animated : Bool,completed: Completed = nil) {
        let width   = lanWindow.bounds.size.width
        let height  = lanWindow.bounds.size.height
        
        let sourceView = self.sourceView
        
        let change = {
            sourceView.center = CGPoint(x: height / 2.0, y: width / 2.0)
            sourceView.transform = .identity
            let newFrame = CGRect(x: 0, y: 0, width: width, height: height)
            sourceView.frame = newFrame
            sourceView.layer.cornerRadius = 0
        }
        
        let complete = {
            self.mode = .landscape
            self.state = .animated
            completed?()
        }

        if animated {
            UIView.animate(withDuration: playerTransitionDuration, delay: 0, options: .layoutSubviews, animations: {
                change()
            }) { (_) in
                complete()
            }
        } else {
            change()
            complete()
        }
    }
    
    // MARK: - Dismiss
    /// 1.
    /// insert snapshotView to prevent flash
    fileprivate func windowDismissInsertSnapshotView() {
        if let snap = destinationView.snapshotView(afterScreenUpdates: true) {
            snap.tag = windowDismissSnapshotViewTag
            destinationView.insertSubview(snap, at: 0)
        }
    }
    
    fileprivate func windowDismissRemoveSnapshotView() {
        if let snap = destinationView.viewWithTag(windowDismissSnapshotViewTag) {
            snap.removeFromSuperview()
        }
    }
    
    // Dismiss from fullScreen view
    fileprivate func windowDismissBegin(animated : Bool = true,completed:Completed = nil) {

        self.state = .animating
        self.mode = .portrait
        /// insert snapshotview as background
        /// when exit app snapshotView will be nil
        windowDismissInsertSnapshotView()
        
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        
        if let aim = aimOrientation,aim == .landscapeLeft {
            sourceView.transform = .init(rotationAngle: .pi / -2)
            sourceView.center = CGPoint(x: height / 2.0, y: width / 2.0)
        } else {
            sourceView.transform = .init(rotationAngle: .pi / 2)
            sourceView.center = CGPoint(x: height / 2.0, y: width / 2.0)
        }
        
        sourceView.removeLayerAnimation()
        keyView.addSubview(sourceView)
                
        let change = {
            self.lanWindow.alpha = 0
        }
        
        let complete = {
            /// 1. when in landscape
            /// 2. exit the app
            /// 3. and in
            /// UITableView will be scaled
            /// so use makeKeyAndVisible and layoutIfNeeded to fix that problem
            self.keyWindow.makeKeyAndVisible()
            self.keyView.layoutIfNeeded()
            self.lanWindow.isHidden = true
            self.lanWindow.alpha = 1.0
            self.windowDismissRemoveSnapshotView()
            self.windowDismissAnimating(animated: animated, completed: completed)
        }

        if animated {
            /// when sourceView removeFromSuperView and add to keyView,view will flash
            /// so I add an fade animation to prevent the flash
            UIView.animate(withDuration: flashTime, animations: {
                change()
            }) { (_) in
                complete()
            }
        } else {
            complete()
        }
    }

    fileprivate func windowDismissAnimating(animated : Bool,completed:Completed = nil) {
        
        let sourceView = self.sourceView
        
        let sourceFrame = self.sourceFrame
        let superView = self.superView
        
        let change = {
            sourceView.frame = CGRect(x: sourceFrame.origin.x, y: sourceFrame.origin.y, width: sourceFrame.height, height: sourceFrame.width)
            sourceView.center = CGPoint(x: sourceFrame.midX, y: sourceFrame.midY)
            sourceView.transform = .identity
            sourceView.layer.cornerRadius = superView.layer.cornerRadius
            sourceView.layer.masksToBounds = false
        }
        
        let complete = {
            superView.addSubview(sourceView)
            sourceView.transform = .identity
            sourceView.edges(to: superView)
            sourceView.layer.cornerRadius = 0
            superView.layoutIfNeeded()
            self.state = .animated
            self.mode = .portrait
            completed?()
        }

        if animated {
            UIView.animate(withDuration: playerTransitionDuration, delay: 0, options:.layoutSubviews, animations: {
                change()
            }) { (_) in
                complete()
            }
        } else {
            change()
            complete()
        }
    }
}

// MARK: - Present
// MARK: - UIViewControllerAnimatedTransitioning
extension Animator : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return playerTransitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let context = TransitionContext(transitionContext)
        let isDismiss = context.fromViewController.presentingViewController == context.toViewController
        if isDismiss {
            controllerDismissAnimation(context: context)
        }else {
            controllerPresentAnimation(context: context)
        }
    }
    
    fileprivate func controllerPresentAnimation(context : TransitionContext) {
        state = .animating
        mode = .landscape
        
        let containerView = context.containerView
        let toView = context.toView
        /// 2.
        /// add toView
        toView.frame = containerView.bounds
        containerView.addSubview(toView)
        /// 3.
        /// create a new view as playerView's container
        let playerContainer = UIView()
        playerContainer.tag = playerContrainerTag
        toView.addSubview(playerContainer)
                
        if let aim = aimOrientation,aim == .landscapeLeft {
            let width = containerView.bounds.width
            let height = containerView.bounds.height
            let newCenter   = CGPoint(x: width - self.sourceFrame.midY, y: height -  self.sourceFrame.midX)
            playerContainer.frame    = self.sourceFrame
            playerContainer.center   = newCenter
            playerContainer.transform = .init(rotationAngle: .pi / 2)
        } else {
            let newCenter   = CGPoint(x: self.sourceFrame.midY, y: self.sourceFrame.midX)
            playerContainer.frame    = self.sourceFrame
            playerContainer.center   = newCenter
            playerContainer.transform = .init(rotationAngle: .pi / -2)
        }
        
        /// 5.
        /// remove all playerView's contraints
        sourceView.removeFromSuperview()
        sourceView.removeConstraints()
        playerContainer.addSubview(sourceView)
        sourceView.edges(to: playerContainer)
        sourceView.removeLayerAnimation()
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
        }) { (_) in
            self.state = .animated
            context.transitionContext.completeTransition(true)
        }
    }
    
    fileprivate func controllerDismissAnimation(context : TransitionContext) {
        
        let sourceView = self.sourceView
        
        state = .animating
        mode = .portrait
        
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
        let playerContainer = fromView.viewWithTag(playerContrainerTag)!
        playerContainer.center = fromView.center
        if let aim = aimOrientation,aim == .landscapeLeft {
            playerContainer.transform = .init(rotationAngle: .pi / -2)
        } else {
            playerContainer.transform = .init(rotationAngle: .pi / 2)
        }
        /// 4.
        /// animating
        UIView.animate(withDuration: transitionDuration(using: context.transitionContext), delay: 0, options:.layoutSubviews, animations: {
            playerContainer.center = CGPoint(x: self.sourceFrame.midX, y: self.sourceFrame.midY)
            playerContainer.transform = .identity
            playerContainer.frame = self.sourceFrame
        }) { (_) in
            fromView.transform = .init(rotationAngle: .pi / 2)
            self.removeSnapshotViewForKeyView()
            let superView = self.superView
            sourceView.removeFromSuperview()
            sourceView.removeConstraints()
            superView.addSubview(sourceView)
            sourceView.edges(to: superView)
            superView.layoutIfNeeded()
            playerContainer.removeFromSuperview()
            self.state = .animated
            context.transitionContext.completeTransition(true)
        }
    }
}



protocol PresentAnimation {
    func presentAnimationWillBegin()
    func presentAnimating()
    func presentAnimationDidEnd()
}

protocol DismissAnimation {
    func dismissAnimationWillBegin()
    func dismissAnimating()
    func dismissAnimationCanceled()
    func dismissAnimationDidEnd()
}

extension PresentAnimation {
    func presentAnimationWillBegin(){}
    func presentAnimating(){}
    func presentAnimationDidEnd(){}
}

extension DismissAnimation {
    func dismissAnimationWillBegin(){}
    func dismissAnimating(){}
    func dismissAnimationCanceled(){}
    func dismissAnimationDidEnd(){}
}
