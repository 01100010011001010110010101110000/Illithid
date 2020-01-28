//
//  File.swift
//  
//
//  Created by Tyler Gregory on 1/27/20.
//

import Foundation

internal extension DateComponentsFormatter {
  static let ShortFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.maximumUnitCount = 2
    formatter.collapsesLargestUnit = true
    formatter.unitsStyle = .full
    formatter.allowsFractionalUnits = true
    formatter.zeroFormattingBehavior = .dropAll
    formatter.allowedUnits = [.month, .day, .hour, .minute, .year]
    return formatter
  }()
}
