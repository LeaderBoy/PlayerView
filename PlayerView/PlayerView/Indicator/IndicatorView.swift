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
//  IndicatorView.swift
//  PlayerView
//
//  Created by 杨志远 on 2019/11/20.
//

import UIKit

class IndicatorView: UIView {
        
    var isBufferFull = false
    var isBufferEmpty = false
    
    @IBOutlet weak var customView: UIView!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var indicatorStackView: UIStackView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
        
    var bus : EventBus! {
        didSet {
            registerAsStateSubscriber()
        }
    }
    
    var state : PlayerState = .unknown
    
    var networkState : PlayerNetworkState?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        fromNib()
        hide()
    }
 
    func show() {
        if !self.isHidden {
            return
        }
        isHidden = false
    }
    
    func hide() {
        if self.isHidden {
            return
        }
        isHidden = true
    }
    
    func handle(state : PlayerState) {
        reloadState(state: state)
    }

    func handleMode(state : PlayerModeState) {
        
    }
    
    func reloadState(state : PlayerState) {
        switch state {
        case .bufferFull(let isFull):
            isBufferFull = isFull
        case .bufferEmpty(let isEmpty):
            isBufferEmpty = isEmpty
        case .error(let e):
            errorView(e)
        case .network(let state):
            handleNetworkState(state)
        default:
            break
        }
    }
    
    func errorView(_ error : Error) {
        leftButton.isHidden = false
        rightButton.isHidden = true
        
        
    }
    
    func handleNetworkState(_ state : PlayerNetworkState) {
        rightButton.isHidden = true
        leftButton.isHidden = false
        var message : String = ""
        var title = ""
        switch state {
        case .networkUnReachable:
            title = NSLocalizedString("a", comment: "retry again")
            message = NSLocalizedString("player-networkUnreachable", comment: "Network connection has been lost")
        default:
            break
//        case .timeout:
//        case .wifi:
//        case .wwan:
//            rightButton.isHidden = false
        }
        
        label.text = message
        leftButton.setTitle(title, for: .normal)
    }
    
    
}

extension IndicatorView : PlayerStateSubscriber {
    var eventBus: EventBus {
        return bus
    }
    
    func receive(_ value: PlayerState) {
        handle(state: value)
    }
    
}
