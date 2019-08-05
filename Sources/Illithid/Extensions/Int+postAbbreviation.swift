//
//  Int+postAbbreviation.swift
//  Illithid
//
//  Created by Tyler Gregory on 5/30/19.
//  Copyright © 2019 flayware. All rights reserved.
//

import Foundation

public extension Int {
  func postAbbreviation(_ significantFigures: Int = 2) -> String {
    guard self >= 1000 else { return self.description }
    let float_self = Double(self)
    let (divisor, unit) = self >= 1_000_000 ? (1_000_000.0, "M") : (1_000.0, "k")
    return String(format: "%.\(significantFigures)f\(unit)", float_self / divisor)
  }
  
  func absoluteDifference(to: Int) -> UInt {
    return (self - to).magnitude
  }
}
