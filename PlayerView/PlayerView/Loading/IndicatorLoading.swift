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
//  IndicatorLoading.swift
//  PlayerView
//
//  Created by 杨志远 on 2019/11/27.
//

import UIKit

class IndicatorLoading: UIView {
    let radius : CGFloat = 20.0
    var strokeColor : UIColor = .white
    var strokeThickness : CGFloat = 3.0
    
    var bottomGradientLayer : CAGradientLayer!
    var topGradientLayer : CAGradientLayer!
    var subLayer : CALayer!
    var indefiniteLayer : CAShapeLayer!
    var layerView : UIView!
    var centerX : CGFloat {
        get {
            return radius + strokeThickness / 2 + 5
        }
    }
    
    var layerWidth : CGFloat {
        return centerX * 2
    }
    
    var layerFrame : CGRect {
        return CGRect(origin: .zero, size: CGSize(width: layerWidth, height: layerWidth))
    }
    
    var bus : EventBus! {
        didSet {
            registerAsStateSubscriber()
        }
    }
    
    var isBufferFull = false
    var indexPath : IndexPath?
    
    var preferences : IndicatorPreferences
    
    var indicator : Indicator!

    override init(frame: CGRect) {
        preferences = IndicatorPreferences()
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        preferences = IndicatorPreferences()
        super.init(coder: coder)
        setup()
    }
    
    init(preferences : IndicatorPreferences) {
        self.preferences = preferences
        super.init(frame: .zero)
        setup()
    }
    
    func show() {
        if !isHidden {
           return
        }
        isHidden = false
        indicator.startAnimating()
    }
    
    func hide() {
        if isHidden {
            return
        }
        isHidden = true
        indicator.stopAnimating()
    }
    
    func setup() {
        addSubViews()
        isUserInteractionEnabled = false
    }
    
    func addSubViews() {
        /// assign style
        switch preferences.style {
        case .activity(let style):
            let activityView = UIActivityIndicatorView(style: .white)
            activityView.style = style
            indicator = activityView
        case .infiniteLayer(let style):
            let layerView = InfiniteIndicator()
            layerView.style = style
            indicator = layerView
        case .custom(let indicator):
            self.indicator = indicator
        }
        /// addSubview
        let view = indicator.view
        indicator.startAnimating()
        addSubview(view)
        /// layout
        switch indicator.size {
        case .intrinsicSize:
            view.center(to: self, offset: indicator.centerOffset)
        case .full:
            view.edges(to: self)
        case .size(let size):
            view.frame.size = size
            view.center(to: self)
        }
    }
    
    override func safeAreaInsetsDidChange() {
        let animation = {
            UIView.animate(withDuration: playerTransitionDuration, delay: 0, options: [], animations: {
                self.layoutIfNeeded()
            }, completion: nil)
        }
        animation()
    }
    
    func handle(state : PlayerState) {
        // fixed a bug about isBufferFull always true
        let stop = PlayerState.stop(indexPath)
        if case state = stop {
            resetVariables()
        }
        
        if isBufferFull {
            hide()
            return
        }
        
        switch state {
        case .bufferFull(let full):
            isBufferFull = full
        case .prepare(let i):
            indexPath = i
            show()
        case .seeking(_),.loading:
            show()
        case .play,.paused,.seekDone,.network(_):
            hide()
        case .stop(_),.finished,.error(_):
            hide()
            resetVariables()
        default:
            break
        }
    }
    
    func resetVariables() {
        isBufferFull = false
        indexPath = nil
    }

}

extension IndicatorLoading : PlayerStateSubscriber {
    var eventBus: EventBus {
        return bus
    }
    
    func receive(state: PlayerState) {
        handle(state: state)
    }
}
