//
//  ShowWorkOutViewController.swift
//  Ciclyc
//
//  Created by Benjamin Völker on 26/09/2016.
//  Copyright © 2016 Benjamin Völker. All rights reserved.
//

import UIKit
import MapKit

class ShowWorkOutViewController: UIViewController, MKMapViewDelegate {
  let debug = false
  
  @IBOutlet weak var backStackView: UIStackView!
  
  @IBOutlet weak var mapView: MKMapView!
  
  @IBOutlet weak var avgSpeedInfoLabel: UILabel!
  @IBOutlet weak var avgSpeedLabel: UILabel!
  @IBOutlet weak var maxSpeedInfoLabel: UILabel!
  @IBOutlet weak var maxSpeedLabel: UILabel!
  @IBOutlet weak var distanceInfoLabel: UILabel!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var durationInfoLabel: UILabel!
  @IBOutlet weak var durationLabel: UILabel!
  @IBOutlet weak var dateInfoLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  
  // This variable must be inited before view did load is called
  var workout:WorkOut!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    mapView.delegate = self
    mapView.isHidden = true;
    // Add observer for color changes, will reinit the complete view
    NotificationCenter.default.addObserver(self, selector: #selector(loadStyle), name: Settings.NotificationColorChanged.name, object: nil)
    
    maxSpeedLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeMaxSpeedUnit)))
    maxSpeedLabel.isUserInteractionEnabled = true
    maxSpeedLabel.isMultipleTouchEnabled = true
    distanceLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeDistanceUnit)))
    distanceLabel.isUserInteractionEnabled = true
    distanceLabel.isMultipleTouchEnabled = true
    avgSpeedLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeAvgSpeedUnit)))
    avgSpeedLabel.isUserInteractionEnabled = true
    avgSpeedLabel.isMultipleTouchEnabled = true
    
    loadStyle()
    showLabelData()
    
    // Do any additional setup after loading the view.
  }
  
  override func viewDidAppear(_ animated: Bool) {
    showMapData()
    mapView.isHidden = false;
  }
  
  /*
   * Change the speed unit from km/h to m/s to min/km
   */
  func changeMaxSpeedUnit(sender: UITapGestureRecognizer? = nil) {
    // Switch between units here
    workout.maxSpeed.switchUnit()
    self.maxSpeedLabel.text = "\(workout.maxSpeed.getValueAsString()) " + "\(workout.maxSpeed.unitToString())"
  }
  
  /*
   * Change the speed unit from km/h to m/s to min/km
   */
  func changeAvgSpeedUnit(sender: UITapGestureRecognizer? = nil) {
    // Switch between units here
    workout.avgSpeed.switchUnit()
    self.avgSpeedLabel.text = "\(workout.avgSpeed.getValueAsString()) " + "\(workout.avgSpeed.unitToString())"
  }
  
  /*
   * Change the speed unit from km/h to m/s to min/km
   */
  func changeDistanceUnit(sender: UITapGestureRecognizer? = nil) {
    // Switch between units here
    workout.distance.switchUnit()
    self.distanceLabel.text = String(format: "%.2f ", workout.distance.getValue()) + "\(workout.distance.unitToString())"
  }
  
  /*
   * Load style will load all view elements in the view with there corresponding color
   */
  func loadStyle() {
    // Set background color
    self.view.backgroundColor = Settings.sharedInstance.bgColor
    avgSpeedInfoLabel.textColor = Settings.sharedInstance.appColor
    avgSpeedLabel.textColor = Settings.sharedInstance.appColor
    maxSpeedInfoLabel.textColor = Settings.sharedInstance.appColor
    maxSpeedLabel.textColor = Settings.sharedInstance.appColor
    distanceInfoLabel.textColor = Settings.sharedInstance.appColor
    distanceLabel.textColor = Settings.sharedInstance.appColor
    durationInfoLabel.textColor = Settings.sharedInstance.appColor
    durationLabel.textColor = Settings.sharedInstance.appColor
    dateLabel.textColor = Settings.sharedInstance.appColor
    dateInfoLabel.textColor = Settings.sharedInstance.appColor
    
    makeBackButtonStackView()
  }
  
  /*
   * Load the data into the correxponding labels
   */
  func showLabelData(){
    self.avgSpeedLabel.text = String(format: "%.2f ", workout.avgSpeed.getValue()) + "\(workout.avgSpeed.unitToString())"
    self.maxSpeedLabel.text = String(format: "%.2f ", workout.maxSpeed.getValue()) + "\(workout.maxSpeed.unitToString())"
    self.distanceLabel.text = String(format: "%.2f ", workout.distance.getValue()) + "\(workout.distance.unitToString())"
    self.durationLabel.text = "\(Time().getStr(duration: workout.duration))"
    self.dateLabel.text = "\(Time().getStr(dateWithTime: workout.startTime))"
  }
  
  /*
   * Load the data into the correxponding labels
   */
  func showMapData(){
    if (self.workout.startLocation != nil){
      self.mapView.region = getMapRegion()
      self.mapView.setRegion(getMapRegion(), animated: false)
    }
    if (self.workout.locations.count > 1){
      let colorSegments = MulticolorPolylineSegment.colorSegments(forLocations: workout.locations)
      mapView.addOverlays(colorSegments)
    }
    mapView.showsScale = true
    mapView.showsCompass = true
    mapView.showsBuildings = true

  }
  
  
  /*
   * Make a Back button at the bottom of the view
   */
  func makeBackButtonStackView() {
    // Remove previous views
    for aView in backStackView.arrangedSubviews {
      backStackView.removeArrangedSubview(aView)
      aView.removeFromSuperview()
    }
    // Add back button to view
    backStackView.addArrangedSubview(Design().makeButton(text: Design().buttonTitleBack, action: #selector(backPressed)))
  }
  
  
  /*
   * If the user presses back, we go one step back in the view hierarchie
   */
  @IBAction func backPressed(_ sender: AnyObject) {
    if debug { print("backPressed") }
    self.dismiss(animated: true, completion: nil)
  }
  
  
  func getMapRegion() -> MKCoordinateRegion {
   
    let initialLoc = (self.workout?.startLocation)!
    var minLat = initialLoc.coordinate.latitude
    var minLng = initialLoc.coordinate.longitude
    var maxLat = minLat
    var maxLng = minLng
    
   
    for location in (self.workout?.locations)! {
      minLat = min(minLat, location.coordinate.latitude)
      minLng = min(minLng, location.coordinate.longitude)
      maxLat = max(maxLat, location.coordinate.latitude)
      maxLng = max(maxLng, location.coordinate.longitude)
    }
    if debug {
      print("MapRegion Center: \((minLat + maxLat)/2), \((minLng + maxLng)/2)")
      print("MapRegion Lat: min: \(minLat) max: \(maxLat)")
      print("MapRegion Long: min: \(minLng) max: \(maxLng)")
      print("MapRegion delta: lat: \(maxLat - minLat) long: \(maxLng - minLng)")
    }
    let d1 = CLLocation(latitude: minLat, longitude: minLng)
    let d2 = CLLocation(latitude: maxLat, longitude: maxLng)
    let distance = d1.distance(from: d2)
    if debug { print("Distance in m: \(distance)") }
    
    return MKCoordinateRegion(
      center: CLLocationCoordinate2D(latitude: (minLat + maxLat)/2,
                                     longitude: (minLng + maxLng)/2),
      span: MKCoordinateSpan(latitudeDelta: abs(maxLat - minLat)*1.2,
                             longitudeDelta: abs(maxLng - minLng)*1.2))
  }
  
  
  func polyline() -> MKPolyline {
    var coords = [CLLocationCoordinate2D]()
    
    let locations = (self.workout?.locations)! as [CLLocation]
    for location in locations {
      coords.append(location.coordinate)
    }
    
    return MKPolyline(coordinates: &coords, count: locations.count)
  }

  // MARK:
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if !overlay.isKind(of: MulticolorPolylineSegment.self) {
      return MKOverlayRenderer()
    }
    
    let polyline = overlay as! MulticolorPolylineSegment
    let renderer = MKPolylineRenderer(polyline: polyline)
    renderer.strokeColor = polyline.color
    renderer.lineWidth = 5
    return renderer
  }
}
