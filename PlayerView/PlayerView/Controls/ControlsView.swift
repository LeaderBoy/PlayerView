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
//  ControlsView.swift
//  PlayerView
//
//  Created by 杨志远 on 2019/11/21.
//

import UIKit


class ControlsView : UIView {
    
    var stateUpdater : PlayerStateUpdater?
        
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var fullButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var progressView: UIProgressView!
    
    var isSlide = false
    var oldPosition : TimeInterval = 0
    var hideTimeInterval = 3.0
    
    var state : PlayerState = .prepare {
        didSet {
            handleState(state: state)
        }
    }
    
    var duration : TimeInterval = 0 {
        didSet {
            let intValue = ceil(duration)
            
            slider.minimumValue = 0
            slider.maximumValue = Float(intValue)
                    
            let label = self.transformSecondsToMMSS(intValue)
            endLabel.text = label
        }
    }
    
    var bufferTime : TimeInterval = 0 {
        didSet {
            if duration > 0 && duration >= bufferTime {
                progressView.progress = Float(bufferTime / duration)
            }
        }
    }
    
    var position : TimeInterval = 0 {
        didSet {
            if isSlide {
                return
            }
            updateSliderValue(position)
            updatePosition(position)
            
            updateShowState()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    public func show() {
        self.isHidden = false
    }
    
    public func hide() {
        self.isHidden = true
    }
    
    func setup() {
        fromNib()
        setupSlider()
    }
    
    func setupSlider() {
        slider.addTarget(self, action: #selector(sliderTouchDragExit), for: .touchDragExit)
        slider.addTarget(self, action: #selector(sliderTouchDown(_:)), for: .touchDown)
        slider.addTarget(self, action: #selector(sliderTouchCancel(_:)), for: .touchCancel)
        slider.addTarget(self, action: #selector(sliderTouchUpInside(_:)), for: .touchUpInside)
        slider.addTarget(self, action: #selector(sliderTouchUpOutside(_:)), for: .touchUpOutside)
        slider.addTarget(self, action: #selector(sliderTouchDragOutside(_:)), for: .touchDragOutside)
        slider.addTarget(self, action: #selector(sliderValueChange(_:)), for: .valueChanged)
    }
    
    @objc func sliderValueChange(_ slider:UISlider) {
        isSlide = true
        let time = TimeInterval(slider.value)
        position = time
        updatePosition(time)
        stateUpdater?(.seeking(time))
    }
    
    @objc func sliderTouchUpOutside(_ slider:UISlider) {
        isSlide = false
    }
    
    @objc func sliderTouchUpInside(_ slider:UISlider) {
        isSlide = false
    }
    
    @objc func sliderTouchCancel(_ slider:UISlider) {
        isSlide = false
    }
    
    @objc func sliderTouchDragOutside(_ slider:UISlider) {
        isSlide = true
    }
    
    @objc func sliderTouchDown(_ slider:UISlider) {
        isSlide = true
    }
    
    @objc func sliderTouchDragExit(_ slider:UISlider) {
        isSlide = true
    }
    
    func updatePosition(_ time : TimeInterval) {
        startLabel.text = transformSecondsToMMSS(time)
    }
    
    func updateSliderValue(_ time : TimeInterval) {
        slider.value = Float(position)
    }
    
    func updateShowState() {
        if (self.isHidden) {
            oldPosition = position;
        } else {
            let drop = round(position - oldPosition);
            if (drop >= hideTimeInterval) {
                oldPosition = position;
                hide()
            }
        }
    }
    
    @IBAction func play(_ sender: UIButton) {
        if sender.isSelected {
            stateUpdater?(.paused)
        }else {
            stateUpdater?(.playing)
        }
    }
    
    
    @IBAction func back(_ sender: UIButton) {
        stateUpdater?(.mode(.small))
    }
    
    @IBAction func full(_ sender: UIButton) {
        if sender.isSelected {
            stateUpdater?(.mode(.small))
        }else {
            stateUpdater?(.mode(.landscapeFull))
        }
    }
    
    func transformSecondsToMMSS(_ seconds : TimeInterval) -> String {
        let time    = Int(round(seconds))
        let hour    = String(format: "%02ld", arguments: [time / 3600] )
        let minute  = String(format: "%02ld", arguments: [(time % 3600)/60] )
        let second  = String(format: "%02ld", arguments: [time % 60] )
        
        if let h = Int(hour),h <= 0 {
            return minute + ":" + second
        }else {
            return hour + ":" + minute + ":" + second
        }
    }
    
    func handleState(state : PlayerState) {
        switch state {
        case .prepare,.playing:
            playButton.isSelected = true
        case .paused:
            playButton.isSelected = false
        case .loading:
            hide()
        case .error(_):
            hide()
        case .mode(let mode):
            switch mode {
            case .landscapeFull,.portraitFull:
                backButton.isHidden = false
                fullButton.isSelected = true
            case .small:
                backButton.isHidden = true
                fullButton.isSelected = false
            }
        case .stop:
            playButton.isSelected = true
            duration = 0
            position = 0
            bufferTime = 0
            isSlide = false
        default:
            break
        }
        
    }
}

@IBDesignable
extension UISlider {
    @IBInspectable var thumbImage : UIImage? {
        set {
            setThumbImage(newValue, for: .normal)
        }
        get {
            return currentThumbImage
        }
    }
}
