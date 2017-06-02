//
//  SettingsViewController.swift
//  Ciclyc
//
//  Created by Benjamin Völker on 16/09/2016.
//  Copyright © 2016 Benjamin Völker. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, SelectColorViewControllerDelegate {
  
  
  // All ui elements as variables
  @IBOutlet weak var changeColorView: UIView!
  @IBOutlet weak var changeColorViewColor: UIView!
  @IBOutlet weak var changeColorLabel: UILabel!
  @IBOutlet weak var changeBGColorLabel: UILabel!
  @IBOutlet weak var changeBGColorView: UIView!
  @IBOutlet weak var changeBGColorViewColor: UIView!
  @IBOutlet weak var showSpeedLabel: UILabel!
  @IBOutlet weak var showSpeedSwitch: UISwitch!
  @IBOutlet weak var showAvgSpeedLabel: UILabel!
  @IBOutlet weak var showAvgSpeedSwitch: UISwitch!
  @IBOutlet weak var showDistanceLabel: UILabel!
  @IBOutlet weak var showDistanceSwitch: UISwitch!
  @IBOutlet weak var showDurationLabel: UILabel!
  @IBOutlet weak var showDurationSwitch: UISwitch!
  @IBOutlet weak var showMapLabel: UILabel!
  @IBOutlet weak var showMapSwitch: UISwitch!
  @IBOutlet weak var changeProfileButton: UIButton!
  @IBOutlet weak var profileLabel: UILabel!
  
  // StackView containing back button
  @IBOutlet weak var buttonStackView: UIStackView!
  
  // Color type will determine which color is changed currently 
  // See settings.swift for reference
  var colorType:Settings.ColorType = .applicationColor
  
  /*
   * View did load is calles if the view is loaded, do view init stuff here
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Color wells should have a corner radius and a 1px black border
    changeColorView.layer.cornerRadius = 4
    changeColorView.layer.masksToBounds = true
    changeColorView.layer.borderWidth = 1
    changeColorView.layer.borderColor = UIColor.black.cgColor
    changeColorViewColor.layer.cornerRadius = 4
    changeColorViewColor.layer.masksToBounds = true
    changeBGColorView.layer.cornerRadius = 4
    changeBGColorView.layer.masksToBounds = true
    changeBGColorView.layer.borderWidth = 1
    changeBGColorView.layer.borderColor = UIColor.black.cgColor
    changeBGColorViewColor.layer.cornerRadius = 4
    changeBGColorViewColor.layer.masksToBounds = true
    
    showSpeedSwitch.setOn(Settings.sharedInstance.showSpeed, animated: false)
    showAvgSpeedSwitch.setOn(Settings.sharedInstance.showAvgSpeed, animated: false)
    showDurationSwitch.setOn(Settings.sharedInstance.showDuration, animated: false)
    showDistanceSwitch.setOn(Settings.sharedInstance.showDistance, animated: false)
    showMapSwitch.setOn(Settings.sharedInstance.showMap, animated: false)
    

    
    // Set the properties for the stack view
    buttonStackView.alignment = .fill
    buttonStackView.distribution = .fillEqually
    buttonStackView.axis = .horizontal
    buttonStackView.spacing = 10.0
    
    // Labels should be tapable
    let tap = UITapGestureRecognizer(target: self, action:  #selector(showAppColorPicker))
    changeColorView.addGestureRecognizer(tap)
    changeColorView.isUserInteractionEnabled = true
    changeColorView.isMultipleTouchEnabled = true
    let tap2 = UITapGestureRecognizer(target: self, action:  #selector(showAppBGColorPicker))
    changeBGColorView.addGestureRecognizer(tap2)
    changeBGColorView.isUserInteractionEnabled = true
    changeBGColorView.isMultipleTouchEnabled = true
    let tap3 = UITapGestureRecognizer(target: self, action:  #selector(changeProfile))
    profileLabel.addGestureRecognizer(tap3)
    profileLabel.isUserInteractionEnabled = true
    profileLabel.isMultipleTouchEnabled = true

    // Add observer for color changes, will reinit the complete view
    NotificationCenter.default.addObserver(self, selector: #selector(loadStyle), name: Settings.NotificationColorChanged.name, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(loadProfile), name: Settings.NotificationPofileChanged.name, object: nil)
    
    // Load the profile
    loadProfile()
    
    // Load total ui
    loadStyle()
  }
  
  /*
   * Load style will load all view elements in the view with there corresponding color
   */
  func loadStyle() {
    // Set Background color of total view
    self.view.backgroundColor = Settings.sharedInstance.bgColor
    // Show the back Button at the bottom
    makeBackButtonStackView()
    let color = Settings.sharedInstance.appColor
    // Set the color of the labels and color wells accordingly
    changeColorViewColor.backgroundColor = color
    changeBGColorViewColor.backgroundColor = Settings.sharedInstance.bgColor
    // Set color of labels accordingly
    changeColorLabel.textColor = color
    changeBGColorLabel.textColor = color
    showSpeedLabel.textColor = color
    showAvgSpeedLabel.textColor = color
    showDurationLabel.textColor = color
    showDistanceLabel.textColor = color
    showMapLabel.textColor = color
    profileLabel.textColor = color
    changeProfileButton.setTitleColor(color, for: .normal)
    
    // Set switch colors
    showSpeedSwitch.onTintColor = color
    showAvgSpeedSwitch.onTintColor = color
    showDurationSwitch.onTintColor = color
    showDistanceSwitch.onTintColor = color
    showMapSwitch.onTintColor = color
  }
  
  /*
   * Will load the profile label
   */
  func loadProfile() {
    // Set values for PROFILE
    if Settings.sharedInstance.userName != nil {
      profileLabel.text = "\(Settings.sharedInstance.userName!), \(Settings.sharedInstance.size)cm, \(Settings.sharedInstance.weight)kg"
    }
  }
  
  /*
   * If the application receives memory warning
   */
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  /*
   * Shows the color picker to change the application color
   */
  @IBAction func showAppColorPicker(sender:UITapGestureRecognizer)
  {
    // Set member accordingly to save the correct color at the end
    colorType = .applicationColor
    self.performSegue(withIdentifier: "colorPickerSegue", sender: self)
  }
  
  /*
   * Shows the color picker to change the background color
   */
  @IBAction func showAppBGColorPicker(sender:UITapGestureRecognizer)
  {
    // Set member accordingly to save the correct color at the end
    colorType = .backgroundColor
    self.performSegue(withIdentifier: "colorPickerSegue", sender: self)
  }
  
  /*
   * Shows the color picker to change the background color
   */
  @IBAction func changeProfile(sender:UITapGestureRecognizer)
  {
    self.performSegue(withIdentifier: "reinitUserNameSegue", sender: self)
    print("want to change profile")
  }
  
  
  /*
   * Get the color picker viewcontroller to set this class as its delegate
   */
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "colorPickerSegue" {
      let colorPickerVC = segue.destination as! SelectColorViewController
      colorPickerVC.delegate = self
    }
  }
  
  /*
   * Make a Back button at the bottom of the view
   */
  func makeBackButtonStackView() {
    // Remove previous views
    for aView in buttonStackView.arrangedSubviews {
      buttonStackView.removeArrangedSubview(aView)
      aView.removeFromSuperview()
    }
    // Add back button to view
    buttonStackView.addArrangedSubview(Design().makeButton(text: Design().buttonTitleBack, action: #selector(backPressed)))
  }
  
  
  /*
   * If the user presses back, we go one step back in the view hierarchie
   */
  @IBAction func backPressed(_ sender: AnyObject) {
    print("backPressed")
    self.dismiss(animated: true, completion: nil)
  }
  /*
   * If the user presses the individual show object switches
   * set value accordingly and save the settings
   */
  @IBAction func showSpeedValueChanged (sender: UISwitch) {
    Settings.sharedInstance.showSpeed = sender.isOn
    Settings.sharedInstance.store()
  }
  @IBAction func showAvgSpeedValueChanged (sender: UISwitch) {
    Settings.sharedInstance.showAvgSpeed = sender.isOn
    Settings.sharedInstance.store()
  }
  @IBAction func showDistanceValueChanged (sender: UISwitch) {
    Settings.sharedInstance.showDistance = sender.isOn
    Settings.sharedInstance.store()
  }
  @IBAction func showDurationValueChanged (sender: UISwitch) {
    Settings.sharedInstance.showDuration = sender.isOn
    Settings.sharedInstance.store()
  }
  @IBAction func showMapValueChanged (sender: UISwitch) {
    Settings.sharedInstance.showMap = sender.isOn
    Settings.sharedInstance.store()
  }
  
  //MARK: Delegate methods for the selectColorViewController
  
  /*
   * Return the current color which should be changed
   */
  func getColorType() -> Settings.ColorType {
    return colorType
  }
  
  /*
   * view returns the selected color, our task is to store the correct color
   */
  func colorSelected(color: UIColor) {
    switch colorType {
    case .backgroundColor:
      Settings.sharedInstance.bgColor = color
    case .applicationColor:
      Settings.sharedInstance.appColor = color
    }
    Settings.sharedInstance.store()
    NotificationCenter.default.post(Settings.NotificationColorChanged as Notification)
  }
  
}
