//
// Array.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 7/13/20
//

import Foundation

extension Array {
  var middle: Element? {
    guard !isEmpty else { return nil }
    return self[count / 2]
  }
}
