//
//  WorkingOut.swift
//  Ciclyc
//
//  Created by Benjamin Völker on 21/09/2016.
//  Copyright © 2016 Benjamin Völker. All rights reserved.
//

import UIKit
import CoreLocation
import HealthKit

// Functions the delegate has to implement
protocol WorkOutDelegate {
  func durationUpdated(duration: Int)
  func speedUpdated(speed: Speed)
  func avgSpeedUpdated(avgSpeed: Speed)
  func locationUpdated(location: CLLocation)
  func distanceUpdated(distance: Distance)
}
extension WorkOutDelegate {
  func durationUpdated(duration: Int){}
  func speedUpdated(speed: Speed){}
  func avgSpeedUpdated(avgSpeed: Speed){}
  func locationUpdated(location: CLLocation){}
  func distanceUpdated(distance: Distance){}
}
// Functions the delegate has to implement
protocol WorkOutMapDelegate {
  func resetMap()
  func locationUpdated(location: CLLocation, running: Bool)
}
extension WorkOutMapDelegate {
  func resetMap(){}
  func locationUpdated(location: CLLocation, running: Bool){}
}


class WorkOut: NSObject, CLLocationManagerDelegate, NSCoding {
  // The delegate objects
  var delegate: WorkOutDelegate?
  var mapDelegate: WorkOutMapDelegate?
  
  let newWorkoutDefaultName = "New Workout"
  
  // Enable Debug messages
  var debug = false
  
  // Timers for speed update, timer update and clock update
  lazy var speedTimer = Timer()
  lazy var timer = Timer()
  
  // If person is currently moving or not
  var running = false
  // If the time should be shown or the current duration
  var showTime = false
  // Time the speed was not updated
  var speedUpdated = 0
  // Location manager object
  var locationManager: CLLocationManager = CLLocationManager()
  
  // The starttime of the exercise
  var startTime:NSDate = NSDate()
  // The seconds the user has paused
  var pauseSec = 0
  // The start time of the pause
  var pauseTime:NSDate = NSDate()
  
  
  // The start location
  var startLocation: CLLocation! = nil
  var currentLocation: CLLocation! = nil
  
  // Variables holding the current speed/avgSpeed/distance and duration
  var speed = Speed(speed: 0, unit: .kiloMeterPerHour)
  var maxSpeed = MaxSpeed(speed: 0, unit: .kiloMeterPerHour)
  var avgSpeed = AvgSpeed(speed: 0, unit: .kiloMeterPerHour)
  var distance = Distance(distance: 0, unit: .kiloMeter)
  var duration = 0
  var workoutName = ""
  
  // Array holding all location points
  lazy var locations = [CLLocation]()
  
  override init() {
    super.init()
    // Start the location manager and set the desired accuracy and information level
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.delegate = self
    locationManager.distanceFilter = 10
    locationManager.requestAlwaysAuthorization()
    locationManager.activityType = .fitness
    locationManager.allowsBackgroundLocationUpdates = true
    // Set default name of this workout
    workoutName = newWorkoutDefaultName
    if (debug) { print("init of workout") }
    running = false
    //locationManager.startUpdatingHeading()
  }
  
  /*
   * Start a new workout
   */
  func start() {
    // Reset start location, so that next location update is set as start location
    running = true
    self.distance.distance = 0;
    self.startLocation = nil
    // Start the timer to update labels
    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    // Set start time
    self.startTime = NSDate()
    locationManager.startUpdatingLocation()
    // Prevent this app from going to sleep
    UIApplication.shared.isIdleTimerDisabled = true
  }
  
  /*
   * Start a new workout
   */
  func stop() {
    // Reset start location, so that next location update is set as start location
    running = false
    // Invalidate the timer
    timer.invalidate()
    locationManager.stopUpdatingLocation()
    // Let this app go sleeping if wanted
    UIApplication.shared.isIdleTimerDisabled = false
    // TODO:
    // Do afterwards regulation stuff, like recalculating distance speed and so on
    // Inform delegate on avg speed change
    self.avgSpeed.speed = self.distance.distance/Double(self.duration)
    self.delegate?.avgSpeedUpdated(avgSpeed: self.avgSpeed)
  }
  
