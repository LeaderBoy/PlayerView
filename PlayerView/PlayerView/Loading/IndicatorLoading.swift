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
    var strokeThickness : CGFloat = 1.0
    
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
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        setupTopLayer()
        setupBottomLayer()
        setupShapLayer()
        setupSubLayer()
        setupLayerView()
        
        isUserInteractionEnabled = false
    }
    
    func setupTopLayer() {
        let width = centerX * 2
        let gradientLayer = CAGradientLayer()
        gradientLayer.contentsScale = UIScreen.main.scale
        gradientLayer.startPoint = CGPoint(x: 1, y: 0)
        gradientLayer.endPoint = .zero
        gradientLayer.frame = CGRect(origin: .zero, size: CGSize(width: width, height: width / 2))
        gradientLayer.colors = [strokeColor.cgColor,strokeColor.withAlphaComponent(0.5).cgColor]
        topGradientLayer = gradientLayer
    }
    
    func setupBottomLayer() {
        let width = centerX * 2
        let gradientLayer = CAGradientLayer()
        gradientLayer.contentsScale = UIScreen.main.scale
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = CGRect(x: 0, y: centerX, width: width, height: centerX)
        gradientLayer.colors = [strokeColor.withAlphaComponent(0.5).cgColor,strokeColor.withAlphaComponent(0.1).cgColor]
        bottomGradientLayer = gradientLayer
    }
    
    func setupShapLayer() {
        let center = CGPoint(x: centerX, y: centerX)
        let circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        let shapLayer = CAShapeLayer()
        shapLayer.contentsScale = UIScreen.main.scale
        shapLayer.lineWidth = strokeThickness
        shapLayer.strokeColor = strokeColor.cgColor
        shapLayer.fillColor = UIColor.clear.cgColor
        shapLayer.path = circlePath.cgPath
        shapLayer.frame = layerFrame
        indefiniteLayer = shapLayer
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
    
    func setupSubLayer() {
        let layer = CALayer()
        layer.bounds = layerFrame
        subLayer = layer
        
        subLayer.addSublayer(topGradientLayer)
        subLayer.addSublayer(bottomGradientLayer)
        subLayer.mask = indefiniteLayer
        
        let keyPath = "transform.rotation"
        let key = "RotationAnimation"
        let rotationAnimation = CABasicAnimation(keyPath: keyPath)
        rotationAnimation.fromValue = NSNumber(value: 0)
        let toValue : Float = .pi * 2
        rotationAnimation.toValue = NSNumber(value: toValue)
        rotationAnimation.repeatCount = Float.infinity
        rotationAnimation.isRemovedOnCompletion = false
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        rotationAnimation.duration = 1.0
        rotationAnimation.fillMode = .forwards
        subLayer.add(rotationAnimation, forKey: key)
        subLayer.position = CGPoint(x: centerX, y: centerX)
    }
    
    func setupLayerView() {
        let width = centerX * 2
        let layerView = UIView()
        layerView.layer.addSublayer(subLayer)
        layerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(layerView)
        
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                layerView.widthAnchor.constraint(equalToConstant: width),
                layerView.heightAnchor.constraint(equalToConstant: width),
                layerView.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
                layerView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                layerView.widthAnchor.constraint(equalToConstant: width),
                layerView.heightAnchor.constraint(equalToConstant: width),
                layerView.centerYAnchor.constraint(equalTo: centerYAnchor),
                layerView.centerXAnchor.constraint(equalTo: centerXAnchor)
            ])
        }
        
        layerView.backgroundColor = .clear
        self.layerView = layerView
    }
    
    override func safeAreaInsetsDidChange() {
        let animation = {
            UIView.animate(withDuration: playerAnimationTime, delay: 0, options: [], animations: {
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
