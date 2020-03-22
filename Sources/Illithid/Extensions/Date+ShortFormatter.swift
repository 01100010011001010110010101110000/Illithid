//
// Date+ShortFormatter.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 3/21/20
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
