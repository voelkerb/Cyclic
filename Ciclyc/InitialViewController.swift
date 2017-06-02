//
//  InitialViewController.swift
//  Ciclyc
//
//  Created by Benjamin Völker on 18/10/2016.
//  Copyright © 2016 Benjamin Völker. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

  
  let debug = false
  
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var whoAmYoulabel: UILabel!
  @IBOutlet weak var textFieldUnderline: UIView!
  @IBOutlet weak var saveButton: UIButton!
  
  
  enum SettingsProgress {
    case progressName, progressGender, progressWeight, progressHeight
  }
  var progress : SettingsProgress = .progressName
  @IBOutlet weak var picker: UIPickerView!
  let pickerGenderData = ["male", "female"]
  var pickerWeightData = [String]()
  let startWeight = 35
  let endWeight = 140
  var pickerHeightData = [String]()
  let startHeight = 140
  let endHeight = 210
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    for i in startWeight..<endWeight {
      pickerWeightData.append("\(i)")
    }
    
    for i in startHeight..<endHeight {
      pickerHeightData.append("\(i)")
    }
    
    picker.dataSource = self
    picker.delegate = self
    
    picker.isHidden = true
    saveButton.isHidden = true
    
    //only apply the blur if the user hasn't disabled transparency effects
    if !UIAccessibilityIsReduceTransparencyEnabled() {
      //self.view.backgroundColor = UIColor.clear
      
      let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
      let blurEffectView = UIVisualEffectView(effect: blurEffect)
      //always fill the view
      blurEffectView.frame = self.view.bounds
      blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
      self.view.insertSubview(blurEffectView, at: 1)
    } else {
      self.view.backgroundColor = UIColor.black
    }
    // Add observer for color changes, will reinit the complete view
    NotificationCenter.default.addObserver(self, selector: #selector(loadStyle), name: Settings.NotificationColorChanged.name, object: nil)
      
      
    // Load total ui
    //loadStyle()
    textField.becomeFirstResponder()
    textField.delegate = self
  }
  
  /*
   * Load style will load all view elements in the view with there corresponding color
   */
  func loadStyle() {
    whoAmYoulabel.textColor = Settings.sharedInstance.appColor
    textField.textColor = Settings.sharedInstance.appColor
  }
  
  /*
   * If the view is disappearing
   */
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }
  
  /*
   * If the application receives memory warning
   */
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  /*
   * If save button is pressed move on
   */
  @IBAction func savePressed(_ sender: AnyObject) {
    progressGoesOn()
  }
  
  /*
   * If enter pressed on the keyboard
   */
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    // Hide keyboard
    self.view.endEditing(true)
    progressGoesOn()
    return false
  }
    
  
  
  func progressGoesOn() {
    // Fade to next string
    whoAmYoulabel.fadeTransition(duration: 0.8)
    // Determine what we are storing
    switch progress {
    // If we want to store the name
    case .progressName:
      // If text is present
      if let text = textField.text {
        // If name is valid, set it and move on
        if text.characters.count > 2 {
          Settings.sharedInstance.userName = text as (NSString)!
          if debug { print("Stored name: ", Settings.sharedInstance.userName) }
          
          // Move to gender question
          whoAmYoulabel.text = "What's your gender?"
          // Therefore, hide text field and underline
          textField.isHidden = true
          textFieldUnderline.isHidden = true
          // And show picker, next button
          picker.isHidden = false
          saveButton.isHidden = false
          // Move on to next
          progress = .progressGender
          // Reload picker
          picker.reloadAllComponents()
        }
      }
      break
    // If we want to store the gender
    case .progressGender:
      // Look if first or second element is selected, first is male
      if picker.selectedRow(inComponent: 0) == 0  {
        Settings.sharedInstance.female = false
      } else {
        Settings.sharedInstance.female = true
      }
      if debug { print("Stored Gender, is Female=", Settings.sharedInstance.female) }
      
      // Move to height question
      whoAmYoulabel.text = "What's your height?"
      progress = .progressHeight
      // Reload picker and select middle value
      picker.reloadAllComponents()
      picker.selectRow(pickerHeightData.count/2, inComponent: 0, animated: true)
      break
    // If we want to store the height
    case .progressHeight:
      // Look if selection is a valid integer value and store it
      if pickerHeightData.indices.contains(picker.selectedRow(inComponent: 0)) {
        let chosen = pickerHeightData[picker.selectedRow(inComponent: 0)]
        if let value = Int(chosen) {
          Settings.sharedInstance.size = value
          if debug { print("Stored Height: ", Settings.sharedInstance.size) }
        }
      }
      
      // Move to weight question
      whoAmYoulabel.text = "What's your weight?"
      
      progress = .progressWeight
      // Reload picker and select middle value
      picker.reloadAllComponents()
      picker.selectRow(pickerWeightData.count/2, inComponent: 0, animated: true)
      // Next step is finish, so show it on button
      saveButton.setTitle("Finish", for: .normal)
      break
    // If we want to store the weight
    case .progressWeight:
      // Look if selection is a valid integer value and store it
      if pickerWeightData.indices.contains(picker.selectedRow(inComponent: 0)) {
        let chosen = pickerWeightData[picker.selectedRow(inComponent: 0)]
        if let value = Int(chosen) {
          Settings.sharedInstance.weight = value
          if debug { print("Stored Weight: ", Settings.sharedInstance.weight) }
        }
      }
      
      // Show Finish Label, hide all other UI elements
      whoAmYoulabel.text = "Finished"
      textField.isHidden = true
      textFieldUnderline.isHidden = true
      picker.isHidden = true
      saveButton.isHidden = true
      Settings.sharedInstance.store()
      // Resolve view after two second
      DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        self.dismiss(animated: true, completion: nil)
      }
      NotificationCenter.default.post(Settings.NotificationPofileChanged as Notification)
      break
    }
  }

  
  //MARK: - Delegates and data sources
  //MARK: Data Sources
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    var comps = 0
    switch progress {
    case .progressGender:
      comps = pickerGenderData.count
      break
    case .progressWeight:
      comps = pickerWeightData.count
      break
    case .progressHeight:
      comps = pickerHeightData.count
      break
    default:
      break
    }
    return comps
  }
  
  //MARK: Delegates
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    var comp = ""
    switch progress {
    case .progressGender:
      comp = pickerGenderData[row]
      break
    case .progressWeight:
      comp = pickerWeightData[row]
      break
    case .progressHeight:
      comp = pickerHeightData[row]
      break
    default:
      break
    }
    return comp
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    var comp = ""
    switch progress {
    case .progressGender:
      comp = pickerGenderData[row]
      break
    case .progressWeight:
      comp = pickerWeightData[row]
      break
    case .progressHeight:
      comp = pickerHeightData[row]
      break
    default:
      break
    }
    if debug { print("Selected: ", comp) }
  }
  
  /*
   * Show the text in the picker view as white
   */
  func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
    var comp = ""
    switch progress {
    case .progressGender:
      comp = pickerGenderData[row]
      break
    case .progressWeight:
      comp = pickerWeightData[row]
      break
    case .progressHeight:
      comp = pickerHeightData[row]
      break
    default:
      break
    }
    let myTitle = NSAttributedString(string: comp, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 30.0),NSForegroundColorAttributeName:UIColor.white])
    return myTitle
  }
}


