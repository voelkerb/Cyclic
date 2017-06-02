//
//  BrowseWorkOutViewController.swift
//  Ciclyc
//
//  Created by Benjamin Völker on 26/09/2016.
//  Copyright © 2016 Benjamin Völker. All rights reserved.
//

import UIKit

class BrowseWorkOutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet var tableView:UITableView!
  @IBOutlet var backStackView:UIStackView!
  @IBOutlet weak var browseLabel: UILabel!
  
  let workOutDB = WorkOutDataBase.sharedInstance

  override func viewDidLoad() {
    super.viewDidLoad()
    //self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    // Do any additional setup after loading the view.
    
    // Add observer for color changes, will reinit the complete view
    NotificationCenter.default.addObserver(self, selector: #selector(loadStyle), name: Settings.NotificationColorChanged.name, object: nil)
    
    loadStyle()
  }
  
  /*
   * Load style will load all view elements in the view with there corresponding color
   */
  func loadStyle() {
    self.view.backgroundColor = Settings.sharedInstance.bgColor
    tableView.backgroundColor = Settings.sharedInstance.bgColor
    tableView.separatorColor = Settings.sharedInstance.appColor
    browseLabel.textColor = Settings.sharedInstance.appColor
    makeBackButtonStackView()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return workOutDB.workouts.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "WorkOutCell") as! WorkOutTableViewCell
    
    let workout = workOutDB.workouts[indexPath.row]
    
    print(workout)
    
    cell.workOutName.text = workout.workoutName
    cell.workOutDate.text = Time().getStr(dateWithTime: workout.startTime)
    cell.isUserInteractionEnabled = true
    //cell.selectionStyle = .none
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.performSegue(withIdentifier: "workoutDetailSegue", sender: self)
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      let index = indexPath.row
      workOutDB.deleteWorkout(workout: workOutDB.workouts[index])
      workOutDB.saveWorkouts()
      tableView.deleteRows(at: [indexPath as IndexPath], with: .fade)
    }
  }
  
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.destination is ShowWorkOutViewController {
      let workoutDetailsViewController = segue.destination as! ShowWorkOutViewController
      let index = tableView.indexPathForSelectedRow!.row
      let workout = workOutDB.workouts[index]
      workoutDetailsViewController.workout = workout
    }
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
    print("backPressed")
    self.dismiss(animated: true, completion: nil)
  }
}
