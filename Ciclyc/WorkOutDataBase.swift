//
//  WorkOutDataBase.swift
//  Ciclyc
//
//  Created by Benjamin Völker on 23/09/2016.
//  Copyright © 2016 Benjamin Völker. All rights reserved.
//

import UIKit

class WorkOutDataBase: NSObject {
  static let ArchiveURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("cyclic.workouts")
  
  var workouts:[WorkOut]! = [WorkOut]()
  
  static let sharedInstance = WorkOutDataBase()
  
  private override init() {
    print("Workouts init")
    super.init()
    self.workouts = [WorkOut]()
    loadWorkouts()
  }
  
  func saveWorkouts() {
    let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(workouts, toFile: WorkOutDataBase.ArchiveURL!.path)
    if !isSuccessfulSave {
      print("Failed to save workouts...")
    } else {
      print("Workouts stored sucessfull")
    }
  }
  
  func addWorkout(workout: WorkOut) {
    if self.workouts == nil { print("error: workouts nil") }
    self.workouts.append(workout)
  }
  
  func deleteWorkout(workout: WorkOut) {
    if let index = workouts.index(of: workout) {
      if index >= 0 && index < workouts.count {
        workouts.remove(at: workouts.index(of: workout)!)
      }
    }
  }
  
  func loadWorkouts() {
    workouts = NSKeyedUnarchiver.unarchiveObject(withFile: WorkOutDataBase.ArchiveURL!.path) as? [WorkOut]
    if workouts != nil {
      print(workouts)
    } else {
      workouts = [WorkOut]()
    }
  }

  subscript(index: Int) -> WorkOut? {
    guard let workout = workouts?[index] else {
      return nil
    }
    return workout
  }
  
}
