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
//  PlayerViewController.swift
//  PlayerView
//
//  Created by 杨志远 on 2019/11/21.
//

import UIKit

class PlayerViewController: UIViewController {
    
    var orientation : UIInterfaceOrientationMask = .landscapeRight

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
        return orientation
    }

}

extension PlayerViewController {
    
    
    func dismissAnimationWillBegin(for animator: Animator) {
        orientation = .portrait
    }
    
    func dismissAnimationDidBegin(for animator: Animator, animating: (() -> Void)?, complete: @escaping () -> Void) {
        let sourceFrame = animator.sourceFrame
        let sourceView = animator.sourceView
        let superView = animator.superView
        
        UIView.animate(withDuration: 0.5, delay: 0, options:.layoutSubviews, animations: {
            sourceView.frame = CGRect(x: sourceFrame.origin.x, y: sourceFrame.origin.y, width: sourceFrame.height, height: sourceFrame.width)
            sourceView.center = CGPoint(x: sourceFrame.midX, y: sourceFrame.midY)
            sourceView.transform = .identity
        }) { (_) in
//            sourceView.removeFromSuperview()
            superView.addSubview(sourceView)
            sourceView.transform = .identity
            sourceView.edges(to: superView)
            superView.layoutIfNeeded()
            complete()
        }
    }
}


extension PlayerViewController {
    func presentAnimationWillBegin(for animator: Animator) {
        // insert playerView
        let sourceView = animator.sourceView
        let sourceFrame = animator.sourceFrame
        sourceView.removeFromSuperview()
        sourceView.removeConstraints()

        sourceView.frame = CGRect(x: sourceFrame.origin.y, y: sourceFrame.origin.x, width: sourceFrame.width, height: sourceFrame.height)
        sourceView.center = CGPoint(x: sourceFrame.midY, y: sourceFrame.midX)
        sourceView.transform = .init(rotationAngle: .pi / -2)

        self.view.addSubview(sourceView)

    }
    
    func presentAnimationDidBegin(for animator : Animator,complete:@escaping ()->Void) {
                
        let sourceView = animator.sourceView
        let sourceFrame = animator.sourceFrame
        
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .layoutSubviews, animations: {
            let newFrame = CGRect(x: 0, y: 0, width: width, height: height)
            sourceView.frame = newFrame
            sourceView.center = CGPoint(x: height / 2.0, y: width / 2.0)
            sourceView.transform = .identity
        }) { (_) in
            complete()
        }
    }
    
}
