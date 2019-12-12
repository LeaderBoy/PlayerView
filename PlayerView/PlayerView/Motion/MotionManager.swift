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
//  MotionManager.swift
//  PlayerView
//
//  Created by 杨志远 on 2019/12/12.
//

import UIKit
import CoreMotion


class MotionManager {
    
    var bus : EventBus! {
        didSet {
            registerAsStateSubscriber()
        }
    }
    
    private lazy var motion : CMMotionManager = {
        let manager = CMMotionManager()
        manager.deviceMotionUpdateInterval = 1 / 15.0
        return manager
    }()
    
    private lazy var motionQueue = OperationQueue()
    
    typealias UpdateOrientation = (UIInterfaceOrientationMask) -> Void
    
    private let sensitive = 0.7
    
    var updateOrientation : UpdateOrientation?
    
    private var orientation : UIInterfaceOrientationMask = .portrait
    
    private func startMonitor() {
        motion.startDeviceMotionUpdates(to: motionQueue) { (deviceMotion, error) in
            if let motion = deviceMotion {
                DispatchQueue.main.async {
                    self.update(with: motion)
                }
            }
        }
    }
    
    private func stopMonitor() {
        if motion.isDeviceMotionActive {
            motion.stopDeviceMotionUpdates()
        }
    }
    
    private func update(with deviceMotion: CMDeviceMotion) {
                
        let x = deviceMotion.gravity.x
        let y = deviceMotion.gravity.y
        
        let update = { (newOrientation : UIInterfaceOrientationMask) in
            if self.orientation == newOrientation {
                return
            }
            self.orientation = newOrientation
            self.updateOrientation?(newOrientation)
        }
        
        if fabs(y) > sensitive {
            if y < 0 {
                update(.portrait)
            } else {
                update(.portraitUpsideDown)
            }
        }
        
        if fabs(x) > sensitive {
            if x < 0 {
                update(.landscapeLeft)
            } else {
                update(.landscapeRight)
            }
        }
    }
}

extension MotionManager : PlayerStateSubscriber {
    func receive(state: PlayerState) {
        switch state {
        case .mode(.landscape):
            startMonitor()
        case .mode(.portrait):
            stopMonitor()
        default:
            break
        }
    }
    
    var eventBus: EventBus {
        return bus
    }
}
