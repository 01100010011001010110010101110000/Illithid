//
// LinuxMain.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 3/21/20
//

import XCTest

import IllithidTests
import UlithariTests

var tests = [XCTestCaseEntry]()
tests += IllithidTests.allTests()
tests += UlithariTests.allTests()
XCTMain(tests)
