//
//  RedditBaseClass.swift
//  Illithid
//
//  Created by Tyler Gregory on 1/18/19.
//  Copyright © 2019 flayware. All rights reserved.
//

import Foundation

enum ShowAllPreference: CustomStringConvertible {
  var description: String {
    switch self {
    case .all: return "all"
    default: return ""
    }
  }

  case all
  case filtered
}

/// The base class for all user-generated content on Reddit
protocol RedditObject: Codable {
  /// The object's unique identifier
  var id: String { get } // swiftlint:disable:this identifier_name

  /// The object's full name
  var name: String { get }

  /// The object's type as defined by the Reddit API
  /// e.g. "t5"
  var type: String { get }
}
