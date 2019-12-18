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
//  Error + NSError.swift
//  PlayerView
//
//  Created by 杨志远 on 2019/12/18.
//

import Foundation

extension Error {
    public func isTimeout() -> Bool {
        let nsError = self as NSError
        return nsError.isTimeout()
    }
    
    public func isInternetUnavailable() -> Bool {
        let nsError = self as NSError
        return nsError.isInternetUnavailable()
    }
    
    public func isResourceUnavailable() -> Bool {
        let nsError = self as NSError
        return nsError.isResourceUnavailable()
    }
}

extension NSError {
    fileprivate func isURLErrorDomain() -> Bool {
        return self.domain == NSURLErrorDomain
    }
    
    fileprivate func isTimeout() -> Bool {
        return self.code == NSURLErrorTimedOut
    }
    
    fileprivate func isInternetUnavailable() -> Bool {
        return self.code == NSURLErrorNotConnectedToInternet
    }
    
    fileprivate func isUnsupportedURL() -> Bool {
        return self.code == NSURLErrorUnsupportedURL
    }
    
    fileprivate func isResourceUnavailable() -> Bool {
        self.code == NSURLErrorResourceUnavailable
    }
}
