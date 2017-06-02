//
//  Design.swift
//  Ciclyc
//
//  Created by Benjamin Völker on 19/09/2016.
//  Copyright © 2016 Benjamin Völker. All rights reserved.
//

import UIKit

class Design: NSObject {
  
  // Standard titles for buttons
  let buttonTitleStart = "Start"
  let buttonTitleBack = "Back"
  let buttonTitleReset = "Reset"
  let buttonTitlePause = "Pause"
  let buttonTitleResume = "Resume"
  let buttonTitleSave = "Save"
  let buttonTitleCancel = "Cancel"
  // Titles for the beginning buttons
  // Titles of all UI Elements
  let buttonTitleStartWork = "Start\nWorkout"
  let buttonTitleBrowseWork = "Browse\nWorkouts"
  let buttonTitleSettings = "Settings"
  //var appColor = UIColor.init(colorLiteralRed: 233.0/255.0, green: 255.0/255.0, blue: 55.0/255.0, alpha: 1)
  //var bgColor = UIColor.black
  
  
  /*
   * Creates a button with a given title and selector
   * The style is fixed
   */
  func makeButton(text:String, action: Selector ) -> UIButton {
    let sett = Settings.sharedInstance
    
    let button = UIButton()
    button.setTitleColor(sett.appColor, for: .normal)
    button.setTitleColor(sett.bgColor, for: .highlighted)
    button.setTitle(text, for: .normal)
    button.titleLabel!.font =  UIFont.systemFont(ofSize: 40.0)
    button.addTarget(self,action: action,for: .touchUpInside)
    button.setBackgroundImage(imageWithColor(color: sett.bgColor), for: .normal)
    button.setBackgroundImage(imageWithColor(color: sett.appColor), for: .highlighted)
    button.titleLabel?.lineBreakMode = .byWordWrapping;
    // you probably want to center it
    button.titleLabel?.textAlignment = .center;
    //button.backgroundColor = UIColor.clear
    button.layer.cornerRadius = 5
    button.layer.borderWidth = 1
    button.layer.borderColor = sett.appColor.cgColor
    let layer:(CALayer) = button.layer
    layer.cornerRadius = 5
    layer.masksToBounds = true
    button.titleLabel?.adjustsFontSizeToFitWidth = true;
    //button.titleLabel?.lineBreakMode = .byClipping;
    return button
  }
    
  func imageWithColor(color: UIColor) -> UIImage {
    let rect = CGRect(x: 0, y: 0, width: 20, height: 20)
    UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, 0)
    color.setFill()
    UIRectFill(rect)
    let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return image
  }
  
  
}
