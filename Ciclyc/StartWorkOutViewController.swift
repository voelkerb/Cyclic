//
//  StartWorkOutViewController.swift
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


class StartWorkOutViewController: UIViewController, CLLocationManagerDelegate, WorkOutDelegate {
  // Label for current speed and its unit
  @IBOutlet var speedLabel: UILabel!
  @IBOutlet var speedUnitLabel: UILabel!
  @IBOutlet var speedInfoLabel: UILabel!
  // Label for current distance
  @IBOutlet var distanceLabel: UILabel!
  @IBOutlet var distanceUnitLabel: UILabel!
  @IBOutlet var distanceInfoLabel: UILabel!
  // Label for avg speed
  @IBOutlet var avgSpeedLabel: UILabel!
  @IBOutlet var avgSpeedUnitLabel: UILabel!
  @IBOutlet var avgSpeedInfoLabel: UILabel!
  // Label for current time/duration
  @IBOutlet var timeLabel: UILabel!
  @IBOutlet var timeUnitLabel: UILabel!
  @IBOutlet weak var timeInfoLabel: UILabel!
  // StackView containing buttons
  @IBOutlet weak var buttonStackView: UIStackView!
  // Stackview containing all workout infos
  @IBOutlet weak var infoStackView: UIStackView!
  
  // Show debug messages
  let debug = true
  

  // If the time should be shown or the current duration
  var showTime = false
  
  // Timers for speed update, timer update and clock update
  lazy var clocktimer = Timer()
  
  // The workout variable
  var workout = WorkOut()
  
  /*
   * View did load is called if the view is loaded, do view init stuff here
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    // Add observer for color changes, will reinit the complete view
    NotificationCenter.default.addObserver(self, selector: #selector(loadStyle), name: Settings.NotificationColorChanged.name, object: nil)
    // Set self as the delegate of the workout
    workout.delegate = self
    // Set the properties for the stack view showing the buttons
    buttonStackView.alignment = .fill
    buttonStackView.distribution = .fillEqually
    buttonStackView.axis = .horizontal
    buttonStackView.spacing = 10.0
    // Set the properties for the stack view showing the workout info
    infoStackView.alignment = .fill
    infoStackView.distribution = .fillEqually
    infoStackView.axis = .vertical
    infoStackView.spacing = 10.0
    
    // Fon should be of monospace
    speedLabel.font = UIFont.monospacedDigitSystemFont(ofSize: speedLabel.font.pointSize, weight: UIFontWeightLight)
    distanceLabel.font = UIFont.monospacedDigitSystemFont(ofSize: distanceLabel.font.pointSize, weight: UIFontWeightLight)
    avgSpeedLabel.font = UIFont.monospacedDigitSystemFont(ofSize: avgSpeedLabel.font.pointSize, weight: UIFontWeightLight)
    timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeLabel.font.pointSize, weight: UIFontWeightLight)
    
    
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
    
    if !Settings.sharedInstance.showDuration { self.showTime = true }
    
    // Load total ui
    loadStyle()
    
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
    speedInfoLabel.textColor = Settings.sharedInstance.appColor
    speedUnitLabel.text = "\(workout.speed.unitToString())"
    avgSpeedLabel.textColor = Settings.sharedInstance.appColor
    avgSpeedUnitLabel.textColor = Settings.sharedInstance.appColor
    avgSpeedInfoLabel.textColor = Settings.sharedInstance.appColor
    avgSpeedUnitLabel.text = "\(workout.avgSpeed.unitToString())"
    distanceLabel.textColor = Settings.sharedInstance.appColor
    distanceUnitLabel.textColor = Settings.sharedInstance.appColor
    distanceInfoLabel.textColor = Settings.sharedInstance.appColor
    distanceUnitLabel.text = "\(workout.distance.unitToString())"
    timeLabel.textColor = Settings.sharedInstance.appColor
    timeUnitLabel.textColor = Settings.sharedInstance.appColor
    //timeInfoLabel.textColor = Settings.sharedInstance.appColor
    // Variable holding the unit
    var unitStr = Time().unitDuration
    // If time of day should be shown show different label and time
    if (showTime) { unitStr = Time().unitTime }
    timeUnitLabel.text = "\(unitStr)"
    
    
    // Make a start button at the bottom
    makeStartButtonStackView()
    showOrHideInformation()
    updateTimeLabel()
    
    distanceLabel.text = String(format: "%.2f", workout.distance.getValue())
    avgSpeedLabel.text = String(format: "%.2f", workout.avgSpeed.getValue())
    speedLabel.text = String(format: "%.2f", workout.speed.getValue())
  }
  
   
  /*
   * Change the speed unit from km/h to m/s to min/km
   */
  func changeSpeedUnit(sender: UITapGestureRecognizer? = nil) {
    if (debug) { print("change Speed unit") }
    // Switch between units here
    workout.speed.switchUnit()
    speedLabel.text = workout.speed.getValueAsString()
    speedUnitLabel.text = "\(workout.speed.unitToString())"
  }
  
