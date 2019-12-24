//
// Errors.swift
// Copyright (c) 2019 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 12/24/19
//

import Foundation

import SwiftyJSON

public extension Illithid {
  struct NotFound: LocalizedError {
    let lookingFor: String
  }
}

extension JSONDecoder {
  func writeDecodingContext(decoding: Data, error _: DecodingError) {
    guard let json = try? JSON(data: decoding).rawString(options: [.sortedKeys, .prettyPrinted]) else { return }
    let filename = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
      .appendingPathComponent("api-decoding-error-\(Date.timeIntervalSinceReferenceDate).json")
    try! json.write(to: filename, atomically: true, encoding: .utf8)
  }
}
