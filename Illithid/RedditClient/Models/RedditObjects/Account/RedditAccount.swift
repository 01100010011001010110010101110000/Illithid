//
//  RedditAccount.swift
//  Illithid
//
//  Created by Tyler Gregory on 11/26/18.
//  Copyright © 2018 flayware. All rights reserved.
//

import Foundation

struct RedditAccount: RedditObject, Codable {
  var id: String
  var name: String
  var type: String
  
  var isEmployee: Bool
  var noProfanity: Bool
  
  enum CodingKeys: String, CodingKey {
    case id
    case name
    case type
    case isEmployee = "is_employee"
    case noProfanity = "pref_no_profanity"
  }
}
