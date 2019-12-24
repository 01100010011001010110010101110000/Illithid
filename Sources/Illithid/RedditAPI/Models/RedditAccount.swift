//
// RedditAccount.swift
// Copyright (c) 2019 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 12/24/19
//

import Foundation

public struct RedditAccount: RedditObject, Codable {
  public static func == (lhs: RedditAccount, rhs: RedditAccount) -> Bool {
    lhs.name == rhs.name
  }

  public var id: String // swiftlint:disable:this identifier_name
  public var name: String

  public var isEmployee: Bool
  public var prefNoProfanity: Bool?
}
