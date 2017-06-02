//
//  MulticolorPolylineSegment.swift
//  Ciclyc
//
//  Created by Benjamin Völker on 27/09/2016.
//  Copyright © 2016 Benjamin Völker. All rights reserved.
//

import UIKit
import MapKit

class MulticolorPolylineSegment: MKPolyline {
  var color: UIColor?
  
  private class func allSpeeds(forLocations locations: [CLLocation]) ->
    (speeds: [Double], minSpeed: Double, maxSpeed: Double) {
      // Make Array of all speeds. Find slowest and fastest
      var speeds = [Double]()
      
      var minSpeed = DBL_MAX
      var maxSpeed = 0.0
      
      var minis = [Double]()
      let avgCount = 10
      for _ in 0..<avgCount {
       minis.append(DBL_MAX)
      }
      
      for i in 1..<locations.count {
        let l1 = locations[i-1]
        let l2 = locations[i]
        
        let distance = l2.distance(from: l1)
        let time = l2.timestamp.timeIntervalSince(l1.timestamp)
        let speed = distance/time
        
        // Test minspeed with minimum speed in location change (if you wait, nothing happens)
        //minSpeed = min(minSpeed, l2.speed)
        var greatestIdx = -1
        var greatest = 0.0
        var putInside = false
        for i in 0..<minis.count {
          if minis[i] > greatest {
            greatestIdx = i;
            greatest = minis[i]
          }
          if minis[i] > speed {
            putInside = true
          }
        }
        if putInside {
          if greatestIdx >= 0 && greatestIdx < minis.count {
            minis[greatestIdx] = speed
          }
        }
        
        minSpeed = min(minSpeed, speed)
        maxSpeed = max(maxSpeed, speed)
        //speeds.append(speed)
      }
      var minAvg = 0.0;
      var count = 0;
      for i in 0..<minis.count {
        if minis[i] != DBL_MAX {
          minAvg += minis[i]
          count += 1
        }
      }
      if (count != 0) {
        minAvg /= Double(count)
      }
      minSpeed = minAvg
      
      let smoothAvg = 5
      if locations.count  > smoothAvg {
        for j in 1..<smoothAvg {
          speeds.append(locations[j].speed)
        }
        for i in smoothAvg..<locations.count {
          var avgSpeed = 0.0
          for j in 0..<smoothAvg {
            avgSpeed += locations[i-j].speed
          }
          avgSpeed /= Double(smoothAvg)
          speeds.append(avgSpeed)
        }
      } else {
        for i in 0..<locations.count {
          speeds.append(locations[i].speed)
        }
      }
      
      print("Max Speed: ", maxSpeed, "Min Speed: ", minSpeed, "Min avg: ", minAvg)
      return (speeds, minSpeed, maxSpeed)
  }
  
  class func colorSegments(forLocations locations: [CLLocation]) -> [MulticolorPolylineSegment] {
    var colorSegments = [MulticolorPolylineSegment]()
    
    // RGB for Red (slowest)
    let red   = (r: 1.0, g: 20.0 / 255.0, b: 44.0 / 255.0)
    
    // RGB for Yellow (middle)
    let yellow = (r: 1.0, g: 215.0 / 255.0, b: 0.0)
    
    // RGB for Green (fastest)
    let green  = (r: 0.0, g: 146.0 / 255.0, b: 78.0 / 255.0)
    
    let (speeds, minSpeed, maxSpeed) = allSpeeds(forLocations: locations)
    
    // now knowing the slowest+fastest, we can get mean too
    
    var meanSpeed = 0.0;
    for i in 0..<speeds.count {
      meanSpeed += speeds[i]
    }
    meanSpeed /= Double(speeds.count)
    
    //let meanSpeed = (minSpeed + maxSpeed)/2
    
    for i in 1..<locations.count {
      let l1 = locations[i-1]
      let l2 = locations[i]
      
      var coords = [CLLocationCoordinate2D]()
      
      coords.append(CLLocationCoordinate2D(latitude: l1.coordinate.latitude, longitude: l1.coordinate.longitude))
      coords.append(CLLocationCoordinate2D(latitude: l2.coordinate.latitude, longitude: l2.coordinate.longitude))
      
      let speed = speeds[i-1]
      var color = UIColor.black
      
      if speed < meanSpeed { // Between Green & Yellow
        var ratio = (speed - minSpeed) / (meanSpeed - minSpeed)
        if ratio < 0 {
          ratio = 0;
        }
        let r = CGFloat(green.r + ratio * (yellow.r - green.r))
        let g = CGFloat(green.g + ratio * (yellow.g - green.g))
        let b = CGFloat(green.b + ratio * (yellow.b - green.r))
        color = UIColor(red: r, green: g, blue: b, alpha: 1)
      }
      else { // Between Yellow & Red
        var ratio = (speed - meanSpeed) / (maxSpeed - meanSpeed)
        if ratio < 0 {
          ratio = 0;
        }
        let r = CGFloat(yellow.r + ratio * (red.r - yellow.r))
        let g = CGFloat(yellow.g + ratio * (red.g - yellow.g))
        let b = CGFloat(yellow.b + ratio * (red.b - yellow.b))
        color = UIColor(red: r, green: g, blue: b, alpha: 1)
      }
      
      let segment = MulticolorPolylineSegment(coordinates: &coords, count: coords.count)
      segment.color = color
      colorSegments.append(segment)
    }
    
    return colorSegments
  }
}
