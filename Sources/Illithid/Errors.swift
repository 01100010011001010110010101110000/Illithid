//
// Errors.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 3/21/20
//

import Foundation

public extension Illithid {
  struct NotFound: LocalizedError {
    let lookingFor: String
  }
}
