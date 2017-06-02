//
//  NonClippingLabel.swift
//  Ciclyc
//
//  Created by Benjamin Völker on 16/09/2016.
//  Copyright © 2016 Benjamin Völker. All rights reserved.
//

import UIKit

class NonClippingLabel: UILabel {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
 
  @IBInspectable var topInset: CGFloat = 0.0
  @IBInspectable var bottomInset: CGFloat = 0.0
  @IBInspectable var leftInset: CGFloat = 0.0
  @IBInspectable var rightInset: CGFloat = 7.0
  
  
  
  override func drawText(in rect: CGRect) {
    let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
    super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
  }
  
  override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
    
    return self.bounds.insetBy(dx: CGFloat(15.0), dy: CGFloat(15.0))
  }
  /*
  override func intrinsicContentSize() -> CGSize {
    var intrinsicSuperViewContentSize = super.intrinsicContentSize()
    intrinsicSuperViewContentSize.height += topInset + bottomInset
    intrinsicSuperViewContentSize.width += leftInset + rightInset
    return intrinsicSuperViewContentSize
  }*/
}
