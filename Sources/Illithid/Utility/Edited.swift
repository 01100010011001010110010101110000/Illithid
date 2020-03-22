//
// Edited.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 3/21/20
//

import Foundation

/// The Reddit API returns either `false` or a UTC timestamp for this field, so if we can decode a Bool it has not been edited,
/// otherwise we should deocde the edited date
public struct Edited: Codable {
  public let on: Date?

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if container.decodeNil() {
      on = nil
    } else if let _ = try? container.decode(Bool.self) {
      on = nil
    } else {
      on = try container.decode(Date.self)
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(on)
  }
}
