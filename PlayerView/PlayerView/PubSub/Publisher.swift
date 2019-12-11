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
//  Publisher.swift
//  PlayerView
//
//  Created by 杨志远 on 2019/11/30.
//

import Foundation

/// A publisher protocol about dispatch player's current state
/// How to use:
/// first : Follow PlayerStatePublisher protocol
/// second : when you need to change player's state,just call publish(.yourstate)
public protocol PlayerStatePublisher : EventBusIdentifiable {
    /// dispatch player's current state
    /// - Parameter state: player state
    func publish(state : PlayerState)
}

extension PlayerStatePublisher {
    /// The default implementation,don't implement't it again
    /// - Parameter value: player current state
    public func publish(state: PlayerState) {
        eventBus.notify(event: PlayerStateSubscriber.self) { (subscriber) in
            subscriber.receive(state:state)
        }
    }
}


public protocol PlayerItemPublisher : EventBusIdentifiable {
    /// dispatch player's current state
    /// - Parameter value: player state
    func publish(item : PlayerItem)
}

extension PlayerItemPublisher {
    /// The default implementation,don't implement't it again
    /// - Parameter value: player current item state
    public func publish(item: PlayerItem) {
        eventBus.notify(event: PlayerItemSubscriber.self) { (subscriber) in
            subscriber.receive(item)
        }
    }
}








