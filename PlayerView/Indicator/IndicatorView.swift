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
    var indexPath : IndexPath?
    
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
        backgroundColor = UIColor(white: 0, alpha: 0.5)
        hide()
    }
 
    func show() {
        if !isHidden {
            return
        }
        isHidden = false
    }
    
    func hide() {
        if isHidden {
            return
        }
        isHidden = true
    }
    
    func resetVariables() {
        isBufferEmpty = false
        isBufferFull = false
        indexPath = nil
        hide()
    }
    
    func handle(state : PlayerState) {
        reloadState(state: state)
    }

    func reloadState(state : PlayerState) {
        switch state {
        case .prepare(let indexPath):
            self.indexPath = indexPath
        case .bufferFull(let isFull):
            isBufferFull = isFull
        case .bufferEmpty(let isEmpty):
            isBufferEmpty = isEmpty
        case .error(_),.network(_):
            handleError(state : state)
        case .stop(_):
            resetVariables()
        default:
            break
        }
    }
    
    func handleError(state : PlayerState) {
        if isBufferFull {
            return
        }
        
        rightButton.isHidden = true
        leftButton.isHidden = false
        
        if let info = message(for: state){
            show()
            label.text = info.0
            leftButton.setTitle(info.1, for: .normal)
        }else {
            hide()
        }
    }

    
    @IBAction func leftButtonClicked(_ sender: UIButton) {
        hide()
        publish(state: .play)
    }
    
    @IBAction func rightButtonClicked(_ sender: UIButton) {
        hide()
        publish(state: .stop(indexPath))
    }
    
    func message(for state : PlayerState) -> (String,String)? {
        switch state {
        case .network(let s):
            return message(networkState: s)
        case .error(let e):
            if let state = PlayerNetworkState(error: e) {
                return message(networkState: state)
            }else {
                return messageError()
            }
        default:
            return nil
        }
    }
    
    func message(networkState : PlayerNetworkState) -> (String,String)? {
        var button = NSLocalizedString("player-indicator-left-button-retry", comment: "Retry again")
        var message = ""
        switch networkState {
        case .networkUnReachable:
            message = NSLocalizedString("player-indicator-label-network-unreachable", comment: "Network connection has been lost")
        case .wwan:
            button = NSLocalizedString("player-indicator-left-button", comment: "Continue play")
            message = NSLocalizedString("player-indicator-label-network-wwan", comment: "wwan")
            rightButton.isHidden = false
            
            publish(state: .paused)
        case .timeout:
            message = NSLocalizedString("player-indicator-label-network-timeout", comment: "Time out")
        default:
            return nil
        }
        return (message,button)
    }
    
    func messageError() -> (String,String) {
        let button = NSLocalizedString("player-indicator-left-button-retry", comment: "Retry again")
        let message = NSLocalizedString("player-indicator-label-error", comment: "Load failed")
        return (message,button)
    }
    
    
}

extension IndicatorView : PlayerStateSubscriber {
    var eventBus: EventBus {
        return bus
    }
    
    func receive(state: PlayerState) {
        handle(state: state)
    }
}

extension IndicatorView : PlayerStatePublisher {}
