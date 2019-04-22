//
//  RedditAccount.swift
//  Illithid
//
//  Created by Tyler Gregory on 11/26/18.
//  Copyright © 2018 flayware. All rights reserved.
//

import Foundation

struct RedditAccount: RedditObject, Codable {
  var id: String //swiftlint:disable:this identifier_name
  var name: String
  var type: String = "t2"
  
  var isEmployee: Bool
  var noProfanity: Bool
  
  enum CodingKeys: String, CodingKey {
    case id //swiftlint:disable:this identifier_name
    case name
    case isEmployee = "is_employee"
    case noProfanity = "pref_no_profanity"
  }
}
