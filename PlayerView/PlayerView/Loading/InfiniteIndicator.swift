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
//  InfiniteIndicator.swift
//  PlayerView
//
//  Created by 杨志远 on 2019/12/22.
//

import UIKit


public class InfiniteIndicator: UIView {
    
    /// Indicator radius and strokeThickness
    /// - case default : radius = 20,strokeThickness = 1
    /// - case medium : radius = 15,strokeThickness = 2
    /// - case large : radius = 20,strokeThickness = 3
    public enum Style : Int {
        case `default`
        case medium
        case large
    }
    
    var style : Style = .default {
        didSet {
            relayout(accordingTo: style)
        }
    }
    var radius : CGFloat = 20.0
    var strokeThickness : CGFloat = 1.0
    var strokeColor : UIColor = .white {
        didSet {
            resetColor()
        }
    }
    
    var bottomGradientLayer : CAGradientLayer!
    var topGradientLayer : CAGradientLayer!
    var subLayer : CALayer!
    var indefiniteLayer : CAShapeLayer!
    var layerView : UIView!
    var centerX : CGFloat {
        get {
            return radius + strokeThickness / 2
        }
    }
    
    var layerWidth : CGFloat {
        return centerX * 2
    }
    
    var layerFrame : CGRect {
        return CGRect(origin: .zero, size: CGSize(width: layerWidth, height: layerWidth))
    }
            
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
        resetColor()
        relayout(accordingTo: style)
        isUserInteractionEnabled = false
    }
    
    func setupTopLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.contentsScale = UIScreen.main.scale
        gradientLayer.startPoint = CGPoint(x: 1, y: 0)
        gradientLayer.endPoint = .zero
        topGradientLayer = gradientLayer
    }
    
    func setupBottomLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.contentsScale = UIScreen.main.scale
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        bottomGradientLayer = gradientLayer
    }
    
    func setupShapLayer() {
        let shapLayer = CAShapeLayer()
        shapLayer.contentsScale = UIScreen.main.scale
        shapLayer.fillColor = UIColor.clear.cgColor
        indefiniteLayer = shapLayer
    }
    
    func setupSubLayer() {
        let layer = CALayer()
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
    }
    
    func setupLayerView() {
        let layerView = UIView()
        layerView.layer.addSublayer(subLayer)
        addSubview(layerView)
        layerView.backgroundColor = .clear
        self.layerView = layerView
    }
    
    func resetColor() {
        topGradientLayer.colors = [strokeColor.cgColor,strokeColor.withAlphaComponent(0.5).cgColor]
        bottomGradientLayer.colors = [strokeColor.withAlphaComponent(0.5).cgColor,strokeColor.withAlphaComponent(0.1).cgColor]
        indefiniteLayer.strokeColor = strokeColor.cgColor
    }
    
    func relayout(accordingTo style : Style) {
        
        switch style {
        case .default:
            radius = 20
            strokeThickness = 1.0
        case .medium:
            radius = 10
            strokeThickness = 3.0
        case .large:
            radius = 20
            strokeThickness = 3.0
        }
        
        let width = centerX * 2
        topGradientLayer.frame = CGRect(x: 0, y: 0, width: width, height: centerX)
        bottomGradientLayer.frame = CGRect(x: 0, y: centerX, width: width, height: centerX)
        indefiniteLayer.lineWidth = strokeThickness
        
        let center = CGPoint(x: centerX, y: centerX)
        let circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        indefiniteLayer.path = circlePath.cgPath
        indefiniteLayer.frame = layerFrame
        
        subLayer.bounds = layerFrame
        subLayer.position = CGPoint(x: centerX, y: centerX)

        layerView.removeConstraints()
        layerView.translatesAutoresizingMaskIntoConstraints = false

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
        
    }
    
    override public func safeAreaInsetsDidChange() {
        let animation = {
            UIView.animate(withDuration: playerTransitionDuration, delay: 0, options: [], animations: {
                self.layoutIfNeeded()
            }, completion: nil)
        }
        animation()
    }
}


extension InfiniteIndicator : Indicator {
    public var view: UIView {
        return self
    }
    
    public var isAnimating: Bool {
        return false
    }
    
    public var foregroundColor: UIColor {
        get {
            return strokeColor
        }
        set {
            strokeColor = newValue
        }
    }
    
    public func startAnimating() {
        subLayer.startAnimating()
    }
    
    public func stopAnimating() {
        subLayer.stopAnimating()
    }
}
