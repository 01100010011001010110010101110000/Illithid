//
//  File.swift
//  
//
//  Created by Tyler Gregory on 6/20/19.
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
