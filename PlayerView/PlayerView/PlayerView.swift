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

/// two implement about player fullscreen
/// window : present a landscaped UIWindow
/// present : present a landscaped controller
public enum Plan {
    case window
    case present
}


/// Why Why do you need to use it?
/// Blog :
/// We need a container to wrap the playerView
public protocol PlayerContainerable {
    var playerContainer : UIView { get }
}

import WebKit

public class PlayerView: UIView {
    
    weak public var dataSource : PlayerViewDataSource?
    weak public var delegate : PlayerViewDelegate?
    
    /// when you need to register as a subscriber,you must confirm to protocol EventBusIdentifiable
    /// return the eventBus rather than implement a eventbus yourself
    public var eventBus = EventBus()
    
    /// current indexPath
    public var indexPath : IndexPath?
    /// current state
    public var state : PlayerState = .unknown
    /// current mode state
    public var modeState : PlayerModeState = .portrait
    public var shouldStatusBarHidden = false
    public var shouldAutorotate = true
    public var supportedInterfaceOrientations : UIInterfaceOrientationMask = .portrait

    public var item : AVPlayerItem?
    /// current plan
    public var plan : Plan = .window
    /// is presenting or dismissing
    public var isAnimating = false
    
    private var reachability = Reachability.forInternetConnection()
    private var animator : Animator?

    private lazy var layerView = PlayerLayerView(player: player)
    private lazy var indicatorView = IndicatorView()
    private lazy var controlsView  = ControlsView()
    private lazy var itemObserver = ItemObserver()
    private lazy var loadingView = IndicatorLoading()
    private lazy var motionManager = MotionManager()
    private lazy var animatable = true
    private lazy var recoverFromPortrait = false
    private lazy var offset : CGPoint = .zero
    
    private var aimOrientation : UIInterfaceOrientationMask?
    
