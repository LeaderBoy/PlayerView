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
//  Subscriber.swift
//  PlayerView
//
//  Created by 杨志远 on 2019/11/30.
//

import Foundation


protocol Subscriber : AnyObject {
    associatedtype Input
    func receive(_ value : Input)
}

/// weakly hold an object
struct Weak<Object : AnyObject> {
    weak var value : Object?
}

struct SubscribedValue<T> {
    typealias Subsctiption = (object : Weak<AnyObject>,handler :(T) -> Void)
    
    private var subscriptions : [Subsctiption] = []
    
    var value : T {
        didSet {
            for (object,handler) in subscriptions where object.value != nil {
                handler(value)
            }
        }
    }
    
    init(value : T) {
        self.value = value
    }
    
    mutating func subscribe(_ object : AnyObject,with handler :@escaping (T) ->Void) {
        subscriptions.append((Weak(value: object),handler))
    }
    
    mutating func cleanupSubscriptions() {
        subscriptions = subscriptions.filter {$0.object.value != nil}
    }
}





