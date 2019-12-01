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
//  Reachability.swift
//  PlayerView
//
//  Created by 杨志远 on 2019/11/21.
//
// inspire by https://www.invasivecode.com/weblog/network-reachability-in-swift/?doing_wp_cron=1476774809.5112760066986083984375 and https://github.com/ashleymills/Reachability.swift/blob/master/Sources/Reachability.swift
// I change it to Swift5 style

import SystemConfiguration
import Foundation

extension Notification.Name {
    public static let ReachabilityDidChanged = Notification.Name("ReachabilityDidChangeNotification")
}

public class Reachability: NSObject {
    public enum Status {
        case unReachable
        case wifi
        case wwan
    }
    
    public typealias StatusDidChanged = (Status) -> Void
    public var statusDidChanged : StatusDidChanged?
    
    private var networkReachability : SCNetworkReachability?
    private var notifying : Bool = false
    private var flags : SCNetworkReachabilityFlags {
        var flags = SCNetworkReachabilityFlags(rawValue: 0)
        if let reachability = networkReachability, withUnsafeMutablePointer(to: &flags, { SCNetworkReachabilityGetFlags(reachability, UnsafeMutablePointer($0)) }) == true {
            return flags
        } else {
            return []
        }
    }
    
    var currentStatus: Status {
     
        if flags.contains(.reachable) == false {
            // The target host is not reachable.
            return .unReachable
        }
        else if flags.contains(.isWWAN) == true {
            // WWAN connections are OK if the calling application is using the CFNetwork APIs.
            return .wwan
        }
        else if flags.contains(.connectionRequired) == false {
            // If the target host is reachable and no connection is required then we'll assume that you're on Wi-Fi...
            return .wifi
        }
        else if (flags.contains(.connectionOnDemand) == true || flags.contains(.connectionOnTraffic) == true) && flags.contains(.interventionRequired) == false {
            // The connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs and no [user] intervention is needed
            return .wifi
        }
        else {
            return .unReachable
        }
    }
    
    var isReachable: Bool {
        switch currentStatus {
        case .unReachable:
            return false
        case .wifi, .wwan:
            return true
        }
    }
     
    init?(hostName : String) {
        guard let name = (hostName as NSString).utf8String,
            let networkReachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, name)
            else { return nil }
        self.networkReachability = networkReachability
        super.init()
    }
    
    init?(hostAddress : sockaddr_in) {
        var address = hostAddress
        
        guard let defaultRouteReachability = withUnsafePointer(to: &address, {
                   $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                   SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, $0)
               }
           }) else {
            return nil
        }
        networkReachability = defaultRouteReachability
        super.init()
        
        if networkReachability == nil {
            return nil
        }
    }
    
    public static func forInternetConnection() -> Reachability? {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        return Reachability(hostAddress: zeroAddress)
    }
     
    public static func forLocalWiFi() -> Reachability? {
        var localWifiAddress = sockaddr_in()
        localWifiAddress.sin_len = UInt8(MemoryLayout.size(ofValue: localWifiAddress))
        localWifiAddress.sin_family = sa_family_t(AF_INET)
        // IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0 (0xA9FE0000).
        localWifiAddress.sin_addr.s_addr = 0xA9FE0000
        return Reachability(hostAddress: localWifiAddress)
    }
    
    @discardableResult
    public func startNotifier() -> Bool {
     
        guard notifying == false else {
            return false
        }
        
        let weakifiedReachability = ReachabilityWeak(reachability: self)
        let opaqueWeakifiedReachability = Unmanaged<ReachabilityWeak>.passUnretained(weakifiedReachability).toOpaque()
     
        var context = SCNetworkReachabilityContext(
            version: 0,
            info: UnsafeMutableRawPointer(opaqueWeakifiedReachability),
            retain: { (info: UnsafeRawPointer) -> UnsafeRawPointer in
                let unmanagedWeakifiedReachability = Unmanaged<ReachabilityWeak>.fromOpaque(info)
                _ = unmanagedWeakifiedReachability.retain()
                return UnsafeRawPointer(unmanagedWeakifiedReachability.toOpaque())
            },
            release: { (info: UnsafeRawPointer) -> Void in
                let unmanagedWeakifiedReachability = Unmanaged<ReachabilityWeak>.fromOpaque(info)
                unmanagedWeakifiedReachability.release()
            },
            copyDescription: { (info: UnsafeRawPointer) -> Unmanaged<CFString> in
                let unmanagedWeakifiedReachability = Unmanaged<ReachabilityWeak>.fromOpaque(info)
                let weakifiedReachability = unmanagedWeakifiedReachability.takeUnretainedValue()
                let description = weakifiedReachability.reachability?.description ?? "nil"
                return Unmanaged.passRetained(description as CFString)
            }
        )
     
        guard let reachability = networkReachability, SCNetworkReachabilitySetCallback(reachability, { (target: SCNetworkReachability, flags: SCNetworkReachabilityFlags, info: UnsafeMutableRawPointer?) in
            if let currentInfo = info {
                let infoObject = Unmanaged<ReachabilityWeak>.fromOpaque(currentInfo).takeUnretainedValue()
                
                if let weakReachability = infoObject.reachability {
                    NotificationCenter.default.post(name: .ReachabilityDidChanged, object: weakReachability)
                    weakReachability.statusDidChanged?(weakReachability.currentStatus)
                }
            }
        }, &context) == true else { return false }
     
        guard SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue) == true else { return false }
     
        notifying = true
        return notifying
    }
    
    public func stopNotifier() {
        if let reachability = networkReachability, notifying == true {
            SCNetworkReachabilityUnscheduleFromRunLoop(reachability, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode as! CFString)
            notifying = false
        }
    }
    
    deinit {
        stopNotifier()
    }
     
}

private class ReachabilityWeak {
    weak var reachability: Reachability?
    init(reachability: Reachability) {
        self.reachability = reachability
    }
}
