//
//  WorkOutViewController.swift
//  Ciclyc
//
//  Created by Benjamin Völker on 16/09/2016.
//  Copyright © 2016 Benjamin Völker. All rights reserved.
//


// Import the need Frameworks
import UIKit
import CoreLocation
import HealthKit
import CoreData


class WorkOutViewController: UIViewController, CLLocationManagerDelegate {
  // Label for current speed and its unit
  @IBOutlet var speedLabel: UILabel!
  @IBOutlet var speedUnitLabel: UILabel!
  // Label for current distance
  @IBOutlet var distanceLabel: UILabel!
  @IBOutlet var distanceUnitLabel: UILabel!
  // Label for avg speed
  @IBOutlet var avgSpeedLabel: UILabel!
  @IBOutlet var avgSpeedUnitLabel: UILabel!
  @IBOutlet weak var avgSpeedInfoLabel: UILabel!
  // Label for current time/duration
  @IBOutlet var timeLabel: UILabel!
  @IBOutlet var timeUnitLabel: UILabel!
  // StackView containing buttons
  @IBOutlet weak var buttonStackView: UIStackView!
  
  // Show debug messages
  let debug = true
  
  // Standard titles for buttons
  let buttonTitleStart = "Start"
  let buttonTitleBack = "Back"
  let buttonTitleReset = "Reset"
  let buttonTitlePause = "Pause"
  let buttonTitleResume = "Resume"
  let unitDuration = "dur"
  let unitTime = "time"
  
  // If person is currently moving or not
  var running = false
  // If the time should be shown or the current duration
  var showTime = false
  // Time the speed was not updated
  var speedUpdated = 0
  
  // Location manager object
  var locationManager: CLLocationManager = CLLocationManager()
  // The start location
  var startLocation: CLLocation!
  
  // Variables holding the current speed/avgSpeed/distance and duration
  var speed = Speed(speed: 0, unit: .kiloMeterPerHour)
  var avgSpeed = Speed(speed: 0, unit: .kiloMeterPerHour)
  var distance = Distance(distance: 0, unit: .kiloMeter)
  var seconds = 0
  // The starttime of the exercise
  var startTime:NSDate = NSDate()
  // The seconds the user has paused
  var pause = 0
  // The start time of the pause
  var pauseTime:NSDate = NSDate()
  
  // Variable holding all location points
  lazy var locations = [CLLocation]()
  // Timers for speed update, timer update and clock update
  lazy var speedTimer = Timer()
  lazy var timer = Timer()
  lazy var clocktimer = Timer()
  
