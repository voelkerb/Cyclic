//
//  fadeLabel.swift
//  Ciclyc
//
//  Created by Benjamin Völker on 19/10/2016.
//  Copyright © 2016 Benjamin Völker. All rights reserved.
//

import UIKit

extension UILabel {
  func fadeTransition(duration:CFTimeInterval) {
    let animation:CATransition = CATransition()
    animation.timingFunction = CAMediaTimingFunction(name:
      kCAMediaTimingFunctionEaseInEaseOut)
    animation.type = kCATransitionFade
    animation.duration = duration
    self.layer.add(animation, forKey: kCATransitionFade)
  }
  
}
