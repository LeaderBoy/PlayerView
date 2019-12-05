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
    
    var state : PlayerState = .unknown
    var player : AVPlayer
    
    var isReadyToPlay = false
    var isPausedByUser = false
    var isSeekingInProgress = false
    var chaseTime : CMTime = .zero
    
    var playerLayer : AVPlayerLayer {
        return self.layer as! AVPlayerLayer
    }
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.classForCoder()
    }
    
    var duration : TimeInterval = 0

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(player : AVPlayer) {
        self.player = player
        super.init(frame: .zero)
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        becomeSubscriber()
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
        player.replaceCurrentItem(with: nil)
    }
    
    /// https://developer.apple.com/library/archive/qa/qa1820/_index.html
    public func seekToTime(_ time:TimeInterval,completionHandler: ((Bool) -> Void)? = nil) {
        let timeScale = player.currentItem?.asset.duration.timescale ?? 600
        let newChaseTime = CMTimeMakeWithSeconds(time, preferredTimescale: timeScale)
        // when seek to zero,it always paued even called play,
        if newChaseTime == .zero {
            if !self.isPausedByUser {
                self.play()
            }
        }else {
            pause()
        }
        
        if CMTimeCompare(newChaseTime, chaseTime) != 0 {
            chaseTime = newChaseTime;
            if !isSeekingInProgress {
                trySeekToChaseTime(completionHandler: completionHandler)
            }else {
                print("正在seek")
            }
        }
    }
    
    private func trySeekToChaseTime(completionHandler: ((Bool) -> Void)? = nil) {
        if isReadyToPlay {
            actuallySeekToTime(completionHandler: completionHandler)
        }
    }
    
    private func actuallySeekToTime(completionHandler: ((Bool) -> Void)? = nil) {
        isSeekingInProgress = true
        let seekTimeInProgress = chaseTime
        player.seek(to: seekTimeInProgress, toleranceBefore: CMTime.zero,toleranceAfter: .zero, completionHandler:{ (isFinished:Bool) -> Void in
            if CMTimeCompare(seekTimeInProgress, self.chaseTime) == 0 {
                if !self.isPausedByUser {
                    // prevent paused by seek
                    self.play()
                }
                self.isSeekingInProgress = false
                completionHandler?(true)
            } else {
                self.trySeekToChaseTime(completionHandler: completionHandler)
            }
        })
    }
    
    func handle(state : PlayerState) {
        switch state {
        case .prepare:
            break
        case .playing:
            play()
            isPausedByUser = false
        case .paused:
            pause()
            isPausedByUser = true
        case .seeking(let time):
            seekToTime(time) { [weak self](done) in
                guard let self = self else {
                    return
                }
                self.publish(.seekDone)
            }
        case .underlying(let item) where item == .status(.readyToPlay):
            isReadyToPlay = true
        default:
            break
        }
    }
    
    func switchVideoGravity() {
        if playerLayer.videoGravity == .resizeAspect {
            playerLayer.videoGravity = .resizeAspectFill
        }else {
            playerLayer.videoGravity = .resizeAspect
        }
    }
}


extension PlayerLayerView : StateSubscriber {
    func receive(_ value: PlayerState) {
        if state == value {
            return
        }
        handle(state:value)
    }
}

extension PlayerLayerView : StatePublisher {}
