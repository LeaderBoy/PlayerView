//
//  DouYinUIPlayer.swift
//  PlayerView
//
//  Created by 杨志远 on 2020/1/5.
//  Copyright © 2020 BaQiWL. All rights reserved.
//

import UIKit

protocol Placeholder {
    var contentMode : UIView.ContentMode { get }
    var image : UIImage { get }
}

class DouYinUIPlayer: UIView {

    @IBOutlet weak var playerContainer: UIView!
    @IBOutlet weak var douYinControlsView: UIView!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var shareLabel: UILabel!
    @IBOutlet weak var desLabel: UILabel!
    @IBOutlet weak var socialStackView: UIStackView!
    @IBOutlet weak var button: UIButton!
    
    var container : UIView!
    var imageView : UIImageView!
    var imageViewHiddenOptions : ImageViewHiddenOption = []

    var model : DouYinModel! {
        didSet {
            likeLabel.text = "\(model.statistics.digg_count)"
            commentLabel.text = "\(model.statistics.comment_count)"
            shareLabel.text = "\(model.statistics.share_count)"
            desLabel.text = model.desc
        }
    }
    
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
    
    let animationDuration : TimeInterval = 0.5
    
    private var isPlaying = false
    
    init(container :UIView , imageView : UIImageView,model : DouYinModel) {
        self.imageView = imageView
        self.model = model
        self.container = container
        super.init(frame: .zero)
        /// prevent autolayout warn from **(frame .zero)** :
        translatesAutoresizingMaskIntoConstraints = false
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        fromNib()
        addGesture()
        backgroundColor = .clear
        registerAsStateSubscriber()
        
        playerContainer.addSubview(player)
        player.edges(to: playerContainer)
        playerContainer.bringSubviewToFront(douYinControlsView)
        playerContainer.layoutIfNeeded()
    }
    
    func prepare(imageView : UIImageView,container : UIView,model : DouYinModel) {
        isPlaying = true
        self.imageView = imageView
        self.model = model
        container.addSubview(self)
        edges(to: container)
        /// layout
        container.layoutIfNeeded()
        
        if let url = URL(string: model.video.play_addr.url_list[0]) {
            player.prepare(url: url)
        }else {
            fatalError("error address")
        }
    }
    
    func addGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapToPaused))
        addGestureRecognizer(tap)
    }
    
    @objc func tapToPaused() {
        if isPlaying {
            isPlaying = false
            player.paused()
        } else {
            isPlaying = true
            player.play()
        }
    }
    
    func controls(hide : Bool,animated : Bool) {
        let block = {
            self.socialStackView.alpha = hide ? 0 : 1
            self.desLabel.alpha = hide ? 0 : 1
            self.socialStackView.isHidden = hide
            self.desLabel.isHidden = hide
        }
    
        if animated {
            socialStackView.alpha = 0
            desLabel.alpha = 0
            UIView.animate(withDuration: animationDuration) {
                block()
            }
        } else {
            block()
        }
    }
    
    func presentAnimationWillBegin() {
        if let url = URL(string: model.video.origin_cover.url_list[0]) {
            imageView.contentMode = .scaleAspectFill
            imageView.kf.setImage(with: url,options: [])
        }
        
        prepare(imageView: imageView, container: container, model: model)
    }
    
    func presentAnimating() {
        controls(hide: false,animated: true)
    }
    
    func presentAnimationDidEnd() {
        imageViewHiddenOptions = imageViewHiddenOptions.union(.animationEnd)
        
        if imageViewHiddenOptions == ImageViewHiddenOption.all {
            imageView.isHidden = true
        }
    }
    
    func dismissWillBegin() {
        controls(hide: true, animated: false)
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
        controls(hide: false, animated: false)
        player.play()
    }
    
    func dismissAnimating() {
        player.stop()
    }

}

extension DouYinUIPlayer : PlayerStateSubscriber {
    func receive(state: PlayerState) {
        if state == .play {
            button.isHidden = true
            
            if !imageView.isHidden {
                imageViewHiddenOptions = imageViewHiddenOptions.union(.readyToPlay)
                if imageViewHiddenOptions == ImageViewHiddenOption.all {
                    imageView.isHidden = true
                }
            }
        }else if state == .stop(nil) {
            imageView.isHidden = false
            removeFromSuperview()
        }else if state == .paused {
            button.isHidden = false
        }
    }
    
    var eventBus: EventBus {
        return player.eventBus
    }
}
