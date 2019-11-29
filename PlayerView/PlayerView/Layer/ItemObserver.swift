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
//  ItemObserver.swift
//  PlayerView
//
//  Created by 杨志远 on 2019/11/20.
//

import Foundation
import AVKit

public class ItemObserver: NSObject {
    public typealias ItemError         = (Swift.Error) -> Void
    public typealias ItemStatus        = (AVPlayer.Status) -> Void
    public typealias ItemTimeinterval  = (TimeInterval) -> Void
    public typealias ItemPlayDone      = () -> Void
    public typealias ItemBool          = (Bool) -> Void

    public var observedPosition    : ItemTimeinterval?
    public var observedLoadedTime  : ItemTimeinterval?
    public var observedDuration    : ItemTimeinterval?
    public var observedError       : ItemError?
    public var observedStatus      : ItemStatus?
    public var observedPlayDone    : ItemPlayDone?
    public var observedBufferEmpty : ItemBool?
    public var observedBufferFull  : ItemBool?
    public var observedKeepUp      : ItemBool?
    
    private var itemErrorContext                    = 0
    private var itemDurationContext                 = 0
    private var itemStatusContext                   = 0
    private var itemLoadedTimeRangesContext         = 0
    private var itemPlaybackBufferEmptyContext      = 0
    private var itemPlaybackBufferFullContext       = 0
    private var itemPlaybackLikelyToKeepUpContext   = 0

    private let itemErrorKeyPath                    = #keyPath(AVPlayerItem.error)
    private let itemDurationKeyPath                 = #keyPath(AVPlayerItem.duration)
    private let itemStatusKeyPath                   = #keyPath(AVPlayerItem.status)
    private let itemLoadedTimeRangesKeyPath         = #keyPath(AVPlayerItem.loadedTimeRanges)
    private let itemPlaybackBufferEmptyKeyPath      = #keyPath(AVPlayerItem.isPlaybackBufferEmpty)
    private let itemPlaybackBufferFullKeyPath       = #keyPath(AVPlayerItem.isPlaybackBufferFull)
    private let itemPlaybackLikelyToKeepUpKeyPath   = #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp)
    
    private var currentPosition     : TimeInterval = 0
    private var previousPosition    : TimeInterval = 0
    private var duration            : TimeInterval = 0
    private var timeObserver        : Any?
    
    var player : AVPlayer? {
        didSet {
            if player != nil {
                observerRateForPlayer(player!)
            }
        }
    }
    
    var item : AVPlayerItem? {
        didSet {
            if oldValue != nil {
                removeAllObservers(for: oldValue!)
            }
            if item != nil {
                observerItem(item!)
            }
        }
    }
    
    func removeAllObservers(for item : AVPlayerItem) {
        removeObserverItemError(item)
        removeObserverItemDuration(item)
        removeObserverItemStatus(item)
        removeObserverItemPlayToEndTime(item)
        removeObserverItemLoadedTimeRanges(item)
        removeObserverItemPlaybackBufferFull(item)
        removeObserverItemPlaybackLikelyToKeepUp(item)
    }


