//
//  URLImageView.swift
//  PlayerView
//
//  Created by 杨志远 on 2020/1/5.
//  Copyright © 2020 BaQiWL. All rights reserved.
//

import UIKit
import CryptoKit
import CommonCrypto


class ImageDiskCache {
    static let shared = ImageDiskCache()
    
    lazy var path: URL? = {
        if let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first,var urlPath = URL(string: path) {
            urlPath.appendPathComponent("com.disk.images")
            let file = URL(fileURLWithPath: urlPath.path)
            if !FileManager.default.fileExists(atPath: file.path) {
                try! FileManager.default.createDirectory(at: file, withIntermediateDirectories: false, attributes: [:])
            }
            
            return urlPath
        }
        return nil
    }()
    
    func setObject(_ obj: Data, forKey key: String) {
        
        if var fileName = fileURL(for: key) {
            do {
                try obj.write(to: fileName)
                do {
                    /// prevent backup
                    var resourceValues = URLResourceValues()
                    resourceValues.isExcludedFromBackup = false
                    try fileName.setResourceValues(resourceValues)
                } catch let e {
                    print("disable backup failed:\(e)")
                }
            } catch let e {
                print("file write to disk failed:\(e)")
            }
        }
    }
    
    func object(forKey key: String) -> UIImage? {
        if let fileName = fileURL(for: key) {
            if FileManager.default.fileExists(atPath: fileName.path) {
                do {
                    let data = try Data(contentsOf: fileName)
                    return UIImage(data: data)
                } catch let e {
                    print("file search failed:\(e)")
                    return nil
                }
            }
            return nil
        }
        return nil
    }
    
    func object(forKey key: String,completed:@escaping (UIImage?) ->Void) {
        DispatchQueue.global(qos: .userInteractive).async {
            if let fileName = self.fileURL(for: key) {
                if FileManager.default.fileExists(atPath: fileName.path) {
                    do {
                        let data = try Data(contentsOf: fileName)
                        completed(UIImage(data: data))
                    } catch let e {
                        print("file search failed:\(e)")
                        completed(nil)
                    }
                }
                completed(nil)
            }
        }
    }
    
    func removeObject(for key: NSString) {
        
    }
    
    func removeAll() {
        
    }
    
    func fileURL(for key : String) -> URL? {
        if let path = self.path {
            let md5Key = key.md5Value
            let file = URL(fileURLWithPath: path.appendingPathComponent(md5Key).path)
            return file
        }
        return nil
    }
}


extension String {
    var md5Value: String {
        if #available(iOS 13.0, *) {
            let digest = Insecure.MD5.hash(data: self.data(using: .utf8) ?? Data())
            return digest.map {
                String(format: "%02hhx", $0)
            }.joined()
        } else {
            let length = Int(CC_MD5_DIGEST_LENGTH)
            var digest = [UInt8](repeating: 0, count: length)

            if let d = self.data(using: .utf8) {
                _ = d.withUnsafeBytes { body -> String in
                    CC_MD5(body.baseAddress, CC_LONG(d.count), &digest)

                    return ""
                }
            }
            return (0 ..< length).reduce("") {
                $0 + String(format: "%02x", digest[$1])
            }
        }
    }
}

class ImageMemoryCache {
    static let shared = ImageMemoryCache()
    lazy var cache = NSCache<NSString, UIImage>()
    
    func md5Key(for key : NSString) -> NSString {
        let newKey = key as String
        return newKey.md5Value as NSString
    }
    
    func setObject(_ obj: UIImage, forKey key: NSString) {
        cache.setObject(obj, forKey: md5Key(for: key))
    }
    
    func object(forKey key: NSString) -> UIImage? {
        return cache.object(forKey: md5Key(for: key))
    }
    
    func removeObject(for key: NSString) {
        cache.removeObject(forKey: md5Key(for: key))
    }
    
    func removeAll() {
        cache.removeAllObjects()
    }
}

class URLImageView: UIImageView {
    
    let memoryCache = ImageMemoryCache.shared
    let diskCache = ImageDiskCache.shared
    var key : String = ""
    var animated : Bool = false
    
    func load(url : URL,animated : Bool,completed:((Bool,Error?) ->Void)? = nil) {
        key = url.absoluteString
        self.animated = animated
        image = nil
        
        if let image = memoryCache.object(forKey: key as NSString) {
            self.image = image
            print("memory")
            return
        }
        
        if let image = diskCache.object(forKey: key) {
            self.image = image
            memoryCache.setObject(image, forKey: key as NSString)
            print("disk")
            return
        }
        
        /// cancel default cache
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60.0)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print(error!)
                completed?(false,error!)
                return
            }
            if self.key == url.absoluteString {
                if let imageData = data,let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        if self.animated {
                            self.alpha = 0
                            UIView.animate(withDuration: 0.25, animations: {
                                self.image = image
                                self.alpha = 1.0
                            }) { (_) in
                            }
                        } else {
                            self.image = image
                        }
                        
                        completed?(true,nil)
                        self.memoryCache.setObject(image, forKey: self.key as NSString)
                        self.diskCache.setObject(imageData, forKey: self.key)
                    }
                }
            }
        }.resume()
    }
}
