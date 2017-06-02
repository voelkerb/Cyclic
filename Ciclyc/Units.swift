//
//  Speed.swift
//  Ciclyc
//
//  Created by Benjamin Völker on 14/09/2016.
//  Copyright © 2016 Benjamin Völker. All rights reserved.
//

import Foundation


class Speed {
  let unitKiloMeterPerHour = "km/h"
  let unitMeterPerSecond = "m/s"
  let unitTimePerKiloMeter = "time/km"
  let speedDescription = "speed"
  
  enum SpeedUnit {
    case kiloMeterPerHour, meterPerSecond, timePerKiloMeter
  }
  
  var speed : Double = 0.0
  var unit : SpeedUnit = SpeedUnit.kiloMeterPerHour
  
  init(speed: Double, unit: SpeedUnit) {
    self.speed = speed
    self.unit = unit
  }
  
  func unitToString() -> String {
    switch unit {
    case .kiloMeterPerHour:
      return unitKiloMeterPerHour
    case .meterPerSecond:
      return unitMeterPerSecond
    case .timePerKiloMeter:
      return unitTimePerKiloMeter
    }
  }
  
  func getDescription() -> String {
    return speedDescription
  }
  
  func getValue() -> Double {
    switch unit {
    case .kiloMeterPerHour:
      return speed*3.6
    case .meterPerSecond:
      return speed
    case .timePerKiloMeter:
      return (1/(speed*(60.0/1000.0)))
    }
  }
  
  func getValueAsString() -> String {
    switch unit {
    case .kiloMeterPerHour:
      return String(format: "%.2f", speed*3.6)
    case .meterPerSecond:
      return String(format: "%.2f", speed)
    case .timePerKiloMeter:
      // Sicne we basically have a duration here, we must make things differently
      let duration = (1/(speed*(60.0/1000.0)))
      print("dur:", duration)
      if duration < Double.infinity {
        let sec = Int(duration)*60 + Int((duration - Double(Int(duration)))*60.0)
        return Time().getStrWithZerosForMin(duration: sec)
      } else {
        return "inf"
      }
    }
  }

  
  func switchUnit() {
    // Switch between units here
    switch self.unit {
    case .kiloMeterPerHour:
      self.unit = .meterPerSecond
    case .meterPerSecond:
      self.unit = .timePerKiloMeter
    case .timePerKiloMeter:
      self.unit = .kiloMeterPerHour
    }
  }
}

class AvgSpeed:Speed {
  let avgSpeedDescription = "avg speed"
  override func getDescription() -> String {
    return avgSpeedDescription
  }
}

class MaxSpeed:Speed {
  let amaxSpeedDescription = "max speed"
  override func getDescription() -> String {
    return amaxSpeedDescription
  }
}


class Distance {
  
  let unitKiloMeter = "km"
  let unitMeter = "m"
  let distanceDescription = "distance"
  
  enum DistanceUnit {
    case kiloMeter, meter
  }
  
  var distance : Double = 0.0
  var unit : DistanceUnit = DistanceUnit.kiloMeter
  
  init(distance: Double, unit: DistanceUnit) {
    self.distance = distance
    self.unit = unit
  }
  
  func unitToString() -> String {
    switch unit {
    case .kiloMeter:
      return unitKiloMeter
    case .meter:
      return unitMeter
    }
  }
  
  func getDescription() -> String {
    return distanceDescription
  }
  
  
  func getValue() -> Double {
    switch unit {
    case .kiloMeter:
      return distance*0.001
    case .meter:
      return distance
    }
  }
  
  func switchUnit() {
    switch self.unit {
    case .kiloMeter:
      self.unit = .meter
    case .meter:
      self.unit = .kiloMeter
    }
  }
}


class Time {
  let unitDuration = "dur"
  let unitTime = "time"
  
  func getStr(time: NSDate) ->String {
    var timeStr = ""
    // Get current time in format /h/min/sec
    let components = NSCalendar.current.dateComponents([.hour, .minute, .second], from: time as Date)
    // Get unwrapped values for hour minute second
    let hour = components.hour!
    let minute = components.minute!
    let second = components.second!
    timeStr = "\(hour):"
    // If minute is 0-9 add a 0 to the time to display 12:01 instead of 12:1
    if (minute < 10) { timeStr += "0"}
    timeStr += "\(minute):"
    // If second is 0-9 add a 0 to the time to display 12:01:01 instead of 12:01:1
    if (second < 10) { timeStr += "0"}
    timeStr += "\(second)"
    return timeStr
  }
  
  
  func getStr(dateWithTime: NSDate) ->String {
    var timeStr = ""
    // Get current time in format /h/min/sec
    let components = NSCalendar.current.dateComponents([.day, .month, .year,
                                                        .hour, .minute, .second],
                                                       from: dateWithTime as Date)
    // Get unwrapped values for hour minute second
    let hour = components.hour!
    let minute = components.minute!
    let second = components.second!
    let day = components.day!
    let month = components.month!
    let year = components.year!
    // If day is 0-9 add a 0 to the day to display 01.12.1999 instead of 1.12.1999
    if (day < 10) { timeStr += "0"}
    timeStr += "\(day)."
    // If month is 0-9 add a 0 to the day to display 01.01.1999 instead of 01.1.1999
    if (month < 10) { timeStr += "0"}
    timeStr += "\(month)."
    timeStr += "\(year), "
    timeStr += "\(hour):"
    // If minute is 0-9 add a 0 to the time to display 12:01 instead of 12:1
    if (minute < 10) { timeStr += "0"}
    timeStr += "\(minute):"
    // If second is 0-9 add a 0 to the time to display 12:01:01 instead of 12:01:1
    if (second < 10) { timeStr += "0"}
    timeStr += "\(second)"
    return timeStr
  }
  
  func getStrWithZerosForMin(duration: Int) ->String {
    var timeStr = ""
    // Calculate seconds minutes and hours passed
    let seconds: Int = duration % 60
    let minutes: Int = (duration / 60) % 60
    let hours: Int = duration / 3600
    // If your activity took more than one hour
    if (hours > 0) { timeStr += "\(hours):" }
    // If your activity took more than one minute
    if (minutes > 0) {
      // Show 1:09 instead of 1:9
      if (hours > 0 && minutes < 10) { timeStr += "0" }
      timeStr += "\(minutes):"
    } else {
      timeStr += "00:"
    }
    // Show 1:09:09 instead of 1:09:9
    if (seconds < 10) { timeStr += "0" }
    timeStr += "\(seconds)"
    return timeStr
  }
  
  func getStr(duration: Int) ->String {
    var timeStr = ""
    // Calculate seconds minutes and hours passed
    let seconds: Int = duration % 60
    let minutes: Int = (duration / 60) % 60
    let hours: Int = duration / 3600
    // If your activity took more than one hour
    if (hours > 0) { timeStr += "\(hours):" }
    // If your activity took more than one minute
    if (minutes > 0) {
      // Show 1:09 instead of 1:9
      if (hours > 0 && minutes < 10) { timeStr += "0" }
      timeStr += "\(minutes):"
    }
    // Show 1:09:09 instead of 1:09:9
    if (minutes > 0 && seconds < 10) { timeStr += "0" }
    timeStr += "\(seconds)"
    return timeStr
  }
}
