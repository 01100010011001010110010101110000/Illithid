//
//  RedditAccount.swift
//  Illithid
//
//  Created by Tyler Gregory on 11/26/18.
//  Copyright © 2018 flayware. All rights reserved.
//

import Foundation

public struct RedditAccount: RedditObject, Codable {
  public var id: String //swiftlint:disable:this identifier_name
  public var name: String
  public var type: String = "t2"
  
  public var isEmployee: Bool
  public var noProfanity: Bool
  
  private enum CodingKeys: String, CodingKey {
    case id //swiftlint:disable:this identifier_name
    case name
    case isEmployee = "is_employee"
    case noProfanity = "pref_no_profanity"
  }
}
