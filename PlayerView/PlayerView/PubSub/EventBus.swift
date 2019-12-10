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
//  EventBus.swift
//  PlayerView
//
//  Created by 杨志远 on 2019/12/2.
//

import Foundation

public protocol EventBusIdentifiable {
    var eventBus : EventBus { get }
}


public class EventBus {
    /// weakBox's set
    typealias WeakSet = Set<WeakBox>
    /// a Dictionary for store weakSet
    private var subscribed : [ObjectIdentifier:WeakSet] = [:]
    
    /// Add subscriber and event type
    /// - Parameter subscriber: subscriber,subscriber must be AnyObject
    /// - Parameter event: with the purpose of get unique identifier by ObjectIdentifier(x: Any.Type)
    public func add<T,E>(subscriber :T,for event : E.Type) {
        let identifier = ObjectIdentifier(event)
        let weakSet = subscribed[identifier] ?? []
        // update first to prevent insert same value
        var newSet = update(set: weakSet) ?? []
        let weakBox = WeakBox(subscriber as AnyObject)
        newSet.insert(weakBox)
        subscribed[identifier] = newSet
    }
    
    public func resign<T,E>(subscriber :T,for event : E.Type) {
        let identifier = ObjectIdentifier(event)
        var weakSet = subscribed[identifier] ?? []
        let weakBox = WeakBox(subscriber as AnyObject)
        weakSet.remove(weakBox)
        subscribed[identifier] = update(set: weakSet)
    }
    
    /// notify event register to excute closure
    /// - Parameter event: event type
    /// - Parameter closure: a closure that the register should excute
    public func notify<T>(event:T.Type, closure: @escaping (T) -> ()) {
        let identifier = ObjectIdentifier(event)
        if let subscribers = subscribed[identifier] {
            for subscriber in subscribers.lazy.compactMap({$0.object as? T}) {
                closure(subscriber)
            }
        }
    }
    
    /// clean up nil object from subscribed
    /// - Parameter set: a new WeakSet without nil object
    fileprivate func update(set: WeakSet) -> WeakSet? {
        let newSet = set.filter { $0.object != nil }
        return newSet.isEmpty ? nil : newSet
    }
}

/// weakly holdly an object to prevent retain cycle,such as a subscriber
struct WeakBox {
    weak var object : AnyObject?
    init(_ object : AnyObject) {
        self.object = object
    }
}

/// WeakBox is nested in Set,so it need to follow Hashable protocol
extension WeakBox : Hashable {
    // Equalable
    static func == (lhs: WeakBox, rhs: WeakBox) -> Bool {
        return lhs.object === rhs.object
    }
    
    static func == (lhs: WeakBox, rhs: AnyObject) -> Bool {
        return lhs.object === rhs
    }
    
    // Hashable
    func hash(into hasher: inout Hasher) {
        if let obj = object {
            hasher.combine(ObjectIdentifier(obj))
        }
    }
}
