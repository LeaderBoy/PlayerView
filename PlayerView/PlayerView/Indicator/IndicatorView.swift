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
    
    enum IndicatorState {
        case loading
        case indicator
        case custom
    }
    
    @IBOutlet weak var customView: UIView!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var indicatorStackView: UIStackView!
    @IBOutlet weak var indicatorActivityView: UIActivityIndicatorView!
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var leftButton: UIButton!    
    @IBOutlet weak var rightButton: UIButton!
    
    var state : PlayerState = .prepare {
        didSet {
            handle(state: state)
        }
    }
    
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
    
    func showCustomView(_ show : Bool) {
        customView.isHidden = !show
        indicatorView.isHidden = show
    }
    
    func show(state : IndicatorState) {
        show()
        switch state {
        case .loading:
            indicatorView.isHidden = false
            indicatorActivityView.isHidden = false
            indicatorActivityView.startAnimating()

            indicatorStackView.isHidden = true
            customView.isHidden = true
        case .indicator:
            indicatorView.isHidden = false
            indicatorStackView.isHidden = false
            
            indicatorActivityView.isHidden = true
            customView.isHidden = true
        case .custom:
            indicatorView.isHidden = true
            customView.isHidden = false
        }
    }
    
    func show() {
        isHidden = false
    }
    
    func hide() {
        isHidden = true
    }
    
    func handle(state : PlayerState) {
        switch state {
        case .prepare:
            show(state: .loading)
        case .playing:
            hide()
        case .paused:
            break
        case .loading:
            show(state: .loading)
        case .error(let errorState):
            handleError(state: errorState)
        case .mode(let mode):
            handleMode(state: mode)
        case .network(let state):
            handleNetwork(state: state)
        case .seeking(_):
            break
        case .seekDone:
            break
        default:
            break
        }
        
        reloadState(state: state)
    }
    
    func handleError(state : PlayerErrorState) {
        
    }
    
    func handleMode(state : PlayerModeState) {
        
    }
    
    func handleNetwork(state : PlayerNetworkState) {
        switch state {
        case .networkUnReachable:
            show(state: .indicator)
        case .wwan:
            show(state: .indicator)
        case .wifi:
            break
//            show(state: .loading)
        }
        
        networkState = state
    }
    
    func reloadState(state : PlayerState) {
        if let title = indicatorTitleFor(state: state) {
            label.text = title
        }
    }
    
    func indicatorTitleFor(state : PlayerState) -> String? {
        if state == .error(.networkUnReachable) || state == .network(.networkUnReachable) {
            return "网络连接失败,请检查网络连接设置"
        }else if state == .error(.timeout) {
            return "请求超时,请重试"
        }else if state == .error(.resourceUnavailable) {
            return "请求资源不可用"
        }
        return nil
    }
}