  /*
   * Pause a new workout
   */
  func pause() {
    // Change running state
    running = false
    // We do not need to update labels other than the speed label anymore
    timer.invalidate()
    // Set start date of the current pause periode
    pauseTime = NSDate()
    // Let this app go sleeping if wanted
    UIApplication.shared.isIdleTimerDisabled = false
    // Recalculate average
    self.avgSpeed.speed = self.distance.distance/Double(self.duration)
    self.delegate?.avgSpeedUpdated(avgSpeed: self.avgSpeed)
  }
  
  /*
   * Resume a new workout
   */
  func resume() {
    // Change running state
    running = true
    // Start the timer to update all labels
    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    // Calculate seconds from start of pause and add it to pause variable which is subtracted from duration
    let rsSeconds = raisedSeconds(from: pauseTime as Date, to: NSDate() as Date)
    pauseSec = pauseSec + rsSeconds
    if (debug) { print("Seconds paused: \(rsSeconds)ms") }
    // Prevent this app from going to sleep
    UIApplication.shared.isIdleTimerDisabled = true
  }
  
  /*
   * Resets a workout
   */
  func reset() {
    // Set all variables to 0
    self.distance.distance = 0.0
    self.duration = 0
    self.pauseSec = 0
    self.distance.distance = 0.0
    self.avgSpeed.speed = 0.0
    // Reset start date
    self.startTime = NSDate()
    // Delete all previously visited locations
    self.locations.removeAll(keepingCapacity: false)
    // Change running state
    self.running = false
    // Let this app go sleeping if wanted
    UIApplication.shared.isIdleTimerDisabled = false
    
    // Delegates need to potentially update their values
    delegate?.durationUpdated(duration: self.duration)
    delegate?.speedUpdated(speed: self.speed)
    delegate?.avgSpeedUpdated(avgSpeed: self.avgSpeed)
    if self.locations.last != nil {
      delegate?.locationUpdated(location: self.locations.last!)
      mapDelegate?.locationUpdated(location: self.locations.last!, running: false)
    }
    delegate?.distanceUpdated(distance: self.distance)
    mapDelegate?.resetMap()
  }
  

  /*
   * Returns the amount of seconds from another date
   */
  private func raisedSeconds(from date1: Date, to date2: Date) -> Int {
    return Calendar.current.dateComponents([.second], from: date1, to: date2).second ?? 0
  }
  
