//
//  UIViewExtensions.swift
//  SnipIt
//
//  Created by Hunter Meyer on 3/5/15.
//  Copyright (c) 2015 Hunter Meyer. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func toggleFade(duration: NSTimeInterval = 0.5, delay: NSTimeInterval = 0.0, completion: ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        self.alpha == 0.0 ? self.fadeIn(duration: duration, delay: delay, completion: completion) : self.fadeOut(duration: duration, delay: delay, completion: completion)
    }
    
    func fadeIn(duration: NSTimeInterval = 0.5, delay: NSTimeInterval = 0.0, completion: ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: { self.alpha = 1.0 }, completion: completion)
    }
    
    func fadeOut(duration: NSTimeInterval = 0.5, delay: NSTimeInterval = 0.0, completion: ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseOut, animations: { self.alpha = 0.0 }, completion: completion)
    }
}