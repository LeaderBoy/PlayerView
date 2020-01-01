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
//  PlayerLayerView.swift
//  PlayerView
//
//  Created by 杨志远 on 2019/11/20.
//

import UIKit
import AVKit


class PlayerLayerView: UIView {
    var player : AVPlayer
    
    var bus : EventBus! {
        didSet {
            registerAsStateSubscriber()
        }
    }
    
    var isReadyToDisplay = false {
        didSet {
            playerLayer.isHidden = !isReadyToDisplay
        }
    }
    
    var disableCacheProgress = false
    
    var videoGravity : AVLayerVideoGravity = .resizeAspect
    
    private var url : String?
    private var isReadyToPlay = false
    private var isSeekingInProgress = false
    private var chaseTime : CMTime = .zero
    private let isReadyForDisplayKeyPath = #keyPath(AVPlayerLayer.isReadyForDisplay)
    private var isReadyForDisplayContext = 0
    private let cache = MemoryCache.shared
    private var state : PlayerState = .unknown
    
    var playerLayer : AVPlayerLayer {
        return self.layer as! AVPlayerLayer
    }
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.classForCoder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(player : AVPlayer) {
        self.player = player
        super.init(frame: .zero)
        playerLayer.player = player
        playerLayer.videoGravity = videoGravity
        playerLayer.isHidden = true
        observerFirstFrame()
    }
    
    deinit {
        removeObserverFirstFrame()
    }
    
    public func switchVideoGravity() {
        if playerLayer.videoGravity == .resizeAspect {
            playerLayer.videoGravity = .resizeAspectFill
        }else {
            playerLayer.videoGravity = .resizeAspect
        }
    }
    
    public func play() {
        player.play()
    }
    
    public func pause() {
        player.pause()
    }
    
    public func replay(completionHandler: ((Bool) -> Void)? = nil) {
        seekToTime(0, completionHandler: completionHandler)
    }
    
    public func stop() {
        pause()
        /// condition: poor network
        /// dismiss from a viewController
        /// deinit was called but player still play
        player.currentItem?.cancelPendingSeeks()
        player.currentItem?.asset.cancelLoading()
        player.replaceCurrentItem(with: nil)
    }
    
    /// https://developer.apple.com/library/archive/qa/qa1820/_index.html
    public func seekToTime(_ time:TimeInterval,completionHandler: ((Bool) -> Void)? = nil) {
        let timeScale = player.currentItem?.asset.duration.timescale ?? 600
        let newChaseTime = CMTimeMakeWithSeconds(time, preferredTimescale: timeScale)
        if CMTimeCompare(newChaseTime, chaseTime) != 0 {
            chaseTime = newChaseTime;
            if !isSeekingInProgress {
                trySeekToChaseTime(completionHandler: completionHandler)
            }
        }
    }
    
    private func trySeekToChaseTime(completionHandler: ((Bool) -> Void)? = nil) {
        if isReadyToPlay {
            actuallySeekToTime(completionHandler: completionHandler)
        }else {
            print("player is not ready to seek")
        }
    }
    
    private func actuallySeekToTime(completionHandler: ((Bool) -> Void)? = nil) {
        isSeekingInProgress = true
        let seekTimeInProgress = chaseTime
        player.seek(to: seekTimeInProgress, toleranceBefore: CMTime.zero,toleranceAfter: .zero, completionHandler:{ (isFinished:Bool) -> Void in
            if CMTimeCompare(seekTimeInProgress, self.chaseTime) == 0 {
                self.isSeekingInProgress = false
                completionHandler?(true)
            } else {
                self.trySeekToChaseTime(completionHandler: completionHandler)
            }
        })
    }
    
    private func handle(state : PlayerState) {
        switch state {
        case .prepare:
            break
        case .play:
            isReadyToPlay = true
            seekToCachedProgress()
            play()
        case .paused:
            pause()
        case .seeking(let time):
            seekToTime(time) { [weak self](done) in
                guard let self = self else {
                    return
                }
                self.publish(state: .seekDone)
            }
        case .stop:
            cachePlayProgress()
            resetVariables()
            stop()
        default:
            break
        }
    }
    
    private func resetVariables() {
        state = .unknown
        isReadyToPlay = false
        isReadyToDisplay = false
        isSeekingInProgress = false
        chaseTime = .zero
        url = nil
    }
    
    func cachePlayProgress() {
        if disableCacheProgress {
            return
        }
        
        if let key = getVideoUrl(from: player) {
            let seconds = CMTimeGetSeconds(player.currentTime())
            if seconds >= 5.0 {
                // for show original frame
                let number = NSNumber(floatLiteral: seconds - 3)
                cache.setObject(number, forKey: key)
            }
        }
    }
    
    func seekToCachedProgress() {
        if disableCacheProgress {
            return
        }
        
        if let key = getVideoUrl(from: player) {
            if let time = cache.object(forKey: key),let item = player.currentItem {
                let duration = CMTimeGetSeconds(item.duration)
                let seekTime = time.doubleValue
                if seekTime < duration {
                    publish(state: .seeking(seekTime))
                }
            }
        }
    }
    
    private func observerFirstFrame() {
        playerLayer.addObserver(self, forKeyPath: isReadyForDisplayKeyPath, options: .new, context: &isReadyForDisplayContext)
    }
    
    private func removeObserverFirstFrame() {
        playerLayer.removeObserver(self, forKeyPath: isReadyForDisplayKeyPath, context: &isReadyForDisplayContext)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let itemContext = context,let itemKeyPath = keyPath,let newChange = change else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if itemContext == &isReadyForDisplayContext && itemKeyPath == isReadyForDisplayKeyPath {
            guard  let value = newChange[.newKey] as? NSNumber else{
                return
            }
            isReadyToDisplay = value.boolValue
        }
    }
    
    func getVideoUrl(from player : AVPlayer) -> NSString? {
        if let urlString = self.url {
            return urlString as NSString
        }
        if let asset = player.currentItem?.asset {
            if let urlAsset = asset as? AVURLAsset {
                let url = urlAsset.url.absoluteString
                self.url = url
                return url as NSString
            }
        }
        return nil
    }
}

extension PlayerLayerView : PlayerStateSubscriber {
    var eventBus: EventBus {
        return bus
    }
    
    func receive(state: PlayerState) {
        if self.state == state {
            return
        }
        handle(state:state)
    }
}

extension PlayerLayerView : PlayerStatePublisher {}
