//
//  RedditAccount.swift
//  Illithid
//
//  Created by Tyler Gregory on 11/26/18.
//  Copyright © 2018 flayware. All rights reserved.
//

import Foundation

public struct RedditAccount: RedditObject, Codable {
  public static func == (lhs: RedditAccount, rhs: RedditAccount) -> Bool {
    return lhs.name == rhs.name
  }

  public var id: String //swiftlint:disable:this identifier_name
  public var name: String
  
  public var isEmployee: Bool
  public var prefNoProfanity: Bool?
}
