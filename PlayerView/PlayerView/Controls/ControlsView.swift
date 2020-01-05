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
import AVKit


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

class ControlsView : UIView {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var fullButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var controlsStackView: UIStackView!
    /// hide every 5 seconds
    let hideTimeInterval = 5.0
    var isSliding = false {
        didSet {
            if isSliding {
                playButton(hide: true)
            }
        }
    }

    var isSeeking = false
    var isBufferFull = false
    var isLikelyToPlay = false
    var isReadyToPlay = false {
        didSet {
            if isReadyToPlay {
                hide()
                controlsStackView.isHidden = preferences.disable
            }
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
            if isSliding {
                return
            }
            
            if !isSeeking {
                updateSliderValue(position)
            }
            updatePosition(position)
            updateShowState()
        }
    }
    
    var bus : EventBus! {
        didSet {
            registerAsStateSubscriber()
            registerAsItemSubscriber()
        }
    }
    
    private var state : PlayerState = .unknown
    private var oldPosition : TimeInterval = 0
    private var mode : PlayerModeState = .portrait
    
    private (set) var preferences : ControlsPreferences
    
    override init(frame: CGRect) {
        self.preferences = ControlsPreferences()
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        self.preferences = ControlsPreferences()
        super.init(coder: coder)
        setup()
    }
    
    init(preferences : ControlsPreferences) {
        self.preferences = preferences
        super.init(frame: .zero)
        setup()
    }
    
    public func show() {
        self.isHidden = false
    }
    
    public func hide() {
        self.isHidden = true
    }
    
    @available(iOS 11.0, *)
    override func safeAreaInsetsDidChange() {
        let delay = 0.0
        let animation = {
            UIView.animate(withDuration: playerTransitionDuration, delay: delay, options: [.beginFromCurrentState], animations: {
                self.layoutIfNeeded()
            }, completion: nil)
        }
        animation()
    }
    

    private func setup() {
        fromNib()
        resetVariables()
        setupSlider()
        setupButtons()
        configUI()
    }
    
    private func configUI() {
        // Slider
        slider.minimumTrackTintColor = preferences.sliderMinTrackColor
        slider.maximumTrackTintColor = preferences.sliderMaxTrackColor
        slider.thumbImage = preferences.sliderImage
        // ProgressView
        progressView.trackTintColor = preferences.progressTrackTintColor
        progressView.tintColor = preferences.progressTintColor
        // Button
        playButton.setImage(preferences.playImage, for: .normal)
        playButton.setImage(preferences.pauseImage, for: .selected)
        playButton.setImage(preferences.pauseImage, for: .init(arrayLiteral: .selected,.highlighted))
        backButton.setImage(preferences.backImage, for: .normal)
        fullButton.isHidden = preferences.disableFullScreen
        fullButton.setImage(preferences.fullImage, for: .normal)
        fullButton.setImage(preferences.fullSelectedImage, for: .selected)
        fullButton.setImage(preferences.fullSelectedImage, for: .init(arrayLiteral: .selected,.highlighted))
        // Label
        startLabel.textColor = preferences.timeLableColor
        endLabel.textColor = preferences.timeLableColor
        // StackView
        controlsStackView.isHidden = preferences.disableSlideControls
    }
    
    fileprivate func resetVariables() {
        isSliding = false
        isSeeking = false
        isReadyToPlay = false
        isBufferFull = false
        isLikelyToPlay = false
        duration = 0
        position = 0
        oldPosition = 0
        bufferTime = 0
        state = .unknown
        mode = .portrait
        // UI
        backButton.isHidden = true
        playButton(hide: false)
        controlsStackView.isHidden = true
    }
    
    private func setupButtons() {
        playButton.setImage(preferences.pauseImage, for: UIControl.State.init(arrayLiteral: .selected,.highlighted))
        fullButton.setImage(preferences.fullSelectedImage, for: UIControl.State.init(arrayLiteral: .selected,.highlighted))
    }
    
