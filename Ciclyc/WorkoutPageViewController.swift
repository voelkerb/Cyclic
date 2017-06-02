//
//  WorkoutPageViewController.swift
//  Ciclyc
//
//  Created by Benjamin Völker on 22/09/2016.
//  Copyright © 2016 Benjamin Völker. All rights reserved.
//

import UIKit

class WorkoutPageViewController: UIPageViewController {
  
  private(set) lazy var orderedViewControllers: [UIViewController] = {
    var vc:[UIViewController] = [UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StartWorkOutViewController")]
    if Settings.sharedInstance.showMap {
      vc.append(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WorkOutMapViewController"))
    }
    return vc
  }()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    dataSource = self
    
    // If map should not be shown, remove the viewcontroller
    if let firstViewController = orderedViewControllers.first {
      setViewControllers([firstViewController],
                         direction: .forward,
                         animated: true,
                         completion: nil)
      // Look if we should load the mapview or not
      if Settings.sharedInstance.showMap {
        // Init mapView controller also at beginning, to stop lagging when switched the first time
        let mapViewController = orderedViewControllers[1] as! WorkOutMapViewController
        let workoutViewController = firstViewController as! StartWorkOutViewController
        // Preload the viewcontroller to avoid lagging
        mapViewController.loadViewIfNeeded()
        // Give workout to second viewcontroller
        mapViewController.setWorkout(workout: workoutViewController.workout)
      }
    }
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}

// MARK: UIPageViewControllerDataSource

extension WorkoutPageViewController: UIPageViewControllerDataSource {
  
  func pageViewController(_ pageViewController: UIPageViewController,
                          viewControllerBefore viewController: UIViewController) -> UIViewController? {
    guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
      return nil
    }
    
    let previousIndex = viewControllerIndex - 1
    
    if previousIndex < 0 {
      return nil
    } else if previousIndex >= orderedViewControllers.count {
      return nil
    }
    
    return orderedViewControllers[previousIndex]
  }
  
  func pageViewController(_ pageViewController: UIPageViewController,
                          viewControllerAfter viewController: UIViewController) -> UIViewController? {
    
    guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
      return nil
    }
    
    let nextIndex = viewControllerIndex + 1
    
    if nextIndex < 0 {
      return nil
    } else if nextIndex >= orderedViewControllers.count {
      return nil
    }
    
    
    // If we must share the workout, share it
    if (nextIndex == 1) {
      let vc = orderedViewControllers[nextIndex] as! WorkOutMapViewController
      let oldVc = orderedViewControllers.first as! StartWorkOutViewController
      vc.setWorkout(workout: oldVc.workout)
      print("Shared workout to other view")
    }
    return orderedViewControllers[nextIndex]
  }
  
  func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
    return orderedViewControllers.count
  }
  
  func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
    guard let firstViewController = viewControllers?.first,
      let firstViewControllerIndex = orderedViewControllers.index(of: firstViewController) else {
        return 0
    }
    
    return firstViewControllerIndex
  }
}
