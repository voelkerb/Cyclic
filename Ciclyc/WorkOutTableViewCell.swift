//
//  WorkOutTableViewCell.swift
//  Ciclyc
//
//  Created by Benjamin Völker on 26/09/2016.
//  Copyright © 2016 Benjamin Völker. All rights reserved.
//

import UIKit

class WorkOutTableViewCell: UITableViewCell {
  @IBOutlet weak var workOutName: UILabel!
  @IBOutlet weak var workOutDate: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    
    // Add observer for color changes, will reinit the complete view
    NotificationCenter.default.addObserver(self, selector: #selector(loadStyle), name: Settings.NotificationColorChanged.name, object: nil)
    
    loadStyle()
    // Do any additional setup after loading the view.
  }
  
  /*
   * Load style will load all view elements in the view with there corresponding color
   */
  func loadStyle() {
    workOutName.textColor = Settings.sharedInstance.appColor
    workOutDate.textColor = Settings.sharedInstance.appColor
    self.backgroundColor = Settings.sharedInstance.bgColor
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
