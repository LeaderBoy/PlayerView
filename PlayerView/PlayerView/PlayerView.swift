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
    private let lanVC = PlayerViewController()
    private let porVc = PlayerViewController()
    
    var animator : Animator?

        
    weak public var dataSource : PlayerViewDataSource?
    weak public var delegate : PlayerViewDelegate?
        
    public lazy var itemObserver = ItemObserver()
    public var state : PlayerState = .unknown
    
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
    
    public var reachability = Reachability.forInternetConnection()
    
    lazy var layerView = PlayerLayerView(player: player)
    lazy var indicatorView = IndicatorView()
    lazy var controlsView  = ControlsView()
    
//    public var shouldStatusBarHidden = false
    
    public var item : AVPlayerItem?
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    init(dataSource : PlayerViewDataSource?,delegate : PlayerViewDelegate?) {
        self.dataSource = dataSource
        self.delegate = delegate
        super.init(frame: .zero)
        setup()
    }
    
    deinit {
        reachability?.stopNotifier()
    }
    
    func setup() {
        backgroundColor = .black
        addSubViews()
        addGestures()
        reachabilityCallBack()
        observerCallBack()
        setupCategory()
        becomeSubscriber()
    }
    
    func setupCategory() {
        do {
            try         AVAudioSession.sharedInstance().setCategory(.playback)
        }catch {
            
        }
    }
    
    public func prepare(url : URL) {
        if item != nil {
            publish(.stop)
        }
        
        let item = AVPlayerItem(url: url)
        item.preferredForwardBufferDuration = 10
        self.item = item
        player.replaceCurrentItem(with: item)
        itemObserver.item = item
        itemObserver.player = player
        layerView.play()
        // loading
        publish(.prepare)
    }
    
    func addSubViews() {
        addSubview(layerView)
        addSubview(controlsView)
        addSubview(indicatorView)
        
        controlsView.edges(to: self)
        indicatorView.edges(to: self)
        layerView.edges(to: self)
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
            publish(.network(.networkUnReachable))
        case .wifi:
            publish(.network(.wifi))
        case .wwan:
            publish(.network(.wwan))
        }
    }
    
    func observerCallBack() {
        itemObserver.observedStatus =  {[weak self] status in
            guard let self = self else { return }
            switch status {
            case .readyToPlay:
                self.layerView.isReadyToPlay = true
                self.publish(.playing)
            case .failed:
               print("播放失败")
            default:
                break
            }
        }
        
        itemObserver.observedDuration =  {[weak self] duration in
            guard let self = self else { return }
            self.layerView.duration = duration
            self.controlsView.duration = duration
        }
        
        itemObserver.observedPosition =  {[weak self] position in
            guard let self = self else { return }
            self.controlsView.position = position
        }
                
        itemObserver.observedLoadedTime =  {[weak self] time in
            guard let self = self else { return }
            self.controlsView.bufferTime = time
        }
        
        itemObserver.observedPlayDone =  {[weak self] in
            guard let self = self else { return }
            self.publish(.finished)
        }
        
        itemObserver.observedBufferEmpty =  {[weak self] isEmpty in
            guard let self = self else { return }
            self.publish(.loading)
        }
        
        itemObserver.observedBufferFull =  {[weak self] isFull in
            guard let self = self else { return }
            self.publish(.bufferFull(isFull))
        }
        
        itemObserver.observedKeepUp =  {[weak self] isLikely in
            guard let self = self else { return }
            if isLikely {
//                self.state = .seekDone
            }
        }
        
        itemObserver.observedError =  {[weak self] error in
            guard let self = self else { return }
            self.publish(.error(error))
        }
    }
    
    @objc func switchVideoGravity(gesture : UIGestureRecognizer) {
        if controlsView.ignore(gesture: gesture) {
            return
        }
        layerView.switchVideoGravity()
    }
    
    func handle(state : PlayerState) {
        if state == .mode(.landscape) {
            if animator == nil {
                let animator = Animator(with: self)
                self.animator = animator
            }else {
                animator!.update(sourceView: self)
            }
            animator!.present()
        }else if state == .mode(.portrait) {
            animator!.dismiss()
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


extension PlayerView : StateSubscriber {
    public func receive(_ value: PlayerState) {
        if state == value {
            return
        }
        handle(state: value)
    }
}

extension PlayerView : StatePublisher {}
