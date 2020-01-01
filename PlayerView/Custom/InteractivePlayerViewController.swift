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

class InteractivePlayerViewController: UIViewController {

    var imageView : UIImageView
    var model : DouYinModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        // Do any additional setup after loading the view.
    }
    
    
    init(imageView : UIImageView,model : DouYinModel) {
        self.imageView = imageView
        self.model = model
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
        if let url = URL(string: model.video.origin_cover.url_list[0]) {
            imageView.contentMode = .scaleAspectFill
            imageView.kf.setImage(with: url,options: [])
        }
    }
}

extension InteractivePlayerViewController : DismissAnimation {
    func dismissAnimationWillBegin(){
        if let url = URL(string: model.video.cover.url_list[0]) {
            imageView.contentMode = .scaleAspectFit
            imageView.kf.setImage(with: url,options: [])
        }
    }
}
