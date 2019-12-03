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


struct Subsctiption<T> : Hashable {
    var weakBox : WeakBox
    var handler : (T) -> Void
    
    // Equalable
    static func == (lhs: Subsctiption, rhs: Subsctiption) -> Bool {
        return lhs.weakBox.object === rhs.weakBox.object
    }
    // Hashable
    func hash(into hasher: inout Hasher) {
        if let obj = weakBox.object {
            hasher.combine(ObjectIdentifier(obj))
        }
    }
    
}


public class EventBus {
    // global obj
    public static let shared = EventBus()
    // subscriber's set
    typealias WeakSet = Set<Subsctiption>
    // store subscriber
    private var subscribed : [ObjectIdentifier:WeakSet] = [:]
    
    public func add<S : AnyObject,T:AnyObject>(subscriber :S,with handler :@escaping (T) ->Void) {
        let identifier = ObjectIdentifier(T.self)
        var weakSet = subscribed[identifier] ?? []
        let subsctiption = Subsctiption(weakBox: WeakBox(subscriber),handler: handler)
        weakSet.insert(subsctiption)
        subscribed[identifier] = weakSet
    }
    
//    public func notify<T:AnyObject>(value : T) {
//        let type = T.self
//        let identifier = ObjectIdentifier(type)
//        if let subscribers = subscribed[identifier] {
//            for subscriber in subscribers where subscriber.weakBox.object != nil {
//                subscriber.handler(value)
//            }
//        }
//    }
    
//    public func has<T>(subscriber : T,for type : T.Type) -> Bool {
////        guard !(type(of: subscriber as Any) is AnyClass) else {
////            return false
////        }
//        if let weakSet = subscribed[ObjectIdentifier(type)]  {
//            return weakSet.contains {$0 == subscriber as AnyObject}
//        }
//        return false
//    }
    
//    private func cleanup(set : WeakSet) -> WeakSet? {
//        let newSet = set.filter {$0.object != nil}
//        return newSet.isEmpty ? nil : newSet
//    }
}

// weakly holdly an object,such as a subscriber
struct WeakBox {
    weak var object : AnyObject?
    init(_ object : AnyObject) {
        self.object = object
    }
}

//
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
