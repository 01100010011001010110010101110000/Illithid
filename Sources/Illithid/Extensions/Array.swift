//
//  File.swift
//
//
//  Created by Tyler Gregory on 6/17/19.
//

import Foundation

public extension Array {
  var middle: Element {
    let middleIndex = self.isEmpty ? 0 : self.count / 2
    return self[middleIndex]
  }
}
