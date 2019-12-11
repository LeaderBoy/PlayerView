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
//  PlayerView.swift
//  PlayerView
//
//  Created by 杨志远 on 2019/11/20.
//

import UIKit
import AVKit


public protocol PlayerViewDataSource : class {
    func playerControlsView() -> UIView?
    func playerIndicatorTitleForState(_ state : PlayerState) -> String?
}

public protocol PlayerViewDelegate : class {
    func playerWillEnterFullScreen()
    func playerWillExitFullScreen()
}


public class PlayerView: UIView {
        
    weak public var dataSource : PlayerViewDataSource?
    weak public var delegate : PlayerViewDelegate?
    
    public var indexPath : IndexPath?
    
    public var eventBus = EventBus()
    
    public var state : PlayerState = .unknown
    public var shouldStatusBarHidden = false
    public var item : AVPlayerItem?
    
    private var player : AVPlayer = {
        let p = AVPlayer()
        p.automaticallyWaitsToMinimizeStalling = false
        // 预防息屏
        if #available(iOS 12.0, *) {
            p.preventsDisplaySleepDuringVideoPlayback = true
        } else {
            // Fallback on earlier versions
        }
        return p
    }()
    
    private var reachability = Reachability.forInternetConnection()
    
    private lazy var layerView = PlayerLayerView(player: player)
    private lazy var indicatorView = IndicatorView()
    private lazy var controlsView  = ControlsView()
    private lazy var itemObserver = ItemObserver()
    
    var animator : Animator?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    deinit {
        reachability?.stopNotifier()
    }
    
    func setup() {
        configUI()
        addGestures()
        reachabilityCallBack()
        setupCategory()
        registerAsStateSubscriber()
    }
    
    func setupCategory() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
        }catch {
            
        }
    }
    
    public func reload() {
        
    }
    
    public func prepare(url : URL,in container : UIView,at indexPath : IndexPath? = nil) {
        if item != nil {
            publish(state: .stop(indexPath))
        }
        
        self.indexPath = indexPath
        
        let item = AVPlayerItem(url: url)
        item.preferredForwardBufferDuration = 10
        self.item = item
        player.replaceCurrentItem(with: item)
        itemObserver.item = item
        itemObserver.player = player
        // loading
        publish(state: .prepare(indexPath))
        
        container.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        edges(to: container)
    }
    
    public func stop(at indexPath : IndexPath? = nil) {
        publish(state: .stop(indexPath))
    }
        
    func resetVariables() {
        indexPath = nil
        item = nil
        shouldStatusBarHidden = false
        state = .unknown
    }
    
    func configUI() {
        backgroundColor = PlayerViewOptions.backgroundColor

        addSubview(layerView)
        layerView.bus = eventBus
        layerView.edges(to: self)
        
        if !PlayerViewOptions.disableControlsView {
            addSubview(controlsView)
            controlsView.edges(to: self)
            controlsView.bus = eventBus
        }
        
        if !PlayerViewOptions.disableIndicatorView {
            addSubview(indicatorView)
            indicatorView.edges(to: self)
            indicatorView.bus = eventBus
        }
        
        itemObserver.bus = eventBus
    }
    
    
    func addGestures() {
        let oneTap = UITapGestureRecognizer(target: controlsView, action: #selector(ControlsView.switchHiddenState(gesture:)))
        oneTap.numberOfTapsRequired = 1
        oneTap.delegate = self
        addGestureRecognizer(oneTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(switchVideoGravity(gesture:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        oneTap.require(toFail: doubleTap)
        addGestureRecognizer(doubleTap)
    }
    
    func reachabilityCallBack() {
        reachability?.startNotifier()
        reachability?.statusDidChanged = { [weak self]status in
            guard let self = self else { return }
            self.handleReachability(status: status)
        }
    }
    
    func handleReachability(status : Reachability.Status) {
        switch status {
        case .unReachable:
            publish(state: .network(.networkUnReachable))
        case .wifi:
            publish(state: .network(.wifi))
        case .wwan:
            publish(state: .network(.wwan))
        }
    }
    
    @objc func switchVideoGravity(gesture : UIGestureRecognizer) {
        if controlsView.ignore(gesture: gesture) {
            return
        }
        layerView.switchVideoGravity()
    }
    
    func handle(state : PlayerState) {
        switch state {
        case .mode(.landscape):
            if animator == nil {
                let animator = Animator(with: self)
                self.animator = animator
            }else {
                animator!.update(sourceView: self)
            }
            animator!.present()
            shouldStatusBarHidden = true
        case .mode(.portrait):
            animator!.dismiss()
            shouldStatusBarHidden = false
        case .stop(_):
            resetVariables()
            removeFromSuperview()
        default:
            break
        }
    }
}


extension PlayerView : UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIControl {
            return false
        }
        return true
    }
}


extension PlayerView : PlayerStateSubscriber {
    public func receive(state: PlayerState) {
        if self.state == state {
            return
        }
        handle(state: state)
    }
}

extension PlayerView : PlayerStatePublisher {}
