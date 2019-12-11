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
    
    var flashTime : TimeInterval = 0.02
    
    private let lanVC = PlayerViewController()
    
    private var destinationView : UIView {
        return lanVC.view
    }
    
    private var lanWindow : UIWindow = {
        let size = UIScreen.main.bounds.size
        let window = UIWindow(frame: CGRect(origin: .zero, size: CGSize(width: size.height, height: size.width)))
        window.windowLevel = .alert
        window.backgroundColor = .clear
        return window
    }()
    
    var state : State = .animated
    
    init(with sourceView : UIView) {
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
    
    /// Present fullScreen view
    func present() {
        presentWillBegin()
    }
    
    // Dismiss from fullScreen view
    func dismiss() {
        dismissWillBegin()
    }
    
    func presentWillBegin() {
        /// To prevent multiple calls
        if state == .animating {
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
        
        /// When sourceView removeFromSuperView and add to destinationView,view will flash
        /// so I add an fade animation to prevent the flash
        UIView.animate(withDuration: flashTime, animations: {
            self.lanWindow.alpha = 1
            self.state = .animating
        }) { (_) in
            self.sourceShotView.removeFromSuperview()
            self.presentAnimating()
        }
    }
    
    fileprivate func presentAnimating() {
        guard let sourceView = self.sourceView else { return }
        let width   = lanWindow.bounds.size.width
        let height  = lanWindow.bounds.size.height
                
        UIView.animate(withDuration: playerAnimationTime, delay: 0, options: .layoutSubviews, animations: {
            sourceView.center = CGPoint(x: height / 2.0, y: width / 2.0)
            sourceView.transform = .identity
            let newFrame = CGRect(x: 0, y: 0, width: width, height: height)
            sourceView.frame = newFrame
            sourceView.layer.cornerRadius = 0
        }) { (_) in
            self.state = .animated
        }
    }
    
    fileprivate func dismissWillBegin() {
        /// To prevent multiple calls
        if state == .animating {
            return
        }
        /// insert snapshotview as background
        let snap = destinationView.snapshotView(afterScreenUpdates: false)!
        destinationView.insertSubview(snap, at: 0)
        
        guard let sourceView = self.sourceView else { return }
        
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        sourceView.transform = .init(rotationAngle: .pi / 2)
        sourceView.center = CGPoint(x: height / 2.0, y: width / 2.0)
        sourceView.removeLayerAnimation()
        keyView.addSubview(sourceView)

        /// When sourceView removeFromSuperView and add to keyView,view will flash
        /// so I add an fade animation to prevent the flash
        UIView.animate(withDuration: flashTime, animations: {
            self.lanWindow.alpha = 0
            self.state = .animating
        }) { (_) in
            self.lanWindow.isHidden = true
            self.lanWindow.alpha = 1.0
            snap.removeFromSuperview()
            self.dismissAnimating()
        }
    }
    
    fileprivate func dismissAnimating() {
        guard let sourceView = self.sourceView else { return }
        let sourceFrame = self.sourceFrame
        let superView = self.superView
        
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
        }
    }
}
