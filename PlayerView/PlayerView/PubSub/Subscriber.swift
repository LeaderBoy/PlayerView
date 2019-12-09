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

/// A publisher protocol about receive player's current state
/// How to use:
/// first  : Follow PLayerStateSubscriber protocol
/// second : register as an observer by calling becomeStateSubscriber()
/// third  : handle the player's state yourself
public protocol PLayerStateSubscriber {
    /// Receive various state
    /// - Parameter value: player current state
    func receive(_ value : PlayerState)
}

extension PLayerStateSubscriber {
    /// Register as an PlayerState observer,so you can receive state change
    func becomeStateSubscriber() {
        EventBus.shared.add(subscriber: self, for: PLayerStateSubscriber.self)
    }
    /// Unregister PlayerState observer
    func resignStateSubscriber() {
        EventBus.shared.resign(subscriber: self, for: PLayerStateSubscriber.self)
    }
}


public protocol PlayerItemSubscriber {
    /// Receive various state
    /// - Parameter value: player current item state
    func receive(_ item : PlayerItem)
}

extension PlayerItemSubscriber {
    func becomeItemSubscriber() {
        EventBus.shared.add(subscriber: self, for: PlayerItemSubscriber.self)
    }
}