  /*
   * View did load is called if the view is loaded, do view init stuff here
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    // Add observer for color changes, will reinit the complete view
    NotificationCenter.default.addObserver(self, selector: #selector(loadStyle), name: Settings.NotificationColorChanged.name, object: nil)
    
    // Set the properties for the stack view showing the buttons
    buttonStackView.alignment = .fill
    buttonStackView.distribution = .fillEqually
    buttonStackView.axis = .horizontal
    buttonStackView.spacing = 10.0
    
    // reset current speed/avgSpeed, distance, time and startlocation
    speed.speed = 0.0
    speed.unit = .kiloMeterPerHour
    avgSpeed.speed = 0.0
    avgSpeed.unit = .kiloMeterPerHour
    distance.distance = 0.0
    distance.unit = .kiloMeter
    seconds = 0
    startLocation = nil
    
    // All Labels should be tapable to change the unit that is displayed
    speedLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeSpeedUnit)))
    speedLabel.isUserInteractionEnabled = true
    speedLabel.isMultipleTouchEnabled = true
    distanceLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeDistanceUnit)))
    distanceLabel.isUserInteractionEnabled = true
    distanceLabel.isMultipleTouchEnabled = true
    avgSpeedLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeAvgSpeedUnit)))
    avgSpeedLabel.isUserInteractionEnabled = true
    avgSpeedLabel.isMultipleTouchEnabled = true
    timeLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeTimeLabel)))
    timeLabel.isUserInteractionEnabled = true
    timeLabel.isMultipleTouchEnabled = true
    
    // All labels should have monospaced digit format
    timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeLabel.font.pointSize, weight: UIFontWeightLight)
    speedLabel.font = UIFont.monospacedDigitSystemFont(ofSize: speedLabel.font.pointSize, weight: UIFontWeightLight)
    distanceLabel.font = UIFont.monospacedDigitSystemFont(ofSize: distanceLabel.font.pointSize, weight: UIFontWeightLight)
    avgSpeedLabel.font = UIFont.monospacedDigitSystemFont(ofSize: avgSpeedLabel.font.pointSize, weight: UIFontWeightLight)
    
    // Start the location manager and set the desired accuracy and information level
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.delegate = self
    locationManager.distanceFilter = 10
    locationManager.requestAlwaysAuthorization()
    locationManager.startUpdatingLocation()
    locationManager.activityType = .fitness
    //locationManager.startUpdatingHeading()
    
    // Load total ui
    loadStyle()
    
    // Timer to see if speed was updated, else set to 0 (update every second)
    speedTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateSpeedLabel), userInfo: nil, repeats: true)
    // Timer to update the clock or duration (update every second)
    clocktimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimeLabel), userInfo: nil, repeats: true)
  }
  
  /*
   * Load style will load all view elements in the view with there corresponding color
   */
  func loadStyle() {
    // Set background color
    self.view.backgroundColor = Settings.sharedInstance.bgColor
    speedLabel.textColor = Settings.sharedInstance.appColor
    speedUnitLabel.textColor = Settings.sharedInstance.appColor
    updateSpeedLabel()
    avgSpeedLabel.textColor = Settings.sharedInstance.appColor
    avgSpeedUnitLabel.textColor = Settings.sharedInstance.appColor
    avgSpeedInfoLabel.textColor = Settings.sharedInstance.appColor
    updateAvgSpeedLabel()
    distanceLabel.textColor = Settings.sharedInstance.appColor
    distanceUnitLabel.textColor = Settings.sharedInstance.appColor
    updateDistanceLabel()
    timeLabel.textColor = Settings.sharedInstance.appColor
    timeUnitLabel.textColor = Settings.sharedInstance.appColor
    updateTimeLabel()
    
    // Make a start button at the bottom
    makeStartButtonStackView()
  }
  
  /*
   * Change the speed unit from km/h to m/s to min/km
   */
  func changeSpeedUnit(sender: UITapGestureRecognizer? = nil) {
    if (debug) { print("change Speed unit") }
    // Switch between units here
    switch speed.unit {
    case .kiloMeterPerHour:
      speed.unit = .meterPerSecond
    case .meterPerSecond:
      speed.unit = .timePerKiloMeter
    case .timePerKiloMeter:
      speed.unit = .kiloMeterPerHour
    }
    updateSpeedLabel()
    speedUnitLabel.text = "\(speed.unitToString())"
  }
  
  /*
   * Change the distance unit from km to m
   */
  func changeDistanceUnit(sender: UITapGestureRecognizer? = nil) {
    if (debug) { print("change distance unit") }
    // Switch between units here
    switch distance.unit {
    case .kiloMeter:
      distance.unit = .meter
    case .meter:
      distance.unit = .kiloMeter
    }
    updateDistanceLabel()
    distanceUnitLabel.text = "\(distance.unitToString())"
  }
  
  /*
   * Change the distance unit from km/h to m/s to min/km
   */
  func changeAvgSpeedUnit(sender: UITapGestureRecognizer? = nil) {
    if (debug) { print("change avg speed unit") }
    // Switch between units here
    switch avgSpeed.unit {
    case .kiloMeterPerHour:
      avgSpeed.unit = .meterPerSecond
    case .meterPerSecond:
      avgSpeed.unit = .timePerKiloMeter
    case .timePerKiloMeter:
      avgSpeed.unit = .kiloMeterPerHour
    }
    updateAvgSpeedLabel()
    avgSpeedUnitLabel.text = "\(avgSpeed.unitToString())"
  }
  
  /*
   * Change the time from duration to current time of day
   */
  func changeTimeLabel(sender: UITapGestureRecognizer? = nil) {
    // handling code
    if (debug) { print("change time label") }
    showTime = !showTime
    updateTimeLabel()
    // Variable holding the unit
    var unitStr = unitDuration
    // If time of day should be shown show different label and time
    if (showTime) { unitStr = unitTime }
    timeUnitLabel.text = "\(unitStr)"
  }
  
