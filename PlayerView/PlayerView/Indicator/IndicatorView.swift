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
    
    enum IndicatorState {
        case loading
        case networkUnReachable
        case timeout
        case wwan
        case success
        case error
        case ignore
        case stop
        
        init(state : PlayerState) {
            switch state {
            case .loading,.prepare,.seeking(_),.unknown:
                self = .loading
            case .playing,.seekDone,.bufferFull(_):
                self = .success
            case .stop,.finished:
                self = .stop
            case .paused,.mode(_):
                self = .ignore
            case .error(let e):
                switch e {
                case .resourceUnavailable,.error(_):
                    self = .error
                case .networkUnReachable:
                    self = .networkUnReachable
                case .timeout:
                    self = .timeout
                }
            case .network(let e):
                switch e {
                case .networkUnReachable:
                    self = .networkUnReachable
                case .wwan:
                    self = .wwan
                case .wifi:
                    self = .success
                }
            }
        }
    }
    
    @IBOutlet weak var customView: UIView!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var indicatorStackView: UIStackView!
    
    @IBOutlet weak var indicatorLoadingView: IndicatorLoading!
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var leftButton: UIButton!    
    @IBOutlet weak var rightButton: UIButton!
    
    var state : PlayerState = .prepare {
        didSet {
            if oldValue == state {
                return
            }
            
            switch state {
            case .bufferFull(let full):
                isBufferFull = full
            default:
                break
            }
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
        let state = IndicatorState(state: state)
        reloadState(state: state)
    }
    
    func handleError(state : PlayerErrorState) {
        
    }
    
    func handleMode(state : PlayerModeState) {
        
    }
    
    func handleNetwork(state : PlayerNetworkState) {
        networkState = state
    }
    
    func reloadState(state : IndicatorState) {
        if state == .stop {
            isBufferFull = false
            hide()
            return
        }else if state == .success || isBufferFull {
            hide()
            return
        }else if state == .ignore{
            return
        }else {
            show()
        }
        
        if let color = indicatorBackgroundColor(state: state) {
            backgroundColor = color
        }
        
        isUserInteractionEnabled = true
        
        if let view = indicatorCustomView(state: state) {
            indicatorLoadingView.isHidden = true
            indicatorStackView.isHidden = true
            customView.isHidden = false
            customView.subviews.forEach{$0.removeFromSuperview()}
            customView.addSubview(view)
            view.edges(to: customView)
        }else if state == .loading {
            isUserInteractionEnabled = false
            indicatorLoadingView.isHidden = false
            indicatorStackView.isHidden = true
            customView.isHidden = true
        }else {
            customView.isHidden = true
            indicatorLoadingView.isHidden = true
            indicatorStackView.isHidden = false
            
            if let title = indicatorTitleFor(state: state) {
                label.text = title
                label.isHidden = false
            }else {
                label.isHidden = true
            }
            
            if let title = indicatorLeftButtonFor(state: state) {
                leftButton.setTitle(title, for: .normal)
                leftButton.isHidden = false
            }else {
                leftButton.isHidden = true
            }
            
            if let title = indicatorRightButtonFor(state: state) {
                rightButton.setTitle(title, for: .normal)
                rightButton.isHidden = false
            }else {
                rightButton.isHidden = true
            }
        }
        
    }
    
    func indicatorTitleFor(state : IndicatorState) -> String? {
        switch state {
        case .wwan:
            return "当前为移动网络,是否继续播放"
        case .networkUnReachable:
            return "无网络连接"
        case .timeout :
            return "请求已超时,请重试"
        case .error:
            return "加载失败,请重试"
        default:
            return nil
        }
    }
    
    func indicatorLeftButtonFor(state : IndicatorState) -> String? {
        switch state {
        case .wwan:
            return "继续播放"
        case .error,.timeout,.networkUnReachable:
            return "点击重试"
        default:
            return nil
        }
    }
    
    func indicatorRightButtonFor(state : IndicatorState) -> String? {
        switch state {
        case .wwan:
            return "退出播放"
        default:
            return nil
        }
    }
    
    func indicatorCustomView(state : IndicatorState) -> UIView? {
        return nil
    }
    
    func indicatorBackgroundColor(state : IndicatorState) -> UIColor? {
        switch state {
        case .networkUnReachable,.error:
            return UIColor(white: 0, alpha: 1)
        default:
            return .clear
        }
    }
    
    
}