  /*
   * Updating all values
   */
  @objc private func update() {
    // Update average speed
    if (self.duration < 5) {
      self.avgSpeed.speed = 0.0
    } else {
      // Take average by looping over visited locations instead of duration average
      var locAvgSpeed = 0.0
      for location in locations {
        locAvgSpeed += location.speed
      }
      if locations.count > 0 {
        locAvgSpeed /= Double(locations.count)
      }
      let durAvgSpeed = self.distance.distance/Double(self.duration)
      // Lowpass for average here
      if (self.avgSpeed.speed == 0) {
        self.avgSpeed.speed = locAvgSpeed
      } else {
        self.avgSpeed.speed = 0.9*self.avgSpeed.speed + 0.05*locAvgSpeed + 0.05*durAvgSpeed
      }
    }
    
    // Update speed
    // If the speed has not updated for 6 seconds and was not set to 0 before
    if speedUpdated > 6 && self.speed.speed != 0 {
      if (debug) { print("Speed did not update") }
      // Set it to zero
      self.speed.speed = 0.0
      // Inform delegate on speed change
      self.delegate?.speedUpdated(speed: self.speed)
      // Else, count speed not updated timer (is resetted in location update)
    } else {
      speedUpdated = speedUpdated + 1
    }
    
    self.delegate?.avgSpeedUpdated(avgSpeed: self.avgSpeed)
    
    // Update duration
    // If not running, the seconds variable holds the duration
    var timePassed = self.duration
    // If running, get the time passed from the start time of the activity
    // With the amount of pause time subtracted
    if (running) {
      timePassed = raisedSeconds(from: startTime as Date, to: NSDate() as Date) - pauseSec
    }
    // Update duration
    self.duration = timePassed;
    // Inform delegate on duration change
    self.delegate?.durationUpdated(duration: self.duration)
  }
  

  
  // MARK: Location manager delegate
  /*
   * Location manager delegate function
   */
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    // For all new locations
    for location in locations {
      if UIApplication.shared.applicationState == .active {
        print("App is in foreground. New location is %@", location)
      } else {
        print("App is backgrounded. New location is %@", location)
      }
      
      // If accuracy is good enough
      if location.horizontalAccuracy < 20 {
        // Update traveled distance if running
        if self.locations.count > 0 && running {
          self.distance.distance += location.distance(from: self.locations.last!)
          self.delegate?.distanceUpdated(distance: self.distance)
        }
        
        // Add location new location if running
        if (running) {
          // Set new startlocation if needed
          if startLocation == nil {
            startLocation = location
          }
          self.locations.append(location)
          self.delegate?.locationUpdated(location: location)
        }
        currentLocation = location
        self.mapDelegate?.locationUpdated(location: location, running: running)
        
        // Get current speed and check for reasonability
        let thespeed = location.speed
        if debug { print(String(format: "%.0f km/h", thespeed * 3.6)) }
        // If speed is too high (over 360km/h) or smaller 0 set it to 0
        if thespeed >= 0.0 && thespeed <= 100.0 {
          self.speed.speed = Double(thespeed)
          // Check for new maximum speed
          if self.speed.speed > self.maxSpeed.speed {
            self.maxSpeed.speed = self.speed.speed
          }
        } else {
          self.speed.speed = 0.0
        }
        self.delegate?.speedUpdated(speed: self.speed)
        // Speed not updated counter is resetted
        speedUpdated = 0
      }
    }
  }
  
  override var description: String {
    return "\(self.workoutName), \(self.startTime), distance: "
      + String(format: "%.2f", self.distance.getValue()) + " duration: \(self.duration)"
  }
  override var debugDescription: String {
    return "\(self.workoutName), \(self.startTime), distance: "
      + String(format: "%.2f", self.distance.getValue()) + " duration: \(self.duration)"
  }
  
  
  // MARK: NSCoding
  func encode(with aCoder: NSCoder) {
    // Encode all needed values
    aCoder.encode(self.startLocation, forKey: "startLocation")
    aCoder.encode(self.locations, forKey: "locations")
    aCoder.encode(self.distance.distance, forKey: "distance")
    aCoder.encode(self.duration, forKey: "duration")
    aCoder.encode(self.avgSpeed.speed, forKey: "avgSpeed")
    aCoder.encode(self.maxSpeed.speed, forKey: "maxSpeed")
    aCoder.encode(self.startTime, forKey: "startTime")
    aCoder.encode(self.workoutName, forKey: "workoutName")
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    // Init ourself
    self.init()
    // Decode all needed values
    if let startLocation = aDecoder.decodeObject(forKey: "startLocation") as? CLLocation {
      self.startLocation = startLocation
    } else {
      self.startLocation = nil
    }
    
    if let locations = aDecoder.decodeObject(forKey: "locations") as? [CLLocation] {
      self.locations = locations
    }
    
    let distanceValue = aDecoder.decodeDouble(forKey: "distance")
    self.distance = Distance(distance: distanceValue, unit: .kiloMeter)
    self.duration = aDecoder.decodeInteger(forKey: "duration")
    let avgSpeedValue = aDecoder.decodeDouble(forKey: "avgSpeed")
    self.avgSpeed = AvgSpeed(speed: avgSpeedValue, unit: .kiloMeterPerHour)
    let maxSpeedValue = aDecoder.decodeDouble(forKey: "maxSpeed")
    self.maxSpeed = MaxSpeed(speed: maxSpeedValue, unit: .kiloMeterPerHour)
    
    if let startTimeValue = aDecoder.decodeObject(forKey: "startTime") as? Date {
      self.startTime = startTimeValue as NSDate
    } else {
      self.startTime = NSDate()
    }
    
    if let workOutNameStr = aDecoder.decodeObject(forKey: "workoutName") as? String {
      self.workoutName = workOutNameStr
    } else {
      self.workoutName = newWorkoutDefaultName
    }

  }
}
