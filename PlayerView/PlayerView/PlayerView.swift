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
//  PlayerView.swift
//  PlayerView
//
//  Created by 杨志远 on 2019/11/20.
//

import UIKit
import AVKit

public class PlayerView: UIView {
    
    public lazy var itemObserver = ItemObserver()
    
    var player = AVPlayer()
    
    lazy var layerView = PlayerLayerView(player: player)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        addSubViews()
        observerCallBack()
    }
    
    public func prepare(url : URL) {
        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)
        itemObserver.item = item
        itemObserver.player = player
    }
    
    func addSubViews() {
        addSubview(layerView)
        
        layerView.edges(to: self)
    }
    
    func observerCallBack() {
        itemObserver.observedStatus =  {[weak self] status in
            guard let self = self else { return }
            switch status {
            case .readyToPlay:
                self.layerView.play()
            case .failed:
               print("播放失败")
            default:
                break
            }
        }
        
        itemObserver.observedDuration =  {[weak self] duration in
            
        }
        
        itemObserver.observedPosition =  {[weak self] position in
            
        }
        
        itemObserver.observedBufferEmpty =  {[weak self] isEmpty in
            
        }
    }
}
