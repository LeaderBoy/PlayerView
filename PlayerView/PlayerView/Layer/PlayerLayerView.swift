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
    
    var state : PlayerState = .prepare {
        didSet {
            handleState(state)
        }
    }
    
    var stateUpdater : PlayerStateUpdater?
    
    var player : AVPlayer
    
    var isReadyToPlay = false
    var isSeekingInProgress = false
    var targetTime : CMTime = .zero
    
    
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
    }
    
    public func play() {
        player.play()
    }
    
    public func pause() {
        player.pause()
    }
    
    public func replay() {
        seekToTime(0) { done in
            
        }
    }
    
    public func stop() {
        pause()
        player.replaceCurrentItem(with: nil)
    }
    
//    public func seekToTime(_ time : TimeInterval,completionHandler: ((Bool) -> Void)? = nil) {
////        if duration == 0 {
////            return
////        }
////        if time > duration {
////            return
////        }
//
////        if !isReadyToPlay {
////            return
////        }
//
////        isSeekingInProgress = true
//
////        let seekTimeInProgress = targetTime
////        player.seek(to: seekTimeInProgress, toleranceBefore: .zero,toleranceAfter: .zero, completionHandler:{ (isFinished:Bool) -> Void in
////            if CMTimeCompare(seekTimeInProgress, self.targetTime) == 0 {
////                self.isSeekingInProgress = false
////            } else{
////                self.trySeekToChaseTime()
////            }
////        })
//
////        let time = CMTimeMake(value: Int64(600.0 * time), timescale: 600)
//
//    }
    
    func seekToTime(_ time:TimeInterval,completionHandler: ((Bool) -> Void)? = nil) {
        pause()
        
       let newChaseTime = CMTimeMake(value: Int64(600.0 * time), timescale: 600)
        
       if CMTimeCompare(newChaseTime, targetTime) != 0 {
           targetTime = newChaseTime;
           if !isSeekingInProgress {
               trySeekToChaseTime(completionHandler: completionHandler)
           }
       }
    }
    
    func trySeekToChaseTime(completionHandler: ((Bool) -> Void)? = nil) {
        if isReadyToPlay {
            actuallySeekToTime(completionHandler: completionHandler)
        }
    }
    
    func actuallySeekToTime(completionHandler: ((Bool) -> Void)? = nil) {
        isSeekingInProgress = true
        let seekTimeInProgress = targetTime
        player.seek(to: seekTimeInProgress, toleranceBefore: CMTime.zero,toleranceAfter: .zero, completionHandler:{ (isFinished:Bool) -> Void in
            if CMTimeCompare(seekTimeInProgress, self.targetTime) == 0 {
                self.isSeekingInProgress = false
                
                if isFinished {
                    print("完成seek:\(self.player.timeControlStatus.rawValue)")
                    self.play()
                    completionHandler?(true)
                }else {
                    print("seek 失败")
                }
                
            } else {
                self.trySeekToChaseTime(completionHandler: completionHandler)
            }
        })
    }
    
    func handleState(_ state : PlayerState) {
        switch state {
        case .prepare:
            break
        case .playing:
            play()
        case .paused:
            pause()
        case .seeking(let time):
            seekToTime(time) { [weak self](done) in
                guard let self = self else {
                    return
                }
                self.stateUpdater?(.seekDone)
            }
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