    private func setupSlider() {
        slider.addTarget(self, action: #selector(sliderTouchDown(_:)), for: [.touchDown,.touchDragExit,.touchDragOutside])
        slider.addTarget(self, action: #selector(sliderTouchCancel(_:)), for: [.touchCancel,.touchUpInside,.touchUpOutside])
        slider.addTarget(self, action: #selector(sliderValueChange(_:)), for: .valueChanged)
    }
    
    // MARK: - Event
    @IBAction func play(_ sender: UIButton) {
        if sender.isSelected {
            publish(state: .paused)
        }else {
            publish(state: .play)
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        publish(state: .mode(.portrait))
    }
    
    @IBAction func full(_ sender: UIButton) {
        if sender.isSelected {
            publish(state: .mode(.portrait))
        }else {
            publish(state: .mode(.landscape))
        }
    }
    
    @objc func sliderValueChange(_ slider:UISlider) {
        isSliding = true
        let time = TimeInterval(slider.value)
        oldPosition = time
        position = time
        updatePosition(time)
        publish(state: .seeking(time))
    }
    
    @objc func sliderTouchCancel(_ slider:UISlider) {
        isSliding = false
        /// when seeking done but slider is still pressed, video will not play,
        /// so to prevent this
        if playButton.isSelected && isLikelyToPlay {
            publish(state: .play)
        }
    }

    @objc func sliderTouchDown(_ slider:UISlider) {
        isSliding = true
    }

    @objc func switchHiddenState(gesture : UIGestureRecognizer) {
        if ignore(gesture: gesture) {
            return
        }
            
        if self.isHidden {
            show()
        }else {
            hide()
        }
    }
    
    private func updatePosition(_ time : TimeInterval) {
        startLabel.text = transformSecondsToMMSS(time)
    }
    
    private func updateSliderValue(_ time : TimeInterval) {
        slider.value = Float(position)
    }
    
    /// hide every 5 seconds
    private func updateShowState() {
        if (self.isHidden) {
            oldPosition = position
        } else {
            let drop = abs(round(position - oldPosition))
            if (drop >= hideTimeInterval) {
                oldPosition = position
                hide()
            }
        }
    }
    
    private func transformSecondsToMMSS(_ seconds : TimeInterval) -> String {
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
    
    fileprivate func playButton(state : PlayerState) {
        switch state {
        case .prepare:
            playButton(selected: true)
            playButton(hide: true)
        case .play:
            playButton(selected: true)
            playButton(hide: false)
        case .paused:
            playButton(selected: false)
            playButton(hide: false)
        case .seeking(_):
            playButton(hide: true)
        case .seekDone:
            playButton(hide: false)
        case .loading:
            playButton(hide: true)
        case .finished,.stop:
            playButton(selected: true)
            playButton(hide: false)
        case .bufferFull(_),.bufferEmpty(_),.error(_),.mode(_),.network(_),.unknown,.interrupted(_):
            break
        }
    }
    
    fileprivate func playButton(selected : Bool) {
        if playButton.isSelected != selected {
            playButton.isSelected = selected
        }
    }
    
    fileprivate func playButton(hide : Bool) {
        if isBufferFull {
            playButton.isHidden = false
            return
        }
        
        if playButton.isHidden != hide {
            playButton.isHidden = hide
        }
    }
    
    fileprivate func handleState(state : PlayerState) {
        playButton(state: state)
        switch state {
        case .prepare:
            controlsStackView.isHidden = true
            show()
        case .seeking(_):
            isSeeking = true
        case .seekDone:
            isSeeking = false
        case .error(_):
            hide()
        case .mode(let mode):
            switch mode {
            case .landscape:
                backButton.isHidden = false
                fullButton.isSelected = true
            case .portrait:
                backButton.isHidden = true
                fullButton.isSelected = false
            }
            self.mode = mode
        case .bufferFull(let isFull):
            isBufferFull = isFull
        case .stop:
            resetVariables()
        default:
            break
        }
    }
    
    fileprivate func handle(item : PlayerItem) {
        switch item {
        case .status(let s):
            if s == .readyToPlay {
                isReadyToPlay = true
            }
        case .duration(let t):
            duration = t
        case .position(let t):
            position = t
        case .loadedTime(let t):
            bufferTime = t
        case .bufferFull(let f):
            isBufferFull = f
        case .likelyKeepUp(let likely):
            isLikelyToPlay = likely
        default:
            break
        }
    }
    
    /// ignore gesture in controlsStackView
    /// - Parameter gesture: gesture
    func ignore(gesture : UIGestureRecognizer) -> Bool {
        if !isHidden && controlsStackView.frame.contains(gesture.location(in: self))  {
            return true
        }
        return false
    }
}

extension ControlsView : PlayerStateSubscriber {
    var eventBus: EventBus {
        return bus
    }
    
    func receive(state: PlayerState) {
        if self.state == state {
            return
        }
        handleState(state: state)
    }
}

extension ControlsView : PlayerStatePublisher {}

extension ControlsView : PlayerItemSubscriber {
    func receive(item: PlayerItem) {
        handle(item: item)
    }
}

