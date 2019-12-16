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

public let playerAnimationTime : TimeInterval =   0.5


class Animator : NSObject {
    enum State {
        case animating
        case animated
    }

    weak var sourceView : UIView?
    var sourceFrame : CGRect
    var superView : UIView
    var keyView : UIView
    var sourceShotView : UIView!
    var keyWindow : UIWindow!
    var flashTime : TimeInterval = 0.02

    private let lanVC = PlayerViewController()

    private var destinationView : UIView {
        return lanVC.view
    }

    var lanWindow : UIWindow = {
        let size = UIScreen.main.bounds.size
        let window = UIWindow(frame: CGRect(origin: .zero, size: CGSize(width: size.height, height: size.width)))
        window.windowLevel = .statusBar
        window.backgroundColor = .clear
        return window
    }()

    var state : State = .animated
    var mode : PlayerModeState = .portrait

    init(with sourceView : UIView) {
        self.sourceView = sourceView
        self.sourceFrame = sourceView.convert(sourceView.bounds, to: nil)
        self.superView = sourceView.superview!
        if let w = UIApplication.shared.keyWindow,let rootView = w.rootViewController?.view {
            keyWindow = w
            keyView = rootView
            let view = rootView.snapshotView(afterScreenUpdates: false)
            self.sourceShotView = view
        }else {
            fatalError("keyWindow not exist")
        }
        lanWindow.rootViewController = lanVC

        super.init()
    }

    /// update frame superView and snapshotView
    /// - Parameter sourceView: player view
    func update(sourceView : UIView) {
        self.sourceView = sourceView
        self.sourceFrame = sourceView.convert(sourceView.bounds, to: nil)
        self.superView = sourceView.superview!
        if let rootView = UIApplication.shared.keyWindow?.rootViewController?.view {
            keyView = rootView
            let view = rootView.snapshotView(afterScreenUpdates: false)
            self.sourceShotView = view
        }else {
            fatalError("keyWindow not exist")
        }
    }

    func captureSnapshotView() -> UIView? {
        if let snapshotView = lanVC.view.snapshotView(afterScreenUpdates: true) {
            return snapshotView
        }
        return nil
    }

    func insertSnapshotView() {
        if let snapshotView = captureSnapshotView() {
            snapshotView.tag = 999
            snapshotView.frame = sourceView!.frame
            snapshotView.center = keyWindow.center
            snapshotView.transform = .init(rotationAngle: .pi / 2)
            keyWindow.addSubview(snapshotView)
            keyWindow.bringSubviewToFront(snapshotView)
        }
    }

    func removeSnapshotView() {
        let view = keyWindow.viewWithTag(999)
        view?.removeFromSuperview()
    }

    /// Present fullScreen view
    func present(animated : Bool = true) {
        presentWillBegin(animated: animated)
    }

    // Dismiss from fullScreen view
    func dismiss(animated : Bool = true) {
        dismissWillBegin(animated: animated)
    }

    func presentWillBegin(animated : Bool) {
        /// To prevent multiple calls
        if state == .animating {
            return
        }

        if mode == .landscape {
            return
        }

        guard let sourceView = self.sourceView else { return }

        /// insert snapshotview as background
        keyView.addSubview(sourceShotView)

        sourceView.removeConstraints()
        sourceView.frame = CGRect(x: sourceFrame.origin.y, y: sourceFrame.origin.x, width: sourceFrame.width, height: sourceFrame.height)
        sourceView.center = CGPoint(x: sourceFrame.midY, y: sourceFrame.midX)
        sourceView.transform = .init(rotationAngle: .pi / -2)
        sourceView.layer.cornerRadius = superView.layer.cornerRadius
        sourceView.layer.masksToBounds = true
        destinationView.addSubview(sourceView)

        lanWindow.alpha = 0
        lanWindow.makeKeyAndVisible()

        if animated {
            /// When sourceView removeFromSuperView and add to destinationView,view will flash
            /// so I add an fade animation to prevent the flash
            UIView.animate(withDuration: flashTime, animations: {
                self.lanWindow.alpha = 1
                self.state = .animating
            }) { (_) in
                self.sourceShotView.removeFromSuperview()
                self.presentAnimating(animated: animated)
            }
        }else {
            self.lanWindow.alpha = 1
            self.state = .animating
            self.sourceShotView.removeFromSuperview()
            self.presentAnimating(animated: animated)
        }
    }

