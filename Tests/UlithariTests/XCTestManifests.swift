//
// XCTestManifests.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 4/27/20
//

import Foundation
import XCTest

#if !canImport(ObjectiveC)
  public func allTests() -> [XCTestCaseEntry] {
    [
      testCase(UlithariTests.allTests)
    ]
  }
#endif
