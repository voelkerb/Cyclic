//
//  ViewController.swift
//  SwiftHSVColorPicker
//
//

import Foundation
import UIKit

// Delegate for the SelectColorViewController
protocol SelectColorViewControllerDelegate: class {
  // Let others do sth with the selected color
  func colorSelected(color: UIColor)
  // Determine which color to change
  func getColorType() -> Settings.ColorType
}

class SelectColorViewController: UIViewController {
  
  // Delegate variable
  weak var delegate: SelectColorViewControllerDelegate?
  
  
  // Color picker variable
  var colorPicker:SwiftHSVColorPicker! = nil
  
  // StackView containing buttons
  @IBOutlet weak var buttonStackView: UIStackView!
  
  /*
   * View did load is called if the view is loaded, do view init stuff here
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set the properties for the stack view
    buttonStackView.alignment = .fill
    buttonStackView.distribution = .fillEqually
    buttonStackView.axis = .horizontal
    buttonStackView.spacing = 10.0
    
    // Setup Color Picker with side and top margin and centered in the view
    let sideMargin:CGFloat = 30.0
    let topMargin:CGFloat = 50.0
    let bottomMargin:CGFloat = 80.0
    let width = self.view.frame.size.width - 2*sideMargin
    let height = self.view.frame.size.height - topMargin - bottomMargin
    colorPicker = SwiftHSVColorPicker(frame: CGRect(x: sideMargin, y: topMargin, width: width, height: height))
    
    // Get the color type and set the current selected color accordingly
    let colorType:Settings.ColorType = (delegate?.getColorType())!
    var color = UIColor.white
    switch colorType {
    case .backgroundColor:
      color = Settings.sharedInstance.bgColor
    case .applicationColor:
      color = Settings.sharedInstance.appColor
    }
    colorPicker.setViewColor( color )
    
    // Add the color picker to the view
    self.view.addSubview(colorPicker)
    
    // Set background color accordingly
    self.view.backgroundColor = Settings.sharedInstance.bgColor
    
    // Show the save and cancel button
    makeSaveCancelButtonStackView()
  }
  
  /*
   * Make the save and cacel button at the bottom
   */
  func makeSaveCancelButtonStackView() {
    // Remove previous views
    for aView in buttonStackView.arrangedSubviews {
      buttonStackView.removeArrangedSubview(aView)
      aView.removeFromSuperview()
    }
    // Add cancel button
    buttonStackView.addArrangedSubview(Design().makeButton(text: Design().buttonTitleCancel, action: #selector(cancelPressed)))
    // Add save button
    buttonStackView.addArrangedSubview(Design().makeButton(text: Design().buttonTitleSave, action: #selector(savePressed)))
  }
  
  /*
   * If save is pressed, look if color is not like the background color, call delegate to save the value
   * and go back in the view hirarchie
   */
  @IBAction func savePressed(_ sender: AnyObject) {
    // Get the current color type from the delegate
    let colorType:Settings.ColorType = (delegate?.getColorType())!
    
    switch colorType {
    // If this color change should belong to the background color
    case .backgroundColor:
      // Calculate the distance to the application color
      let distance = colorPicker.color.CIE94(compare: Settings.sharedInstance.appColor)
      print("Distance to appColor is \(distance)")
      // If distance is too small, show error alert
      if distance < Settings.sharedInstance.distanceThreshold {
        let alertController = UIAlertController(title: "Color Error", message:
          "Can not apply this color, since its distance to the Application Color is to small.", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
      // Else let delegate store and go back in the view hirarchie
      } else {
        delegate?.colorSelected(color: colorPicker.color)
        self.dismiss(animated: true, completion: nil)
      }
      
    // If this color change should belong to the application color
    case .applicationColor:
      // Calculate the distance to the background color
      let distance = colorPicker.color.CIE94(compare: Settings.sharedInstance.bgColor)
      print("Distance to bgColor is \(distance)")
      // If distance is too small, show error alert
      if distance < Settings.sharedInstance.distanceThreshold {
        let alertController = UIAlertController(title: "Color Error", message:
          "Can not apply this color, since its distance to the Background Color is to small.", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
      // Else let delegate store and go back in the view hirarchie
      } else {
        delegate?.colorSelected(color: colorPicker.color)
        self.dismiss(animated: true, completion: nil)
      }
    }
    print("savePressed")
  }
  
  /*
   * If cancel is pressed, go back in the view hirarchie
   */
  @IBAction func cancelPressed(_ sender: AnyObject) {
    print("cancelPressed")
    self.dismiss(animated: true, completion: nil)
  }
}

