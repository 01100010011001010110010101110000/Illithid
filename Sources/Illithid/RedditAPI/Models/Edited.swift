//
// Edited.swift
// Copyright (c) 2019 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 12/24/19
//

import Foundation

public struct Edited: Codable {
  public let on: Date?

  /// The Reddit API returns either `false` or a UTC timestamp for this field, so if we can decode a Bool it has not been edited,
  /// otherwise we should deocde the edited date
  /// - Parameter decoder: A `Decoder` conforming object
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let _ = try? container.decode(Bool.self) {
      on = nil
    } else {
      on = try container.decode(Date.self)
    }
  }
}
