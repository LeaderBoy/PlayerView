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


/// error state
enum PlayerErrorState {
    case networkUnReachable
    case timeout
    case failed
    case error(_ error : Error)
}

/// full screen or not
enum PlayerStateMode {
    case landscapeFull
    case portraitFull
    case small
}


enum PlayerState {
    case playing
    case paused
    case error(_ error : PlayerErrorState)
    case mode(_ mode : PlayerStateMode)
}

class PlayerLayerView: UIView {
    var player : AVPlayer
    
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
    }
    
    func initialConfig() {

    }
    
    public func play() {
        player.play()
    }
    
    public func pause() {
        player.pause()
    }
    
    public func replay() {
        seekToTime(0) { done in
            if done {
                self.play()
            }
        }
    }
    
    public func stop() {
        pause()
        player.replaceCurrentItem(with: nil)
    }
    
    func seekToTime(_ time : TimeInterval,completionHandler: @escaping (Bool) -> Void) {
        if duration == 0 {
            return
        }
        if time > duration {
            return
        }
        let time = CMTimeMake(value: Int64(600.0 * time), timescale: 600)
        player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero, completionHandler: completionHandler)
    }
}
