//
//  ViewController.swift
//  Ciclyc
//
//  Created by Benjamin Völker on 14/09/2016.
//  Copyright © 2016 Benjamin Völker. All rights reserved.
//


// Import the need Frameworks
import UIKit
import CloudKit

class ViewController: UIViewController {
  
  
  // Stack view containing the buttons
  @IBOutlet weak var buttonStackView: UIStackView!
  
  /*
   * View did load is calles if the view is loaded, do view init stuff here
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    //only apply the blur if the user hasn't disabled transparency effects
    if !UIAccessibilityIsReduceTransparencyEnabled() {
      self.view.backgroundColor = UIColor.clear
      
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
    
    // Set the properties for the stack view
    buttonStackView.alignment = .fill
    buttonStackView.distribution = .fillEqually
    buttonStackView.axis = .vertical
    buttonStackView.spacing = 40.0
    
    // Load past workouts
    _ = WorkOutDataBase.sharedInstance
    
    // Load total ui
    loadStyle()
    
    if Settings.sharedInstance.userName == nil {
      getUserName()
    }
  }
  
  /*
   * Load style will load all view elements in the view with there corresponding color
   */
  func loadStyle() {
    // Set color of background
    self.view.backgroundColor = Settings.sharedInstance.bgColor
    // Remove all previous views from the stackview (the buttons)
    for aView in buttonStackView.arrangedSubviews {
      buttonStackView.removeArrangedSubview(aView)
      aView.removeFromSuperview()
    }
    // Add the button for starting an activity
    buttonStackView.addArrangedSubview(Design().makeButton(text: Design().buttonTitleStartWork, action: #selector(startPressed)))
    // Add the button for browsing all activities
    buttonStackView.addArrangedSubview(Design().makeButton(text: Design().buttonTitleBrowseWork, action: #selector(browsePressed)))
    // Add the button for changing settings
    buttonStackView.addArrangedSubview(Design().makeButton(text: Design().buttonTitleSettings, action: #selector(settingsPressed)))
  }
  
  func getUserName() {
    print("Fetch username first")
    
    DispatchQueue.main.async {
      self.performSegue(withIdentifier: "userNameSegue", sender: self)
    }
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
   * If the user wants to start an activity
   */
  func startPressed() {
    DispatchQueue.main.async {
      self.performSegue(withIdentifier: "workoutPageSegue", sender: self)
    }
  }
  
  /*
   * If the user wants to browse all activities
   */
  func browsePressed() {
    DispatchQueue.main.async {
      self.performSegue(withIdentifier: "browseWorkOutSegue", sender: self)
    }
  }
  
  /*
   * If the user wants to change the settings
   */
  func settingsPressed() {
    DispatchQueue.main.async {
      self.performSegue(withIdentifier: "settingsSegue", sender: self)
    }
  }
  
  
}

