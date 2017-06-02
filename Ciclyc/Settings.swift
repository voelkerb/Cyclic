//
//  Settings.swift
//  Ciclyc
//
//  Created by Benjamin Völker on 16/09/2016.
//  Copyright © 2016 Benjamin Völker. All rights reserved.
//

import UIKit

class Settings: NSObject {
  
  // Enumeration for the color which is changed
  enum ColorType {
    case applicationColor, backgroundColor
  }
  
  // Threshold for the minimal distance between foreground and background color of the application
  var distanceThreshold:CGFloat = 25.0

  // Default values for all settings
  var appColor = UIColor.init(colorLiteralRed: 233.0/255.0, green: 255.0/255.0, blue: 55.0/255.0, alpha: 1)
  var bgColor = UIColor.black
  var showSpeed = true
  var showDistance = true
  var showAvgSpeed = true
  var showDuration = true
  var showMap = true
  var userName:(NSString)! = nil
  var female:Bool = false
  var size:Int = 180
  var weight:Int = 70
  
  // The notifications for a user profile change and a color change notification
  static let NotificationColorChanged:NSNotification = NSNotification(name: NSNotification.Name(rawValue: "appColorChanged"), object: nil)
  static let NotificationPofileChanged:NSNotification = NSNotification(name: NSNotification.Name(rawValue: "profileChanged"), object: nil)
  
  // This class is singletone
  static let sharedInstance = Settings()
  
  // Making thia function private prevents others from using the default '()' initializer for this class.
  private override init() {
    // Try to decode all data from user defaults
    if let userSelectedColorData = UserDefaults.standard.object(forKey: "color") as? NSData {
      if let userSelectedColor = NSKeyedUnarchiver.unarchiveObject(with: userSelectedColorData as Data) as? UIColor {
        appColor = userSelectedColor
      }
    }
    if let userSelectedColorDataBG = UserDefaults.standard.object(forKey: "bgColor") as? NSData {
      if let userSelectedColorBG = NSKeyedUnarchiver.unarchiveObject(with: userSelectedColorDataBG as Data) as? UIColor {
        bgColor = userSelectedColorBG
      }
    }
    if let userSelectedShowSpeedData = UserDefaults.standard.object(forKey: "showSpeed") as? NSData {
      if let userSelectedShowSpeed = NSKeyedUnarchiver.unarchiveObject(with: userSelectedShowSpeedData as Data) as? Bool {
        showSpeed = userSelectedShowSpeed
      }
    }
    if let userSelectedShowAvgSpeedData = UserDefaults.standard.object(forKey: "showAvgSpeed") as? NSData {
      if let userSelectedShowAvgSpeed = NSKeyedUnarchiver.unarchiveObject(with: userSelectedShowAvgSpeedData as Data) as? Bool {
        showAvgSpeed = userSelectedShowAvgSpeed
      }
    }
    if let userSelectedShowDistanceData = UserDefaults.standard.object(forKey: "showDistance") as? NSData {
      if let userSelectedShowDistance = NSKeyedUnarchiver.unarchiveObject(with: userSelectedShowDistanceData as Data) as? Bool {
        showDistance = userSelectedShowDistance
      }
    }
    if let userSelectedShowDurationData = UserDefaults.standard.object(forKey: "showDuration") as? NSData {
      if let userSelectedShowDuration = NSKeyedUnarchiver.unarchiveObject(with: userSelectedShowDurationData as Data) as? Bool {
        showDuration = userSelectedShowDuration
      }
    }
    if let userSelectedShowMapData = UserDefaults.standard.object(forKey: "showMap") as? NSData {
      if let userSelectedShowMap = NSKeyedUnarchiver.unarchiveObject(with: userSelectedShowMapData as Data) as? Bool {
        showMap = userSelectedShowMap
      }
    }
    if let userSelectedUserNameData = UserDefaults.standard.object(forKey: "userName") as? NSData {
      if let userSelectedUserName = NSKeyedUnarchiver.unarchiveObject(with: userSelectedUserNameData as Data) as? NSString {
        userName = userSelectedUserName
      }
    }
    if let userSelectedFemaleData = UserDefaults.standard.object(forKey: "female") as? NSData {
      if let userSelectedFemale = NSKeyedUnarchiver.unarchiveObject(with: userSelectedFemaleData as Data) as? Bool {
        female = userSelectedFemale
      }
    }
    if let userSelectedSizeData = UserDefaults.standard.object(forKey: "size") as? NSData {
      if let userSelectedSize = NSKeyedUnarchiver.unarchiveObject(with: userSelectedSizeData as Data) as? Int {
        size = userSelectedSize
      }
    }
    if let userSelectedWeightData = UserDefaults.standard.object(forKey: "weight") as? NSData {
      if let userSelectedWeight = NSKeyedUnarchiver.unarchiveObject(with: userSelectedWeightData as Data) as? Int {
        size = userSelectedWeight
      }
    }
  }


  /*
   * Stores all data in user defaults
   */
  func store() {
    var data : NSData = NSKeyedArchiver.archivedData(withRootObject: appColor) as NSData
    UserDefaults.standard.set(data, forKey: "color")
    data = NSKeyedArchiver.archivedData(withRootObject: userName) as NSData
    UserDefaults.standard.set(data, forKey: "userName")
    data = NSKeyedArchiver.archivedData(withRootObject: bgColor) as NSData
    UserDefaults.standard.set(data, forKey: "bgColor")
    data = NSKeyedArchiver.archivedData(withRootObject: showSpeed) as NSData
    UserDefaults.standard.set(data, forKey: "showSpeed")
    data = NSKeyedArchiver.archivedData(withRootObject: showAvgSpeed) as NSData
    UserDefaults.standard.set(data, forKey: "showAvgSpeed")
    data = NSKeyedArchiver.archivedData(withRootObject: showDistance) as NSData
    UserDefaults.standard.set(data, forKey: "showDistance")
    data = NSKeyedArchiver.archivedData(withRootObject: showDuration) as NSData
    UserDefaults.standard.set(data, forKey: "showDuration")
    data = NSKeyedArchiver.archivedData(withRootObject: showMap) as NSData
    UserDefaults.standard.set(data, forKey: "showMap")
    data = NSKeyedArchiver.archivedData(withRootObject: female) as NSData
    UserDefaults.standard.set(data, forKey: "female")
    data = NSKeyedArchiver.archivedData(withRootObject: size) as NSData
    UserDefaults.standard.set(data, forKey: "size")
    data = NSKeyedArchiver.archivedData(withRootObject: weight) as NSData
    UserDefaults.standard.set(data, forKey: "weight")
    UserDefaults.standard.synchronize()
  }
  
  
  

}
