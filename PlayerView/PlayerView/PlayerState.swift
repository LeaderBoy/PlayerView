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

public enum PlayerNetworkState {
    case wwan
    case wifi
    case networkUnReachable
    case timeout
}

/// full screen or not
public enum PlayerModeState {
    case landscape
    case portraitFull
    case portrait
}

/// player state
public enum PlayerState : Equatable {
    case prepare
    case playing
    case paused
    case seeking(_ time : TimeInterval)
    case seekDone
    case loading
    case finished
    case bufferFull(_ full : Bool)
    case stop
    case error(_ error  : Error)
    case mode(_ mode    : PlayerModeState)
    case network(_ net  : PlayerNetworkState)
    case unknown
    case underlying(item : PlayerItem)
    
    public static func == (lhs : Self,rhs : Self) -> Bool {
        switch (lhs,rhs) {
        case (.prepare,.prepare): return true
        case (.playing,.playing): return true
        case (.paused,.paused): return true
        case (.seeking(let l),.seeking(let r)) where l == r : return true
        case (.seekDone,.seekDone): return true
        case (.loading,.loading): return true
        case (.finished,.finished): return true
        case (.bufferFull(let l),.bufferFull(let r)) where l == r : return true
        case (.stop,.stop): return true
        case (.error(let l as NSError),.error(let r as NSError)) where l.code == r.code : return true
        case (.mode(let l),.mode(let r))where l == r : return true
        case (.network(let l),.network(let r))where l == r : return true
        case (.unknown,.unknown): return true
        case (.underlying(let l),.underlying(let r))where l == r : return true
        case (_):return false
        }
    }
}


extension Error {
    func isTimeout() -> Bool {
        let nsError = self as NSError
        return nsError.isTimeout()
    }
    
    func isInternetUnavailable() -> Bool {
        let nsError = self as NSError
        return nsError.isInternetUnavailable()
    }
    
    func isResourceUnavailable() -> Bool {
        let nsError = self as NSError
        return nsError.isResourceUnavailable()
    }
}

extension NSError {
    func isURLErrorDomain() -> Bool {
        return self.domain == NSURLErrorDomain
    }
    
    func isTimeout() -> Bool {
        return self.code == NSURLErrorTimedOut
    }
    
    func isInternetUnavailable() -> Bool {
        return self.code == NSURLErrorNotConnectedToInternet
    }
    
    func isUnsupportedURL() -> Bool {
        return self.code == NSURLErrorUnsupportedURL
    }
    
    func isResourceUnavailable() -> Bool {
        self.code == NSURLErrorResourceUnavailable
    }
}

