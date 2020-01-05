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
//  InteractivePlayerViewController.swift
//  PlayerView
//
//  Created by 杨志远 on 2019/12/28.
//

import UIKit

/// Hide the imageView when meet multiple conditions at the same time
struct ImageViewHiddenOption : OptionSet {
    let rawValue: Int
    static let readyToPlay = ImageViewHiddenOption(rawValue: 1 << 0)
    static let animationEnd = ImageViewHiddenOption(rawValue: 1 << 1)
    static let all = ImageViewHiddenOption(rawValue: 3)
}

class InteractivePlayerViewController: UIViewController {
    var player : DouYinUIPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    init(container :UIView , imageView : URLImageView,model : DouYinModel) {
        player = DouYinUIPlayer(container: container, imageView: imageView, model: model)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

}

extension InteractivePlayerViewController : PresentAnimation {
    func presentAnimationWillBegin() {
        player.presentAnimationWillBegin()
    }
    
    func presentAnimating() {
        player.presentAnimating()
    }
    
    func presentAnimationDidEnd() {
        player.presentAnimationDidEnd()
    }
}

extension InteractivePlayerViewController : DismissAnimation {
    
    func dismissWillBegin() {
        player.dismissWillBegin()
    }
    
    func dismissAnimationWillBegin(){
        player.dismissAnimationWillBegin()
    }
    
    func dismissAnimationDidEnd() {
        player.dismissAnimationDidEnd()
    }
    
    func dismissAnimationCanceled() {
        player.dismissAnimationCanceled()
    }
    
    func dismissAnimating() {
        player.dismissAnimating()
    }
}

