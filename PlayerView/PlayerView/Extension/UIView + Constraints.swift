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
//  UIView + Constraints.swift
//  PlayerView
//
//  Created by 杨志远 on 2019/11/20.
//

import UIKit

extension UIView {
    
    /// edge layout relative to view
    /// - Parameter view: relatived view
    /// - Parameter insets: edgeInsets
    @discardableResult
    func edges(to view: UIView,insets : UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        
        let left    = leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: insets.left)
        let right   = trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: insets.right)
        let top     = topAnchor.constraint(equalTo: view.topAnchor,constant: insets.top)
        let bottom  = bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: insets.bottom)
        
        NSLayoutConstraint.activate([
            left,right,top,bottom
        ])
        return [top,left,bottom,right]
    }
    
    /// edge layout relative to view.safeAreaLayoutGuide
    /// - Parameter view: relatived view
    /// - Parameter insets: edgeInsets
    @discardableResult
    func edgesSafearea(to view: UIView,in controller: UIViewController,insets : UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        
        var top     : NSLayoutConstraint
        var left    : NSLayoutConstraint
        var bottom  : NSLayoutConstraint
        var right   : NSLayoutConstraint

        if #available(iOS 11.0, *) {
            left = leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
            right = trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
            bottom = bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            top = topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        } else {
            left    = leadingAnchor.constraint(equalTo: view.leadingAnchor)
            right   = trailingAnchor.constraint(equalTo: view.trailingAnchor)
            bottom  = bottomAnchor.constraint(equalTo: controller.bottomLayoutGuide.topAnchor)
            top     = topAnchor.constraint(equalTo: controller.topLayoutGuide.bottomAnchor)
        }
        NSLayoutConstraint.activate([top,left,bottom,right])
        
        return [top,left,bottom,right]
    }
    
    
    func removeConstraints() {
        if let superView = self.superview {
            for constraint in superView.constraints {
                if let v = constraint.firstItem as? UIView,v == self {
                    superView.removeConstraint(constraint)
                }
                if let v = constraint.secondItem as? UIView,v == self {
                    superView.removeConstraint(constraint)
                }
            }
        }
        removeWidthConstraints()
        removeHeightConstraints()
    }
    
    func removeWidthConstraints() {
        for constraint in constraints {
            if #available(iOS 10.0, *) {
                if constraint.firstAnchor == widthAnchor {
                    removeConstraint(constraint)
                }
            } else {
                if constraint.firstAttribute == .width {
                    removeConstraint(constraint)
                }
            }
        }
    }
    
    func removeHeightConstraints() {
        for constraint in constraints {
            if #available(iOS 10.0, *) {
                if constraint.firstAnchor == heightAnchor {
                    removeConstraint(constraint)
                }
            } else {
                if constraint.firstAttribute == .height {
                    removeConstraint(constraint)
                }
            }
        }
    }
    
    
    
    
    
}