  /*
   * Change the distance unit from km to m
   */
  func changeDistanceUnit(sender: UITapGestureRecognizer? = nil) {
    if (debug) { print("change distance unit") }
    // Switch between units here
    workout.distance.switchUnit()
    distanceLabel.text = String(format: "%.2f", workout.distance.getValue())
    distanceUnitLabel.text = "\(workout.distance.unitToString())"
  }
  
  /*
   * Change the distance unit from km/h to m/s to min/km
   */
  func changeAvgSpeedUnit(sender: UITapGestureRecognizer? = nil) {
    if (debug) { print("change avg speed unit") }
    // Switch between units here
    workout.avgSpeed.switchUnit()
    avgSpeedLabel.text = workout.avgSpeed.getValueAsString()
    avgSpeedUnitLabel.text = "\(workout.avgSpeed.unitToString())"
  }
  
  /*
   * Change the time from duration to current time of day
   */
  func changeTimeLabel(sender: UITapGestureRecognizer? = nil) {
    // handling code
    if (debug) { print("change time label") }
    // If user do not want to see the duration, simply show time
    if !Settings.sharedInstance.showDuration {
      self.showTime = true
    } else {
      showTime = !showTime
    }
    updateTimeLabel()
    // Variable holding the unit
    var unitStr = Time().unitDuration
    // If time of day should be shown show different label and time
    if (showTime) { unitStr = Time().unitTime }
    timeUnitLabel.text = "\(unitStr)"
  }
  
  /*
   * If this view disappears, invalidate all timers
   */
  override func viewWillDisappear(_ animated: Bool) {
    if (debug) { print("View disappears, stop timer") }
    //workout.stop()
    //clocktimer.invalidate()
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
    if (sender.currentTitle == Design().buttonTitlePause) {
      if (debug) { print("pausePressed") }
      // Set title to resume
      sender.setTitle(Design().buttonTitleResume, for: .normal)
      // Stop the workout
      self.workout.pause()
      // Show the pause button
      makeResumeResetSaveButtonStackView()
    }
  }
  
  /*
   * If the user presses the pause button
   */
  @IBAction func resumePressed(_ sender: AnyObject) {
    if (debug) { print("resumePressed") }
    // Stop the workout
    self.workout.resume()
    // Show the pause button
    makePauseButtonStackView()
  }
  
  /*
   * If the user presses the reset button, everything is resetted
   */
  @IBAction func resetPressed(_ sender: AnyObject) {
    if (debug) { print("resetPressed") }
    // Reset the workout
    workout.reset()
    // Show the start and back button once again
    makeStartButtonStackView()
    // Update all labels again to show 0 values
    distanceLabel.text = String(format: "%.2f", workout.distance.getValue())
    avgSpeedLabel.text = String(format: "%.2f", workout.avgSpeed.getValue())
    speedLabel.text = String(format: "%.2f", workout.speed.getValue())
    updateTimeLabel()
  }
  
  /*
   * If the user presses the start button
   */
  @IBAction func startPressed(_ sender: AnyObject) {
    if (debug) { print("startPressed") }
    workout.start()
    // Show the pause button
    makePauseButtonStackView()
  }
  
