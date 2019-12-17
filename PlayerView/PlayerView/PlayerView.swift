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



public class PlayerUIInterfaceOrientation {
    static let shared = PlayerUIInterfaceOrientation()
    var current : UIInterfaceOrientationMask = .portrait
}


/// two implement about player fullscreen
/// window : present a landscaped UIWindow
/// present : present a landscaped controller
public enum Plan {
    case window
    case present
}


public class PlayerView: UIView {
        
    weak public var dataSource : PlayerViewDataSource?
    weak public var delegate : PlayerViewDelegate?
    
    public var indexPath : IndexPath?
    public var eventBus = EventBus()
    
    public var state : PlayerState = .unknown
    public var shouldStatusBarHidden = false
    public var item : AVPlayerItem?
    
    public var plan : Plan = .window
    
    private var keyWindow : UIWindow? = UIApplication.shared.keyWindow
    
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
    
    private var reachability = Reachability.forInternetConnection()
    
    private lazy var layerView = PlayerLayerView(player: player)
    private lazy var indicatorView = IndicatorView()
    private lazy var controlsView  = ControlsView()
    private lazy var itemObserver = ItemObserver()
    private lazy var loadingView = IndicatorLoading()
    private lazy var motionManager = MotionManager()
    
    var animator : Animator?
    var modeState : PlayerModeState = .portrait
    var animatable = true
    var recoverFromPortrait = false
    
    var transitionAnimator : TransitionAnimator?
    lazy var transition = Transition()
    lazy var fullVC: FullPlayerViewController = {
        let full = FullPlayerViewController()
        full.transitioningDelegate = transition
        full.modalPresentationStyle = .overFullScreen
        return full
    }()
    
    private var offset : CGPoint = .zero

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    deinit {
        removeAllObserver()
        reachability?.stopNotifier()
    }
    
    func setup() {
        configUI()
        addGestures()
        addObserver()
        reachabilityCallBack()
        registerAsStateSubscriber()
    }
    
    public func reload() {
        
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
        publish(state: .stop(self.indexPath))
    }
    
    public func updateWillChangeTableView(_ tableView : UITableView) {
        offset = tableView.contentOffset
        print(offset)
    }
    
    public func updateDidChangeTableView(_ tableView : UITableView) {
        if let i = indexPath {
            DispatchQueue.main.async {
                tableView.contentOffset = self.offset
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if let cell = tableView.cellForRow(at: i) as? HomeListCell {
                        let container = cell.containerView
                        self.transitionAnimator?.superView = container!
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
//            motionManager.bus = eventBus
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
        default:
            break
        }
    }
    
    func handleLandscape() {
        if plan == .window {
            PlayerUIInterfaceOrientation.shared.current = [.landscapeRight,.portrait]
            let animator = Animator(with: self)
            self.animator = animator
            animator.present(animated: animatable)
        } else {
            if let top = UIApplication.shared.keyWindow?.rootViewController?.topLevelViewController() {
                let animator = TransitionAnimator(with: self)
                transition.animator = animator
                self.transitionAnimator = animator
                top.present(fullVC, animated: true, completion: nil)
            } else {
                fatalError("could not find rootViewController's topLevelViewController")
            }
        }
        modeState = .landscape
        shouldStatusBarHidden = true
    }
    
    func handlePortrait() {
        if plan == .window {
            if animator != nil {
                PlayerUIInterfaceOrientation.shared.current = [.portrait,.landscapeRight]
                animator!.dismiss(animated: animatable)
                modeState = .portrait
                shouldStatusBarHidden = false
            }
        } else {
            fullVC.dismiss(animated: true, completion: nil)
        }
    }
    
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActiveNotification), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    private func removeAllObserver() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
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
                    self.animator?.removeSnapshotView()
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
                    self.animator?.insertSnapshotView()
                    self.animatable = false
                    self.publish(state: .mode(.portrait))
                    self.animatable = true
                    self.recoverFromPortrait = true
                }
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
