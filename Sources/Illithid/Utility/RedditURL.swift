//
// RedditURL.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 3/21/20
//

import Foundation

/// This is a wrapper struct to make decoding URL types from Reddit's API more convenient
/// Reddit returns the empty string when an object does not have the content it would otherwise link to via a URL
public struct RedditURL: Codable, Hashable, Equatable {
  public let url: URL?

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if container.decodeNil() {
      url = nil
    } else if let emptyString = try? container.decode(String.self), emptyString.isEmpty {
      url = nil
    } else {
      url = try container.decode(URL.self)
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(url)
  }
}
