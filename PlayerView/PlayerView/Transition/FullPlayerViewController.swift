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
//  FullPlayerViewController.swift
//  PlayerView
//
//  Created by 杨志远 on 2019/12/16.
//

import UIKit

class FullPlayerViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
        
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.landscapeRight,.landscapeLeft]
    }
    
//    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
//        return .landscapeRight
//    }

}

//extension FullPlayerViewController : DismissAnimation {
//    func dismissAnimationWillBegin(for animator: Animator) {
//        view.backgroundColor = .clear
//        self.containerView.center = view.center
//        self.containerView.transform = .init(rotationAngle: .pi / 2)
//    }
//
//    func dismissAnimationDidBegin(for animator: Animator, complete: @escaping () -> Void) {
//        let sourceFrame = animator.sourceFrame
//        let sourceView = animator.sourceView
//
//
//        UIView.animate(withDuration: animator.transitionDuration(using: nil), delay: 0, options:.layoutSubviews, animations: {
//            self.containerView.center = CGPoint(x: sourceFrame.midX, y: sourceFrame.midY)
//            self.containerView.transform = .identity
//            self.containerView.frame = sourceFrame
//        }) { (_) in
//            let superView = animator.superView
//            sourceView.removeFromSuperview()
//            sourceView.removeConstraints()
//            superView.addSubview(sourceView)
//            sourceView.edges(to: superView)
//            superView.layoutIfNeeded()
//            complete()
//        }
//    }
//
//    func dismissAnimationDidEnd(for animator: Animator) {
//        self.containerView.transform = .identity
//    }
//}


