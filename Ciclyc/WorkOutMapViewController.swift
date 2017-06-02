//
//  WorkOutMapViewController.swift
//  Ciclyc
//
//  Created by Benjamin Völker on 22/09/2016.
//  Copyright © 2016 Benjamin Völker. All rights reserved.
//

import UIKit
import MapKit
import HealthKit

class WorkOutMapViewController: UIViewController, MKMapViewDelegate, WorkOutMapDelegate {
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var valueLabel: UILabel!
  @IBOutlet weak var infoLabel: UILabel!
  @IBOutlet weak var unitLabel: UILabel!
  
  var lastLocation:(CLLocation)! = nil
  
  var workout:(WorkOut)! = nil
  
  var timer = Timer()
  
  enum LabelToShow {
    case speedLabel, avgSpeedLabel, distanceLabel, durationLabel, timeLabel
  }
  
  var labelToShow :(LabelToShow) = .speedLabel
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Add observer for color changes, will reinit the complete view
    NotificationCenter.default.addObserver(self, selector: #selector(loadStyle), name: Settings.NotificationColorChanged.name, object: nil)

    // Do any additional setup after loading the view. 
    valueLabel.font = UIFont.monospacedDigitSystemFont(ofSize: valueLabel.font.pointSize, weight: UIFontWeightLight)
    
    
    // All Labels should be tapable to change the unit that is displayed
    valueLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeValue)))
    valueLabel.isUserInteractionEnabled = true
    valueLabel.isMultipleTouchEnabled = true
    valueLabel.text = "0.00"
    unitLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeUnit)))
    unitLabel.isUserInteractionEnabled = true
    unitLabel.isMultipleTouchEnabled = true
    infoLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeUnit)))
    infoLabel.isUserInteractionEnabled = true
    infoLabel.isMultipleTouchEnabled = true
    
    // Timer to update the clock or duration (update every second)
    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateLabels), userInfo: nil, repeats: true)
    
    // Set this as the delegate class for the mapview
    mapView.delegate = self
    mapView.showsUserLocation = true
    mapView.showsScale = true
    mapView.showsCompass = true
    mapView.showsBuildings = true
    
    
    // Load total ui
    loadStyle()
  }
  
  /*
   * Load style will load all view elements in the view with there corresponding color
   */
  func loadStyle() {
    // Set background color
    self.view.backgroundColor = Settings.sharedInstance.bgColor
    valueLabel.textColor = Settings.sharedInstance.appColor
    infoLabel.textColor = Settings.sharedInstance.appColor
    unitLabel.textColor = Settings.sharedInstance.appColor
    
    if self.workout != nil {
      showValue()
      showUnit()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  /*
   * Public function to let window controller load the workout for us
   * is not an init function, since the workout can be resetted.
   */
  func setWorkout(workout: WorkOut) {
    self.workout = workout
    self.workout?.mapDelegate = self
  }

  
  /*
   * Called each second from timer to update the currently displayed value
   */
  func updateLabels() {
    showValue()
  }
  
  
  /*
   * If a value shoudl be changed.
   */
  func changeValue() {
    switch labelToShow {
    case .speedLabel:
      labelToShow = .avgSpeedLabel
    case .avgSpeedLabel:
      labelToShow = .distanceLabel
    case .distanceLabel:
      labelToShow = .durationLabel
      unitLabel.text = "\(Time().unitDuration)"
      // No info is shown for time
      infoLabel.text = ""
    case .durationLabel:
      labelToShow = .timeLabel
    case .timeLabel:
      labelToShow = .speedLabel
    }
    // In nearly all cases, the value and unit must be reshown
    showValue()
    showUnit()
  }
  
  /*
   * If a unit should be changed
   */
  func changeUnit() {
    switch labelToShow {
    case .speedLabel:
      self.workout?.speed.switchUnit()
    case .avgSpeedLabel:
      self.workout?.avgSpeed.switchUnit()
    case .distanceLabel:
      self.workout?.distance.switchUnit()
    default: break
    }
    // In nearly all cases, the value and unit must be reshown
    showValue()
    showUnit()
  }
  
  /*
   * Shows the unit and info
   */
  func showUnit() {
    switch labelToShow {
    case .speedLabel:
      unitLabel.text = "\((self.workout?.speed.unitToString())!)"
      infoLabel.text = "\((self.workout?.speed.getDescription())!)"
    case .avgSpeedLabel:
      unitLabel.text = "\((self.workout?.avgSpeed.unitToString())!)"
      infoLabel.text = "\((self.workout?.avgSpeed.getDescription())!)"
    case .durationLabel:
      labelToShow = .durationLabel
      unitLabel.text = "\(Time().unitDuration)"
      infoLabel.text = ""
    case .timeLabel:
      unitLabel.text = "\(Time().unitTime)"
      infoLabel.text = ""
    case .distanceLabel:
      unitLabel.text = "\((self.workout?.distance.unitToString())!)"
      infoLabel.text = "\((self.workout?.distance.getDescription())!)"
    }
  }
  
  /*
   * Shows the value
   */
  func showValue() {
    switch labelToShow {
    case .speedLabel:
      valueLabel.text = self.workout?.speed.getValueAsString()
    case .avgSpeedLabel:
      valueLabel.text = self.workout?.avgSpeed.getValueAsString()
    case .distanceLabel:
      valueLabel.text = String(format: "%.2f", (self.workout?.distance.getValue())!)
    case .durationLabel:
      valueLabel.text = Time().getStr(duration: (self.workout?.duration)!)
    case .timeLabel:
      valueLabel.text = Time().getStr(time: NSDate())
    }
  }
  
  /*
   * Removes all overlays from the map and shows user location if possible
   */
  func resetMap() {
    if lastLocation != nil {
      let region = MKCoordinateRegionMakeWithDistance(lastLocation.coordinate, 300, 300)
      mapView.setRegion(region, animated: true)
    }
    mapView.removeOverlays(mapView.overlays)
    self.lastLocation = nil
  }
  
  /*
   * Redraw all visited location. For some reason this works better than just adding the new location
   */
  func locationUpdated(location: CLLocation, running: Bool) {
    if self.lastLocation == nil {
      self.lastLocation = location
    }
    print("new location update")
    
    // Set new region
    let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 300, 300)
    mapView.setRegion(region, animated: true)
    
    // If we move, everything is redrawn
    if (running) {
      // Remove all previous overlays
      self.mapView.removeOverlays(mapView.overlays)
      // Add all new
      self.lastLocation = workout.startLocation
      for location in workout.locations {
        var coords = [CLLocationCoordinate2D]()
        coords.append(self.lastLocation.coordinate)
        coords.append(location.coordinate)
        mapView.add(MKPolyline(coordinates: &coords, count: coords.count))
        self.lastLocation = location
      }
    }
  }
  
  
  // MARK: delegate function of mapview
  /*
   * Determines the color and line thickness of the polylines shown
   */
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if !overlay.isKind(of: MKPolyline.self) {
      return MKOverlayRenderer()
    }
    
    let polyline = overlay as! MKPolyline
    let renderer = MKPolylineRenderer(polyline: polyline)
    renderer.strokeColor = Settings.sharedInstance.appColor
    renderer.lineWidth = 10
    return renderer
  }
 }

