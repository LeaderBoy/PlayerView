//
//  URLImageView.swift
//  PlayerView
//
//  Created by 杨志远 on 2020/1/5.
//  Copyright © 2020 BaQiWL. All rights reserved.
//

import UIKit

class ImageCache {
    static let shared = ImageCache()
    lazy var cache = NSCache<NSString, UIImage>()
    
    func setObject(_ obj: UIImage, forKey key: NSString) {
        cache.setObject(obj, forKey: key)
    }
    
    func object(forKey key: NSString) -> UIImage? {
        return cache.object(forKey: key)
    }
    
    func removeObject(for key: NSString) {
        cache.removeObject(forKey: key)
    }
    
    func removeAll() {
        cache.removeAllObjects()
    }
}

class URLImageView: UIImageView {
    
    let cache = ImageCache.shared
        
    var key : String = ""
    
    func load(url : URL) {
        key = url.absoluteString
        image = nil
        
        if let image = cache.object(forKey: key as NSString) {
            self.image = image
            return
        }
        
        /// cancel default cache
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60.0)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            if self.key == url.absoluteString {
                if let imageData = data,let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self.image = image
                        self.cache.setObject(image, forKey: self.key as NSString)
                    }
                }
            }
        }.resume()
    }
}
