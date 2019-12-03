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
//  StatePublisher.swift
//  PlayerView
//
//  Created by 杨志远 on 2019/12/1.
//

import Foundation


public protocol StateSubscriber : Subscriber {
    associatedtype Input = PlayerState
}

extension Subscriber {
    func becomeSubscriber() {
        EventBus.shared.add(subscriber: self, event: Input.self) { (input) in
            self.receive(input)
        }
    }
}

//extension StateSubscriber where Input == PlayerState {
//    func becomeSubscriber() {
//        PlayerStatePublisher.shared.receive(subscriber: self)
//    }
//}

protocol StatePublisher : AnyObject, Publisher {
    associatedtype Output = PlayerState
//    var current : Output { get set }
}

extension StatePublisher {
    func publish(_ value : PlayerState) {
        // send value
        PlayerStatePublisher.shared.current = value
    }
}

class PlayerStatePublisher : StatePublisher {

    static let shared = PlayerStatePublisher()
    
    var current: PlayerState {
        get {
            subscribed.value
        }
        set {
            subscribed.value = newValue
        }
    }
    
    private var subscribed : SubscribedValue<PlayerState>
    
    init() {
        subscribed = .init(value: .prepare)
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, Output == S.Input {
        subscribed.subscribe(subscriber) { state in
            subscriber.receive(state)
        }
    }
}