    func observerItem(_ item : AVPlayerItem) {
        observerItemError(item)
        observerItemDuration(item)
        observerItemStatus(item)
        observerItemLoadedTimeRanges(item)
        observerItemPlaybackBufferEmpty(item)
        observerItemPlaybackLikelyToKeepUp(item)
        observerItemPlaybackBufferFull(item)
        observerItemPlayToEndTime(item)
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let itemContext = context,let itemKeyPath = keyPath else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if itemContext == &itemErrorContext && itemKeyPath == itemErrorKeyPath {
            observeErrorValue(change: change)
        }else if itemContext == &itemDurationContext && itemKeyPath == itemDurationKeyPath {
            observeDurationValue(change: change)
        }else if itemContext == &itemStatusContext && itemKeyPath == itemStatusKeyPath {
            observeStatusValue(change: change)
        }else if itemContext == &itemLoadedTimeRangesContext && itemKeyPath == itemLoadedTimeRangesKeyPath {
            observeLoadedTimeRangesValue(change: change)
        }else if itemContext == &itemPlaybackBufferEmptyContext && itemKeyPath == itemPlaybackBufferEmptyKeyPath {
            observePlaybackBufferEmptyValue(change: change)
        }else if itemContext == &itemPlaybackBufferFullContext && itemKeyPath == itemPlaybackBufferFullKeyPath {
            observePlaybackBufferFullValue(change: change)
        }else if itemContext == &itemPlaybackLikelyToKeepUpContext && itemKeyPath == itemPlaybackLikelyToKeepUpKeyPath {
            observePlaybackLikelyToKeepUpValue(change: change)
        }else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    
    func observeErrorValue(change: [NSKeyValueChangeKey : Any]?) {
        guard let newChange = change, let newError = newChange[.newKey] as? Error else {
            return
        }
        observedError?(newError)
    }
    
    func observeDurationValue(change: [NSKeyValueChangeKey : Any]?) {
        guard let newChange = change, let value = newChange[.newKey] as? NSValue else {
            return
        }
        var time = CMTime()
        value.getValue(&time)
        let seconds = CMTimeGetSeconds(time)
        if duration >= 0 {
            duration = seconds
            observedDuration?(seconds)
        }
    }
    
    func observeStatusValue(change: [NSKeyValueChangeKey : Any]?) {
        guard let newChange = change, let value = newChange[.newKey] as? NSNumber,let status = AVPlayer.Status(rawValue: value.intValue) else{
            observedStatus?(.unknown)
            return
        }
        observedStatus?(status)
    }
    
    func observeLoadedTimeRangesValue(change: [NSKeyValueChangeKey : Any]?) {
        guard let newChange = change, let value = newChange[.newKey] as? [NSValue],let timeRange = value.first?.timeRangeValue else {
            return
        }
        
        let startSeconds = CMTimeGetSeconds(timeRange.start)
        let durationSeconds = CMTimeGetSeconds(timeRange.duration)
        let bufferTime = startSeconds + durationSeconds
        
        if bufferTime >= duration {
            observedBufferFull?(true)
        }
        
        if let player = self.player,player.timeControlStatus == .playing {
            observedKeepUp?(true)
        }
        observedLoadedTime?(bufferTime)
    }
    
    func observePlaybackBufferEmptyValue(change: [NSKeyValueChangeKey : Any]?) {
        guard let newChange = change, let value = newChange[.newKey] as? NSNumber else{
            return
        }
        observedBufferEmpty?(value.boolValue)
    }
    
    func observePlaybackBufferFullValue(change: [NSKeyValueChangeKey : Any]?) {
        guard let newChange = change, let value = newChange[.newKey] as? NSNumber else{
            return
        }
        observedBufferFull?(value.boolValue)
    }
    
    func observePlaybackLikelyToKeepUpValue(change: [NSKeyValueChangeKey : Any]?) {
        guard let newChange = change, let value = newChange[.newKey] as? NSNumber else{
            return
        }
//        observedKeepUp?(value.boolValue)
    }
    
    @objc func observePlayToEndTime(note: Notification) {
        guard let item = note.object as? AVPlayerItem,player?.currentItem == item else{
            return
        }
        observedPlayDone?()
    }
    
    func observerItemError(_ item : AVPlayerItem) {
        item.addObserver(self, forKeyPath: itemErrorKeyPath, options: .new, context: &itemErrorContext)
    }
    
    func removeObserverItemError(_ item : AVPlayerItem) {
        item.removeObserver(self, forKeyPath: itemErrorKeyPath, context: &itemErrorContext)
    }
    
    func observerItemDuration(_ item : AVPlayerItem) {
        item.addObserver(self, forKeyPath: itemDurationKeyPath, options: .new, context: &itemDurationContext)
    }
    
    func removeObserverItemDuration(_ item : AVPlayerItem) {
        item.removeObserver(self, forKeyPath: itemDurationKeyPath, context: &itemDurationContext)
    }
    
    func observerItemStatus(_ item : AVPlayerItem) {
        item.addObserver(self, forKeyPath: itemStatusKeyPath, options: .new, context: &itemStatusContext)
    }
    
    func removeObserverItemStatus(_ item : AVPlayerItem) {
        item.removeObserver(self, forKeyPath: itemStatusKeyPath, context: &itemStatusContext)
    }
    
    func observerItemLoadedTimeRanges(_ item : AVPlayerItem) {
        item.addObserver(self, forKeyPath: itemLoadedTimeRangesKeyPath, options: .new, context: &itemLoadedTimeRangesContext)
    }
    
    func removeObserverItemLoadedTimeRanges(_ item : AVPlayerItem) {
        item.removeObserver(self, forKeyPath: itemLoadedTimeRangesKeyPath, context: &itemLoadedTimeRangesContext)
    }
    
    func observerItemPlaybackBufferEmpty(_ item : AVPlayerItem) {
        item.addObserver(self, forKeyPath: itemPlaybackBufferEmptyKeyPath, options: .new, context: &itemPlaybackBufferEmptyContext)
    }
    
    func removeObserverItemPlaybackBufferEmpty(_ item : AVPlayerItem) {
        item.removeObserver(self, forKeyPath: itemPlaybackBufferEmptyKeyPath, context: &itemPlaybackBufferEmptyContext)
    }
    
    func observerItemPlaybackLikelyToKeepUp(_ item : AVPlayerItem) {
        item.addObserver(self, forKeyPath: itemPlaybackLikelyToKeepUpKeyPath, options: .new, context: &itemPlaybackLikelyToKeepUpContext)
    }
    
    func removeObserverItemPlaybackLikelyToKeepUp(_ item : AVPlayerItem) {
        item.removeObserver(self, forKeyPath: itemPlaybackLikelyToKeepUpKeyPath, context: &itemPlaybackLikelyToKeepUpContext)
    }
    
    func observerItemPlaybackBufferFull(_ item : AVPlayerItem) {
        item.addObserver(self, forKeyPath: itemPlaybackBufferFullKeyPath, options: .new, context: &itemPlaybackBufferFullContext)
    }
    
    func removeObserverItemPlaybackBufferFull(_ item : AVPlayerItem) {
        item.removeObserver(self, forKeyPath: itemPlaybackBufferFullKeyPath, context: &itemPlaybackBufferFullContext)
    }
    
    func observerItemPlayToEndTime(_ item : AVPlayerItem) {
        NotificationCenter.default.addObserver(self, selector: #selector(observePlayToEndTime(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
    }
    
    func removeObserverItemPlayToEndTime(_ item : AVPlayerItem) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
    }
    
    func observerRateForPlayer(_ player : AVPlayer) {
        let interval = CMTimeMake(value: 600, timescale: 600)
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: nil) { [weak self]time in
            guard let self = self else { return }
            let current = CMTimeGetSeconds(time)
            self.currentPosition = current
            let drop = round(current - self.previousPosition)
            if self.duration == 0 {
                return
            }
            
            self.previousPosition = self.currentPosition

            if drop == 1.0 {
                // playing
            }else if drop == 0 {
                // paused
                return
            }else if drop > 1 {
                // forwarded
                return;
            }else if drop < 0 {
                // backwarded
                return;
            }
            
            if player.timeControlStatus == .playing {
                self.observedPosition?(current)
            }
        }
    }
        
}
