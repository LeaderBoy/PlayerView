//
//  Copyright (C) 2019 杨.
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
//  PlayerViewOptions.swift
//  PlayerView
//
//  Created by 杨 on 2019/12/10.
//

import UIKit
import WebKit

class A {
    func aaa() {
        let webview = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    }
}




//public enum Style : Int {
//    case large
//    case medium
//    case small
//}





struct PlayerViewOptions {
    public static var disableControlsView = false
    public static var disableIndicatorView = false
    public static var disableIndicatorLoading = false
    public static var backgroundColor : UIColor = .black
    public static var disableCacheProgress = false
    public static var disableMotionMonitor = false
}


struct ControlsViewOptions {
    public static var disableSlideControls = false
    /// UIButton
    public static var fullButtonImage : UIImage = #imageLiteral(resourceName: "full_screen")
    public static var fullButtonSelectedImage : UIImage = #imageLiteral(resourceName: "full_screen_selected")
    
    public static var disableFullScreen = false
    public static var backButtonImage : UIImage = #imageLiteral(resourceName: "ZYPlayer_controls_back_white")
    
    public static var playButtonImage : UIImage = #imageLiteral(resourceName: "controls_play")
    public static var playButtonSelectedImage : UIImage = #imageLiteral(resourceName: "controls_pause")
    /// UISlider
    public static var sliderMinTrackColor : UIColor = #colorLiteral(red: 1, green: 0.1490196078, blue: 0, alpha: 1)
    public static var sliderMaxTrackColor : UIColor = .clear
    public static var sliderImage : UIImage = #imageLiteral(resourceName: "ZYPlayer_controls_thumb")
    /// UIProgressView
    public static var progressTintColor : UIColor = .white
    public static var progressTrackTintColor : UIColor = .lightGray
    /// UILabel
    public static var timeLabelColor : UIColor = .white
    
}
