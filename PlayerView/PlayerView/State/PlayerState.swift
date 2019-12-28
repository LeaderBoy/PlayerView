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
//  PlayerState.swift
//  PlayerView
//
//  Created by 杨志远 on 2019/12/1.
//

import Foundation
import AVKit

public enum PlayerNetworkState {
    case wwan
    case wifi
    case networkUnReachable
    case timeout
    
    init?(error : Error) {
        if error.isTimeout() {
            self = .timeout
        }else if error.isInternetUnavailable() {
            self = .networkUnReachable
        }else {
            return nil
        }
    }
    
}

/// full screen or not
public enum PlayerModeState {
    case landscape
    case portraitFull
    case portrait
}

/// player state
public enum PlayerState : Equatable {
    case prepare(_ indexPath : IndexPath?)
    case play
    case paused
    case seeking(_ time : TimeInterval)
    case seekDone
    case loading
    case finished
    case bufferFull(_ full : Bool)
    case bufferEmpty(_ empty : Bool)
    case stop(_ indexPath : IndexPath?)
    case error(_ error  : Error)
    case mode(_ mode    : PlayerModeState)
    case network(_ net  : PlayerNetworkState)
    case interrupted(AVAudioSession.InterruptionType)
    case unknown
    
    public static func prepare(at indexPath : IndexPath) -> PlayerState {
        return .prepare(indexPath)
    }
    
    public static func stop(at indexPath : IndexPath) -> PlayerState {
        return .stop(indexPath)
    }
    
    public static func == (lhs : Self,rhs : Self) -> Bool {
        switch (lhs,rhs) {
        case (.prepare(let l),.prepare(let r)) where l == r: return true
        case (.play,.play): return true
        case (.paused,.paused): return true
        case (.seeking(let l),.seeking(let r)) where l == r : return true
        case (.seekDone,.seekDone): return true
        case (.loading,.loading): return true
        case (.finished,.finished): return true
        case (.bufferFull(let l),.bufferFull(let r)) where l == r : return true
        case (.stop(let l),.stop(let r)) where l == r: return true
        case (.error(let l as NSError),.error(let r as NSError)) where l.code == r.code : return true
        case (.mode(let l),.mode(let r))where l == r : return true
        case (.network(let l),.network(let r))where l == r : return true
        case (.bufferEmpty(let l),.bufferEmpty(let r))where l == r : return true
        case (.unknown,.unknown): return true
        case (.interrupted(let l),.interrupted(let r))where l == r : return true
        case (_):return false
        }
    }
}
