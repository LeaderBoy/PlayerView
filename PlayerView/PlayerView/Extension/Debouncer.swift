//
//  Debouncer.swift
//  EnjoyCopying
//
//  Created by 杨志远 on 2019/1/10.
//  Copyright © 2019 BaQiWL. All rights reserved.
// 来源
// https://stackoverflow.com/questions/27116684/how-can-i-debounce-a-method-call

import Foundation

class Debouncer {
    
    // MARK: - Properties
    private let queue = DispatchQueue.main
    private var workItem = DispatchWorkItem(block: {})
    private var interval: TimeInterval
    
    // MARK: - Initializer
    init(seconds: TimeInterval) {
        self.interval = seconds
    }
    
    // MARK: - Debouncing function
    func debounce(action: @escaping (() -> Void)) {
        workItem.cancel()
        workItem = DispatchWorkItem(block: { action() })
        queue.asyncAfter(deadline: .now() + interval, execute: workItem)
    }
    
    // MARK: - Debouncing action
    func action(action: @escaping (() -> Void)) {
        workItem = DispatchWorkItem(block: { action() })
        queue.asyncAfter(deadline: .now() + interval, execute: workItem)
    }
    
    // MARK: - Cancel action
    func cancel() {
        workItem.cancel()
    }
}