  /*
   * If this view disappears, invalidate all timers
   */
  override func viewWillDisappear(_ animated: Bool) {
    if (debug) { print("View disappears, stop timer") }
    timer.invalidate()
    speedTimer.invalidate()
    clocktimer.invalidate()
    super.viewWillDisappear(animated)
  }
  
  
  /*
   * If we received a memory warning
   */
  override func didReceiveMemoryWarning() {
    if (debug) { print("Memory warning") }
    super.didReceiveMemoryWarning()
  }
  
  
  /*
   * If the user presses the pause button
   */
  @IBAction func pausePressed(_ sender: AnyObject) {
    // If the current title of the pause button is pause,
    // change it to resume and stop the timer
    if (sender.currentTitle == buttonTitlePause) {
      if (debug) { print("pausePressed") }
      // Set title to resume
      sender.setTitle(buttonTitleResume, for: .normal)
      // Change running state
      running = false
      // We do not need to update labels other than the speed label anymore
      timer.invalidate()
      // Set start date of the current pause periode
      pauseTime = NSDate()
    // If resume is pressed
    } else {
      if (debug) { print("resumePressed") }
      // Set title back to pause
      sender.setTitle(buttonTitlePause, for: .normal)
      // Change running state
      running = true
      // Start the timer to update all labels
      timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateLabels), userInfo: nil, repeats: true)
      // Calculate seconds from start of pause and add it to pause variable which is subtracted from duration
      let rsSeconds = raisedSeconds(from: pauseTime as Date, to: NSDate() as Date)
      pause = pause + rsSeconds
      if (debug) { print("Seconds paused: \(rsSeconds)ms") }
    }
  }
  
  /*
   * Returns the amount of seconds from another date
   */
  func raisedSeconds(from date1: Date, to date2: Date) -> Int {
    return Calendar.current.dateComponents([.second], from: date1, to: date2).second ?? 0
  }
  
  /*
   * If the user presses the reset button, everything is resetted
   */
  @IBAction func resetPressed(_ sender: AnyObject) {
    if (debug) { print("resetPressed") }
    // Set all variables to 0
    distance.distance = 0.0
    seconds = 0
    pause = 0
    distance.distance = 0.0
    avgSpeed.speed = 0.0
    // Reset start date
    startTime = NSDate()
    // Delete all previously visited locations
    locations.removeAll(keepingCapacity: false)
    // Show the start and back button once again
    makeStartButtonStackView()
    // Update all labels again to show 0 values
    updateLabels()
    // Afterwards invalidate timer and set running to false
    // If this was done before, the labels would not be updated anymore
    timer.invalidate()
    running = false
  }
  
  /*
   * If the user presses the start button
   */
  @IBAction func startPressed(_ sender: AnyObject) {
    if (debug) { print("startPressed") }
    // Reset start location, so that next location update is set as start location
    running = true
    startLocation = nil
    // Show the reset and pause button
    makePauseResetButtonStackView()
    // Start the timer to update labels
    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateLabels), userInfo: nil, repeats: true)
    // Set start time
    startTime = NSDate()
  }
  
  /*
   * If the user presses the back button, go back in the view hierarchie
   */
  @IBAction func backPressed(_ sender: AnyObject) {
    if (debug) { print("backPressed") }
    self.dismiss(animated: true, completion: nil)
  }
  
  
  /*
   * Clears the stackview and adds a pause and reset button
   */
  func makePauseResetButtonStackView() {
    // Remove previous views
    for aView in buttonStackView.arrangedSubviews {
      buttonStackView.removeArrangedSubview(aView)
      aView.removeFromSuperview()
    }
    // Add the reset button at the left
    buttonStackView.addArrangedSubview(Design().makeButton(text: buttonTitleReset, action: #selector(resetPressed)))
    // And the pause button on the right
    buttonStackView.addArrangedSubview(Design().makeButton(text: buttonTitlePause, action: #selector(pausePressed)))
  }
  
  /*
   * Clears the stackview and adds a start and back button
   */
  func makeStartButtonStackView() {
    // Remove previous views
    for aView in buttonStackView.arrangedSubviews {
      buttonStackView.removeArrangedSubview(aView)
      aView.removeFromSuperview()
    }
    // Add the back button on the left
    buttonStackView.addArrangedSubview(Design().makeButton(text: buttonTitleBack, action: #selector(backPressed)))
    // And the start button on the right
    buttonStackView.addArrangedSubview(Design().makeButton(text: buttonTitleStart, action: #selector(startPressed)))
  }
  
  /*
   * Function called every second from timer to update all labels
   */
  func updateLabels() {
    updateDistanceLabel()
    updateAvgSpeedLabel()
  }
  
  /*
   * Function called every second to update either the duration or the current time of day
   */
  func updateTimeLabel() {
    // Variable holding time information
    var timeStr = ""
    // If time of day should be shown
    if (showTime) {
      // Get current time in format /h/min/sec
      let components = NSCalendar.current.dateComponents([.hour, .minute, .second], from: NSDate() as Date)
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
    // If the current duration should be shown
    } else {
      // If not running, the seconds variable holds the duration
      var timePassed = self.seconds
      // If running, get the time passed from the start time of the activity
      // With the amount of pause time subtracted
      if (running) {
        timePassed = raisedSeconds(from: startTime as Date, to: NSDate() as Date) - pause
      }
      // Update duration
      self.seconds = timePassed;
      // Calculate seconds minutes and hours passed
      let seconds: Int = timePassed % 60
      let minutes: Int = (timePassed / 60) % 60
      let hours: Int = timePassed / 3600
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
    }
    if (debug) { print("Updated duration label: \(seconds) \(timeUnitLabel.text)") }
    // Update labels
    timeLabel.text = "\(timeStr)"
  }
  
  /*
   * Function called every second to update speed
   */
  func updateSpeedLabel() {
    // If the speed has not updated for 5 seconds and was not set to 0 before
    if speedUpdated > 5 && speed.speed != 0 {
      if (debug) { print("Speed did not update") }
      // Set it to zero
      speed.speed = 0.0
    // Else, count speed not updated timer (is resetted in location update)
    } else {
      speedUpdated = speedUpdated + 1
    }
    if (debug) { print("Updated the speed label: \(speed.getValue()) \(speed.unitToString())") }
    // Show speed and unit
    speedLabel.text = String(format: "%.2f", speed.getValue())
  }
  
  /*
   * Function called every second to update avg speed
   * The average speed is recalculated here every second
   */
  func updateAvgSpeedLabel() {
    // Calculate new average speed value from distance and duration
    if (seconds < 1) { avgSpeed.speed = 0.0 } else { avgSpeed.speed = distance.distance/Double(seconds) }
    if (debug) { print("Updated the speed label: \(avgSpeed.getValue()) \(avgSpeed.unitToString())") }
    avgSpeedLabel.text = String(format: "%.2f", avgSpeed.getValue())
  }
  
  /*
   * Function called every second to update the distance traveled
   */
  func updateDistanceLabel() {
    if (debug) { print("Updated the distance label: \(distance.getValue()) \(distance.unitToString())") }
    distanceLabel.text = String(format: "%.2f", distance.getValue())
  }
  
  
  /*
   func saveRun() {
   // 1
   let savedRun = NSEntityDescription.insertNewObjectForEntityForName("Run", inManagedObjectContext: managedObjectContext!) as! Run
   savedRun.distance = distance
   savedRun.duration = seconds
   savedRun.timestamp = NSDate()
   
   // 2
   var savedLocations = [Location]()
   for location in locations {
   let savedLocation = NSEntityDescription.insertNewObjectForEntityForName("Location",
   inManagedObjectContext: managedObjectContext!) as! Location
   savedLocation.timestamp = location.timestamp
   savedLocation.latitude = location.coordinate.latitude
   savedLocation.longitude = location.coordinate.longitude
   savedLocations.append(savedLocation)
   }
   
   savedRun.locations = NSOrderedSet(array: savedLocations)
   run = savedRun
   
   // 3
   var error: NSError?
   let success = managedObjectContext!.save(&error)
   if !success {
   println("Could not save the run!")
   }
   }*/
  
  
  // MARK: Location manager delegate
  /*
   * Location manager delegate function
   */
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    // For all new locations
    for location in locations {
      // If accuracy is good enough
      if location.horizontalAccuracy < 20 {
        // Update traveled distance if running
        if self.locations.count > 0 && running {
          distance.distance += location.distance(from: self.locations.last!)
        }
        
        // Add location new location if running
        if (running) {
          self.locations.append(location)
        }
        
        // Get current speed and check for reasonability
        let thespeed = location.speed
        if debug { print(String(format: "%.0f km/h", thespeed * 3.6)) }
        // If speed is too high (over 360km/h) or smaller 0 set it to 0
        if thespeed >= 0.0 && thespeed <= 100.0 {
          speed.speed = double_t(thespeed)
        } else {
          speed.speed = 0.0
        }
        // Speed not updated counter is resetted
        speedUpdated = 0
      }
    }
  }
}

