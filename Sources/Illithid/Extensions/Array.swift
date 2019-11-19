//
//  File.swift
//
//
//  Created by Tyler Gregory on 6/17/19.
//

import Foundation

public extension Array {
  var middle: Element? {
    guard !isEmpty else { return nil }
    return self[count / 2]
  }
}
