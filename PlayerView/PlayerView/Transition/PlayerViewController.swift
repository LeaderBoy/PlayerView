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

    var containerView: UIView = {
        let v = UIView()
//        v.backgroundColor = .blue
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
       
        view.addSubview(containerView)
        // Do any additional setup after loading the view.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
        
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscapeRight
    }

}

extension PlayerViewController : DismissAnimation {
    func dismissAnimationWillBegin(for animator: Animator) {
        view.backgroundColor = .clear
    }
    
    func dismissAnimationDidBegin(for animator: Animator, complete: @escaping () -> Void) {
        let sourceFrame = animator.sourceFrame
        let sourceView = animator.sourceView
        let superView = animator.superView
        
        UIView.animate(withDuration: animator.transitionDuration(using: nil), delay: 0, options:.layoutSubviews, animations: {
            self.containerView.frame = sourceFrame
            self.containerView.center = CGPoint(x: sourceFrame.midY, y: sourceFrame.midX)
            self.containerView.transform = .init(rotationAngle: .pi / -2)
        }) { (_) in
            sourceView.removeFromSuperview()
            sourceView.removeConstraints()
            superView.addSubview(sourceView)
            sourceView.edges(to: superView)
            superView.layoutIfNeeded()
            complete()
        }
    }
    
    func dismissAnimationDidEnd(for animator: Animator) {
        self.containerView.transform = .identity
    }
}


extension PlayerViewController : PresentAnimation {
    
    func presentAnimationDidBegin(for animator : Animator,complete:@escaping ()->Void) {
        let sourveView = animator.sourceView
        sourveView.removeLayerAnimation()
        UIView.animate(withDuration: animator.transitionDuration(using: nil), delay: 0, options: .layoutSubviews, animations: {
            let newFrame = CGRect(x: 0, y: 0, width: self.view.frame.height, height: self.view.frame.width)
            self.containerView.frame = newFrame
            self.containerView.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
            self.containerView.transform = .identity
        }) { (_) in
            complete()
        }
    }
    
    func presentAnimationWillBegin(for animator: Animator) {
        // insert playerView
        let sourceView = animator.sourceView
        let sourceFrame = animator.sourceFrame
        sourceView.removeFromSuperview()
        sourceView.removeConstraints()
        containerView.addSubview(sourceView)
        sourceView.edges(to: containerView)

        let newCenter   = CGPoint(x: sourceFrame.midY, y: sourceFrame.midX)
        containerView.frame    = sourceFrame
        containerView.center   = newCenter
        containerView.transform = .init(rotationAngle: .pi / -2)
        containerView.layoutIfNeeded()
    }
}
