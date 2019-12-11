//
//  MemoryCache.swift
//  PlayerView
//
//  Created by 杨志远 on 2019/12/11.
//  Copyright © 2019 BaQiWL. All rights reserved.
//

import Foundation

class MemoryCache {
    static let shared = MemoryCache()
    lazy var cache = NSCache<NSString, NSNumber>()
    
    func setObject(_ obj: NSNumber, forKey key: NSString) {
        cache.setObject(obj, forKey: key)
    }
    
    func object(forKey key: NSString) -> NSNumber? {
        return cache.object(forKey: key)
    }
}
