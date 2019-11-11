//
//  File.swift
//
//
//  Created by Tyler Gregory on 6/17/19.
//

import Foundation

public extension Array {
  var middle: Element {
    let middleIndex = isEmpty ? 0 : count / 2
    return self[middleIndex]
  }
}