    private var player : AVPlayer = {
        let p = AVPlayer()
        p.automaticallyWaitsToMinimizeStalling = false
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
        }catch (let r) {
            print("AVAudioSession.sharedInstance().setCategory error:\(r)")
        }
        // 预防息屏
        if #available(iOS 12.0, *) {
            p.preventsDisplaySleepDuringVideoPlayback = true
        } else {
            // Fallback on earlier versions
        }
        return p
    }()

    override init(frame: CGRect) {
        self.configuration = PlayerConfiguration()
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        self.configuration = PlayerConfiguration()
        super.init(coder: coder)
        setup()
    }
    
    private(set) var configuration : PlayerConfiguration
    
    public init(frame: CGRect, configuration: PlayerConfiguration) {
        self.configuration = configuration
        super.init(frame:frame)
        setup()
    }
    
    deinit {
        removeAllObserver()
        reachability?.stopNotifier()
    }
    
    func setup() {
        registerAsStateSubscriber()
        configUI()
        addGestures()
        addObserver()
        reachabilityCallBack()
    }
    
    public func prepare(url : URL,in container : UIView,at indexPath : IndexPath? = nil) {
        /// stop observer for oldItem
        if item != nil {
            publish(state: .stop(self.indexPath))
        }
        /// record indexPath
        self.indexPath = indexPath
        /// prepare new item
        let item = AVPlayerItem(url: url)
        item.preferredForwardBufferDuration = 10
        self.item = item
        player.replaceCurrentItem(with: item)
        itemObserver.item = item
        itemObserver.player = player
        /// loading
        publish(state: .prepare(indexPath))
        /// add player
        container.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        edges(to: container)
    }
    
    public func stop() {
        if modeState == .landscape || isAnimating {
            return
        }
        publish(state: .stop(self.indexPath))
    }
    
    public func play() {
        publish(state: .play)
    }
    
    public func paused() {
        publish(state: .paused)
    }
    
    public func seekTo(time : TimeInterval) {
        publish(state: .seeking(time))
    }
    
    public func updateMode(_ mode : PlayerModeState) {
        publish(state: .mode(mode))
    }
    
    public func updateWillChangeTableView(_ tableView : UITableView) {
        offset = tableView.contentOffset
    }
    
    public func updateDidChangeTableView(_ tableView : UITableView) {
        if let i = indexPath {
            DispatchQueue.main.async {
                tableView.contentOffset = self.offset
                /// deadline should less than playerTransitionDuration
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.016) {
                    if let cell = tableView.cellForRow(at: i) as? PlayerContainerable {
                        let container = cell.playerContainer
                        self.animator?.superView = container
                    }else {
                        fatalError("your cell must confirm to protocol PlayerContainerable")
                    }
                }
            }
        }
    }
        
    func resetVariables() {
        indexPath = nil
        item = nil
        shouldStatusBarHidden = false
        state = .unknown
        aimOrientation = nil
    }
    
    func configUI() {
        backgroundColor = PlayerViewOptions.backgroundColor

        addSubview(layerView)
        layerView.bus = eventBus
        layerView.edges(to: self)
        
//        if configuration {
//            <#code#>
//        }
        
        if !PlayerViewOptions.disableControlsView {
            addSubview(controlsView)
            controlsView.edges(to: self)
            controlsView.bus = eventBus
        }
        
        if !PlayerViewOptions.disableIndicatorLoading {
            addSubview(loadingView)
            loadingView.edges(to: self)
            loadingView.bus = eventBus
        }
        
        if !PlayerViewOptions.disableIndicatorView {
            addSubview(indicatorView)
            indicatorView.edges(to: self)
            indicatorView.bus = eventBus
        }
        
        if !PlayerViewOptions.disableMotionMonitor {
            motionManager.bus = eventBus
//            print(UIInterfaceOrientationMask.portrait)
//            print(UIInterfaceOrientationMask.landscapeLeft)
//            print(UIInterfaceOrientationMask.landscapeRight)
//            print(UIInterfaceOrientationMask.allButUpsideDown)
//
//            motionManager.updateOrientation = { ori in
//                print(ori)
//            }
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
            handleLandscape()
        case .mode(.portrait):
            handlePortrait()
        case .stop(_):
            resetVariables()
            removeFromSuperview()
        case .interrupted(let t):
            if t == .began {
                publish(state: .paused)
            }else if t == .ended {
                publish(state: .play)
            }
        default:
            break
        }
    }
    
    func handleLandscape() {
        
        if modeState == .landscape {
            print("Warn : current modeState is already landscape, do not landscape again")
            return
        }
        
        modeState = .landscape
        shouldStatusBarHidden = true
        
        let animator = Animator(with: self, plan: plan)
        animator.aimOrientation = aimOrientation

        isAnimating = true
        supportedInterfaceOrientations = [.landscapeLeft,.landscapeRight]
        
        let animated = plan == .window ? animatable : true
        animator.present(animated: animated) {
            self.isAnimating = false
        }
        self.animator = animator
    }
    
    func handlePortrait() {
        if modeState == .portrait {
            print("Warn : current modeState is already portrait, do not portrait again")
            return
        }
        modeState = .portrait
        shouldStatusBarHidden = false
        isAnimating = true
        supportedInterfaceOrientations = [.portrait]
        
        let animated = plan == .window ? animatable : true
        if let animator = self.animator {
            animator.dismiss(animated: animated) {
                self.isAnimating = false
                self.animator = nil
            }
        }
    }
        
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActiveNotification), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notification(note:)), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    private func removeAllObserver() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    
    @objc func didBecomeActiveNotification() {
        if plan == .window {
            if modeState == .portrait && recoverFromPortrait {
                /// iOS12
                /// fullscreen will get wrong width and height in present animation if not use DispatchQueue.main
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.recoverFromPortrait = false
                    self.animatable = false
                    self.publish(state: .mode(.landscape))
                    self.animatable = true
                    self.animator?.windowDismissRemoveTempSnapshotView()
                }
            }
        }
        
        self.publish(state: .play)
    }
    
    @objc func willResignActiveNotification() {
        controlsView.hide()
        publish(state: .paused)
        if plan == .window {
            if modeState == .landscape {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.animator?.windowDismissInsertTempSnapshotView()
                    self.animatable = false
                    self.publish(state: .mode(.portrait))
                    self.animatable = true
                    self.recoverFromPortrait = true
                }
            }
        }
    }
    
    @objc func notification(note : Notification) {
        let value = UIDevice.current.orientation
        if value == .landscapeLeft {
            aimOrientation = .landscapeRight
            animator?.aimOrientation = aimOrientation
        } else if value == .landscapeRight {
            aimOrientation = .landscapeLeft
            animator?.aimOrientation = aimOrientation
        } else if value == .portrait {
            aimOrientation = .portrait
        } else if value == .portraitUpsideDown {
            aimOrientation = .portraitUpsideDown
        } else if value == .faceUp {
            aimOrientation = .portrait
        } else if value == .faceDown {
            aimOrientation = .portrait
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


extension UIViewController {
    // find the most top viewController but presentedViewController
    func topLevelViewController() -> UIViewController {
        if let tab = self as? UITabBarController,let selected = tab.selectedViewController {
            return selected.topLevelViewController()
        } else if let nav = self as? UINavigationController,let top = nav.topViewController {
            return top.topLevelViewController()
        } else {
            return self
        }
    }
}
