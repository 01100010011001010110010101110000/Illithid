//
//  File.swift
//  
//
//  Created by Tyler Gregory on 6/20/19.
//

import Foundation

public struct Edited: Codable {
  public let on: Date?

  public init(from decoder: Decoder) throws {
    var container = try decoder.singleValueContainer()
    on = try? container.decode(Date.self)
  }
}
