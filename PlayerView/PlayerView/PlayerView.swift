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

    private lazy var lanWindow : UIWindow = {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.windowLevel = .alert
        lanVC.orientation = .landscapeRight
        window.rootViewController = lanVC
        window.backgroundColor = .clear
        return window
    }()
        
    private lazy var porWindow : UIWindow = {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.windowLevel = .alert
        porVc.orientation = .portrait
        window.rootViewController = porVc
        window.backgroundColor = .clear
        return window
    }()
        
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
    
    func setup() {
        backgroundColor = .black
        addSubViews()
        addGestures()
        reachabilityCallBack()
        observerCallBack()
    }
    
    public func prepare(url : URL) {
        
        if item != nil {
            self.state = .stop
        }
        
        let item = AVPlayerItem(url: url)
        item.preferredForwardBufferDuration = 10
        self.item = item
        player.replaceCurrentItem(with: item)
        itemObserver.item = item
        itemObserver.player = player
        layerView.play()
        state = .loading
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
            self.state = .network(.networkUnReachable)
        case .wifi:
            self.state = .network(.wifi)
        case .wwan:
            self.state = .network(.wwan)
        }
    }
    
    func observerCallBack() {
        itemObserver.observedStatus =  {[weak self] status in
            guard let self = self else { return }
            switch status {
            case .readyToPlay:
                self.layerView.isReadyToPlay = true
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
            self.state = .finished
        }
        
        itemObserver.observedBufferEmpty =  {[weak self] isEmpty in
            guard let self = self else { return }
            self.state = .loading
        }
        
        itemObserver.observedBufferFull =  {[weak self] isFull in
            guard let self = self else { return }
            self.state = .bufferFull(isFull)
        }
        
        itemObserver.observedKeepUp =  {[weak self] isLikely in
            guard let self = self else { return }
            if isLikely {
//                self.state = .seekDone
            }
        }
        
        itemObserver.observedError =  {[weak self] error in
            guard let self = self else { return }
            let error = PlayerErrorState(error: error)
            print(error)
            self.state = .error(error)
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
                        
            let animator = Animator(with: self)
            delegate?.playerWillEnterFullScreen()
            
            lanVC.presentAnimationWillBegin(for: animator)
            lanVC.presentAnimationDidBegin(for: animator) {
                
            }
            
            lanWindow.makeKeyAndVisible()
            
            self.animator = animator
        }else if state == .mode(.portrait) {
            
            let width = UIScreen.main.bounds.width
            let height = UIScreen.main.bounds.height
            let porView = porVc.view!
//            self.removeFromSuperview()
//            self.frame = CGRect(x: 0, y: 0, width: width, height: height)
            self.transform = .init(rotationAngle: .pi / 2)
            self.center = CGPoint(x: height / 2.0, y: width / 2.0)
            self.removeLayerAnimation()
//
            porWindow.makeKeyAndVisible()
            porView.addSubview(self)

            lanWindow.isHidden = true
                        
            porVc.dismissAnimationDidBegin(for: animator!, animating: {
            }) {
                print("完成")
                self.porWindow.isHidden = true
            }
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
    func receive(_ value: PlayerState) {
        handle(state: state)
    }
}
