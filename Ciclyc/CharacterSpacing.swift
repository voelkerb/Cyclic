//
//  CharacterSpacing.swift
//  Ciclyc
//
//  Created by Benjamin Völker on 21/09/2016.
//  Copyright © 2016 Benjamin Völker. All rights reserved.
//

import UIKit

extension UILabel {
  func addCharactersSpacing(spacing:CGFloat, text:String) {
    let attributedString = NSMutableAttributedString(string: text)
    attributedString.addAttribute(NSKernAttributeName, value: spacing, range: NSMakeRange(0, text.characters.count))
    self.attributedText = attributedString
  }
}
