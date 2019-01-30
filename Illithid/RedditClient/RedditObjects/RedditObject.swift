//
//  RedditBaseClass.swift
//  Illithid
//
//  Created by Tyler Gregory on 1/18/19.
//  Copyright © 2019 flayware. All rights reserved.
//

import Foundation

/// The base class for all user-generated content on Reddit
protocol RedditObject: Codable {
  /// The object's unique identifier
  var id: String { get }
  
  /// The object's full name
  var name: String { get }
  
}
