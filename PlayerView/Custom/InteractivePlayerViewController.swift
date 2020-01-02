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

    private var container : UIView
    private var imageView : UIImageView
    private var model : DouYinModel
    
    lazy var player: PlayerView = {
        let configuration = PlayerConfiguration()
        configuration.backgroundColor = .clear
        configuration.repeatWhenFinished = true
        configuration.controlsPreferences.disable = true
        configuration.disableCacheProgress = true
        configuration.videoGravity = .resizeAspectFill
        let player = PlayerView(configuration: configuration)
        return player
    }()

    var imageViewHiddenOptions : ImageViewHiddenOption = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        container.backgroundColor = .red
    }
    
    
    init(container :UIView , imageView : UIImageView,model : DouYinModel) {
        self.imageView = imageView
        self.model = model
        self.container = container
        super.init(nibName: nil, bundle: nil)
        registerAsStateSubscriber()
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
        let urlString = model.video.play_addr.url_list[0]
        if let url = URL(string: urlString) {
            player.prepare(url: url, in: container)
            container.layoutIfNeeded()
        }
        if let url = URL(string: model.video.origin_cover.url_list[0]) {
            imageView.contentMode = .scaleAspectFill
            imageView.kf.setImage(with: url,options: [])
        }
    }
    
    func presentAnimating() {

    }
    
    func presentAnimationDidEnd() {
        imageViewHiddenOptions = imageViewHiddenOptions.union(.animationEnd)
        
        if imageViewHiddenOptions == ImageViewHiddenOption.all {
            imageView.isHidden = true
        }
    }
}

extension InteractivePlayerViewController : DismissAnimation {
    
    func dismissWillBegin() {
        player.paused()
    }
    
    func dismissAnimationWillBegin(){
        if let url = URL(string: model.video.cover.url_list[0]) {
            imageView.kf.setImage(with: url,options: [])
        }
    }
    
    func dismissAnimationDidEnd() {
        imageView.contentMode = .scaleAspectFit
    }
    
    func dismissAnimationCanceled() {
        player.play()
    }
    
    func dismissAnimating() {
        player.stop()
    }
}

extension InteractivePlayerViewController : PlayerStateSubscriber {
    func receive(state: PlayerState) {
        if state == .play {
            if !imageView.isHidden {
                imageViewHiddenOptions = imageViewHiddenOptions.union(.readyToPlay)
                if imageViewHiddenOptions == ImageViewHiddenOption.all {
                    imageView.isHidden = true
                }
            }
        }else if state == .stop(nil) {
            imageView.isHidden = false
        }else if state == .paused {
            print("停止")
        }
    }
    
    var eventBus: EventBus {
        return player.eventBus
    }
}

