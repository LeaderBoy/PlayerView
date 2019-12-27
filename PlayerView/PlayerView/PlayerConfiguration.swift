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
//  PlayerConfiguration.swift
//  PlayerView
//
//  Created by 杨志远 on 2019/12/21.
//

import UIKit

/// init
public final class PlayerConfiguration : NSObject {
    /// default is true,when playback progress greater then or equal to 5 seconds
    /// use NSCache to cache the video's playback progress,video will play at cached progress next time
    /// if set to false,video will play from the start time
    public var disableCacheProgress : Bool
    public var backgroundColor : UIColor = .black
    
    public var indicatorPreferences : IndicatorPreferences
    public var controlsPreferences : ControlsPreferences
    
    override init() {
        disableCacheProgress = false
        self.indicatorPreferences = IndicatorPreferences()
        self.controlsPreferences = ControlsPreferences()
        super.init()
    }
}


// MARK: - Indicator
public class IndicatorPreferences: NSObject {
    /// disable indicator or not
    var disable : Bool = false
    var style : IndicatorStyle = .infiniteLayer(.default)
}

extension IndicatorPreferences {
    public enum IndicatorStyle {
        case activity(UIActivityIndicatorView.Style)
        case infiniteLayer(InfiniteIndicator.Style)
        case custom(Indicator)
    }
}

/// like UIActivityIndicatorView
public protocol Indicator {
    var view : UIView { get }
    var isAnimating: Bool { get }
    var color: UIColor { set get }
//    var hidesWhenStopped: Bool { set get }// default is YES. calls -setHidden when animating gets set to NO
    var centerOffset : CGPoint { get }
    var size : IndicatorSize { get }
    func startAnimating()
    func stopAnimating()
}

extension Indicator {
    public var size : IndicatorSize {
        return .full
    }
    public var centerOffset : CGPoint {
        return .zero
    }
}

public enum IndicatorSize {
    case full
    case intrinsicSize
    case size(CGSize)
}

extension UIActivityIndicatorView : Indicator {
    public var view: UIView {
        return self
    }
    
    public var color: UIColor {
        get {
            return tintColor
        }
        set {
            tintColor = newValue
        }
    }
}

// MARK: - Controls
public final class ControlsPreferences : NSObject {
    /// disable controls or not
    /// if set to true,controls will not add to playerView
    /// so all the following properties will not take effect even if they are set
    var disable                 : Bool = false
    /// that is to say disable full screen feature
    var disableFullScreen       : Bool = false
    /// cancel display of start and end times
    var disableTime             : Bool = false
    /// cancel display of bottom controls,show only play button
    var disableSlideControls    : Bool = false
    /// full screen button image
    var fullImage               : UIImage = #imageLiteral(resourceName: "full_screen")
    /// full screen button selected image
    var fullSelectedImage       : UIImage = #imageLiteral(resourceName: "full_screen_selected")
    var backImage          : UIImage = #imageLiteral(resourceName: "ZYPlayer_controls_back_white")
    var playImage          : UIImage = #imageLiteral(resourceName: "controls_play")
    var pauseImage         : UIImage = #imageLiteral(resourceName: "controls_pause")
    /// slider thumb image
    var sliderImage        : UIImage = #imageLiteral(resourceName: "ZYPlayer_controls_thumb")
    /// playback progress color
    var sliderMinTrackColor     : UIColor = #colorLiteral(red: 1, green: 0.1490196078, blue: 0, alpha: 1)
    var sliderMaxTrackColor     : UIColor = .clear
    /// buffer color
    var progressTintColor       : UIColor = .white
    /// track color
    var progressTrackTintColor  : UIColor = .lightGray
    var timeLableColor          : UIColor = .white
}
 