    fileprivate func presentAnimating(animated : Bool) {
        guard let sourceView = self.sourceView else { return }
        let width   = lanWindow.bounds.size.width
        let height  = lanWindow.bounds.size.height

        if animated {
            UIView.animate(withDuration: playerAnimationTime, delay: 0, options: .layoutSubviews, animations: {
                sourceView.center = CGPoint(x: height / 2.0, y: width / 2.0)
                sourceView.transform = .identity
                let newFrame = CGRect(x: 0, y: 0, width: width, height: height)
                sourceView.frame = newFrame
                sourceView.layer.cornerRadius = 0
            }) { (_) in
                self.mode = .landscape
                self.state = .animated
            }
        } else {
            sourceView.center = CGPoint(x: height / 2.0, y: width / 2.0)
            sourceView.transform = .identity
            let newFrame = CGRect(x: 0, y: 0, width: width, height: height)
            sourceView.frame = newFrame
            sourceView.layer.cornerRadius = 0
            self.mode = .landscape
            self.state = .animated
        }
    }

    fileprivate func dismissWillBegin(animated : Bool) {
        /// To prevent multiple calls
        if state == .animating {
            return
        }

        if mode == .portrait {
            return
        }

        /// insert snapshotview as background
        /// when exit app snapshotView will be nil
        var snapshotView : UIView?
        if let snap = destinationView.snapshotView(afterScreenUpdates: true) {
            destinationView.insertSubview(snap, at: 0)
            snapshotView = snap
        }

        guard let sourceView = self.sourceView else { return }

        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        sourceView.transform = .init(rotationAngle: .pi / 2)
        sourceView.center = CGPoint(x: height / 2.0, y: width / 2.0)
        sourceView.removeLayerAnimation()
        keyView.addSubview(sourceView)

        if animated {
            /// when sourceView removeFromSuperView and add to keyView,view will flash
            /// so I add an fade animation to prevent the flash
            UIView.animate(withDuration: flashTime, animations: {
                self.lanWindow.alpha = 0
                self.state = .animating
            }) { (_) in
                /// 1. when in landscape
                /// 2. exit the app
                /// 3. and in
                /// UITableView will be scaled
                /// so use makeKeyAndVisible and layoutIfNeeded to fix that problem
                self.keyWindow.makeKeyAndVisible()
                self.keyView.layoutIfNeeded()

                self.lanWindow.isHidden = true
                self.lanWindow.alpha = 1.0
                snapshotView?.removeFromSuperview()
                self.dismissAnimating(animated: animated)
            }
        } else {
            self.lanWindow.alpha = 0
            self.state = .animating
            self.keyWindow.makeKeyAndVisible()
            self.keyView.layoutIfNeeded()

            self.lanWindow.isHidden = true
            self.lanWindow.alpha = 1.0
            snapshotView?.removeFromSuperview()
            self.dismissAnimating(animated: animated)
        }

    }

    fileprivate func dismissAnimating(animated : Bool) {
        guard let sourceView = self.sourceView else { return }
        let sourceFrame = self.sourceFrame
        let superView = self.superView

        if animated {
            UIView.animate(withDuration: playerAnimationTime, delay: 0, options:.layoutSubviews, animations: {
                sourceView.frame = CGRect(x: sourceFrame.origin.x, y: sourceFrame.origin.y, width: sourceFrame.height, height: sourceFrame.width)
                sourceView.center = CGPoint(x: sourceFrame.midX, y: sourceFrame.midY)
                sourceView.transform = .identity
                sourceView.layer.cornerRadius = superView.layer.cornerRadius
                sourceView.layer.masksToBounds = false
            }) { (_) in
                superView.addSubview(sourceView)
                sourceView.transform = .identity
                sourceView.edges(to: superView)
                sourceView.layer.cornerRadius = 0
                superView.layoutIfNeeded()
                self.state = .animated
                self.mode = .portrait
            }
        } else {
            sourceView.frame = CGRect(x: sourceFrame.origin.x, y: sourceFrame.origin.y, width: sourceFrame.height, height: sourceFrame.width)
            sourceView.center = CGPoint(x: sourceFrame.midX, y: sourceFrame.midY)
            sourceView.transform = .identity
            sourceView.layer.cornerRadius = superView.layer.cornerRadius
            sourceView.layer.masksToBounds = false

            superView.addSubview(sourceView)
            sourceView.transform = .identity
            sourceView.edges(to: superView)
            sourceView.layer.cornerRadius = 0
            superView.layoutIfNeeded()
            self.state = .animated
            self.mode = .portrait
        }
    }
}
