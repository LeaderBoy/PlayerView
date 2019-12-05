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
    
    weak var sourceView : UIView?
    let sourceFrame : CGRect
    let superView : UIView
    
    private let lanVC = PlayerViewController()
    
    private var destinationView : UIView {
        return lanVC.view
    }
    
    private lazy var lanWindow : UIWindow = {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.windowLevel = .alert
        lanVC.orientation = .landscapeRight
        window.rootViewController = lanVC
        window.backgroundColor = .clear
        return window
    }()
    
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
    
    func present() {
        presentWillBegin()
        presentAnimating()
        lanWindow.makeKeyAndVisible()
    }
    
    func presentWillBegin() {
        guard let sourceView = self.sourceView else { return }
        sourceView.removeFromSuperview()
        sourceView.removeConstraints()
        sourceView.frame = CGRect(x: sourceFrame.origin.y, y: sourceFrame.origin.x, width: sourceFrame.width, height: sourceFrame.height)
        sourceView.center = CGPoint(x: sourceFrame.midY, y: sourceFrame.midX)
        sourceView.transform = .init(rotationAngle: .pi / -2)
        destinationView.addSubview(sourceView)
    }
    
    func presentAnimating() {
        guard let sourceView = self.sourceView else { return }
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        UIView.animate(withDuration: 0.5, delay: 0, options: .layoutSubviews, animations: {
            let newFrame = CGRect(x: 0, y: 0, width: width, height: height)
            sourceView.frame = newFrame
            sourceView.center = CGPoint(x: height / 2.0, y: width / 2.0)
            sourceView.transform = .identity
        }) { (_) in
//            complete()
        }
    }
    
    func dismiss() {
        dismissWillBegin()
        dismissAnimating()
    }
    
    func dismissWillBegin() {
        guard let sourceView = self.sourceView else { return }
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height

        sourceView.transform = .init(rotationAngle: .pi / 2)
        sourceView.center = CGPoint(x: height / 2.0, y: width / 2.0)
        sourceView.removeLayerAnimation()

        lanWindow.isHidden = true
                    
        guard let keyView = UIApplication.shared.keyWindow?.rootViewController?.view else {
            fatalError("keyWindow not exist")
        }

        keyView.addSubview(sourceView)
    }
    
    func dismissAnimating() {
        guard let sourceView = self.sourceView else { return }
        let sourceFrame = self.sourceFrame
        let superView = self.superView
        
        UIView.animate(withDuration: 0.5, delay: 0, options:.layoutSubviews, animations: {
            sourceView.frame = CGRect(x: sourceFrame.origin.x, y: sourceFrame.origin.y, width: sourceFrame.height, height: sourceFrame.width)
            sourceView.center = CGPoint(x: sourceFrame.midX, y: sourceFrame.midY)
            sourceView.transform = .identity
        }) { (_) in
            superView.addSubview(sourceView)
            sourceView.transform = .identity
            sourceView.edges(to: superView)
            superView.layoutIfNeeded()
        }
    }
}