  /*
   * If the user presses the save button
   */
  @IBAction func savePressed(_ sender: AnyObject) {
    if (debug) { print("savePressed") }
    workout.stop()
    // Reset start location, so that next location update is set as start location
    if (workout.duration > 0) {
      WorkOutDataBase.sharedInstance.addWorkout(workout: self.workout)
      WorkOutDataBase.sharedInstance.saveWorkouts()
    }
    // Show the pause button
    makeStartButtonStackView()
    // Reset the workout
    workout = WorkOut()
    // Update all labels again to show 0 values
    distanceLabel.text = String(format: "%.2f", workout.distance.getValue())
    avgSpeedLabel.text = String(format: "%.2f", workout.avgSpeed.getValue())
    speedLabel.text = String(format: "%.2f", workout.speed.getValue())
    updateTimeLabel()
  }
  
  
  /*
   * If the user presses the back button, go back in the view hierarchie
   */
  @IBAction func backPressed(_ sender: AnyObject) {
    if (debug) { print("backPressed") }
    workout.stop()
    // Invalidate timer
    clocktimer.invalidate()
    // Remove self from notification center observer
    NotificationCenter.default.removeObserver(self)
    self.dismiss(animated: true, completion: nil)
  }
  
  
  /*
   * Clears the stackview and adds a pause and reset button
   */
  func makePauseButtonStackView() {
    // Remove previous views
    for aView in buttonStackView.arrangedSubviews {
      buttonStackView.removeArrangedSubview(aView)
      aView.removeFromSuperview()
    }
    // And the pause button on the right
    buttonStackView.addArrangedSubview(Design().makeButton(text: Design().buttonTitlePause, action: #selector(pausePressed)))
  }
  
  /*
   * Clears the stackview and adds a pause and reset button
   */
  func makeResumeResetSaveButtonStackView() {
    // Remove previous views
    for aView in buttonStackView.arrangedSubviews {
      buttonStackView.removeArrangedSubview(aView)
      aView.removeFromSuperview()
    }
    // Add the reset button at the left
    buttonStackView.addArrangedSubview(Design().makeButton(text: Design().buttonTitleReset, action: #selector(resetPressed)))
    // Add the reset button at the left
    buttonStackView.addArrangedSubview(Design().makeButton(text: Design().buttonTitleResume, action: #selector(resumePressed)))
    // And the pause button on the right
    buttonStackView.addArrangedSubview(Design().makeButton(text: Design().buttonTitleSave, action: #selector(savePressed)))
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
    buttonStackView.addArrangedSubview(Design().makeButton(text: Design().buttonTitleBack, action: #selector(backPressed)))
    // And the start button on the right
    buttonStackView.addArrangedSubview(Design().makeButton(text: Design().buttonTitleStart, action: #selector(startPressed)))
  }
  
  /*
   * Clears the stackview and adds a start and back button
   */
  func showOrHideInformation() {
    let set = Settings.sharedInstance
    //infoStackView.arrangedSubviews[0].isHidden = !set.showSpeed
    if !set.showSpeed { infoStackView.arrangedSubviews[0].removeFromSuperview() }
    if !set.showDistance { infoStackView.arrangedSubviews[1].removeFromSuperview() }
    //infoStackView.arrangedSubviews[1].isHidden = !set.showDistance
    if !set.showAvgSpeed { infoStackView.arrangedSubviews[2].removeFromSuperview() }
    //infoStackView.arrangedSubviews[2].isHidden = !set.showAvgSpeed
    //infoStackView.arrangedSubviews[3].isHidden = !set.showDuration
  }
  
  
  
  
  /*
   * Function called every second to update either the duration or the current time of day
   */
  func updateTimeLabel() {
    // Variable holding time information
    var timeStr = ""
    // If time of day should be shown
    if (showTime) {
      timeStr = Time().getStr(time: NSDate())
      // If the current duration should be shown
    } else {
      timeStr = Time().getStr(duration: workout.duration)
    }
    if (debug) { print("Updated duration label: \(workout.duration) \(timeUnitLabel.text)") }
    // Update labels
    timeLabel.text = "\(timeStr)"
  }
  
  
  // MARK: Workout delegate methods
  /*
   * Function called if a new speed reading is available
   */
  func speedUpdated(speed: Speed) {
    if (debug) { print("Updated the speed label: \(speed.getValue()) \(workout.speed.unitToString())") }
    // Show speed and unit
    speedLabel.text = speed.getValueAsString()
  }
  
  /*
   * Function called if a new avgspeed reading is available
   */
  func avgSpeedUpdated(avgSpeed: Speed) {
    if (debug) { print("Updated the avg speed label: \(avgSpeed.getValue()) \(workout.avgSpeed.unitToString())") }
    avgSpeedLabel.text = avgSpeed.getValueAsString()
  }
  
  /*
   * Function called if a new distance reading is available
   */
  func distanceUpdated(distance: Distance) {
    if (debug) { print("Updated the distance label: \(distance.getValue()) \(workout.distance.unitToString())") }
    distanceLabel.text = String(format: "%.2f", distance.getValue())
  }
    
}

