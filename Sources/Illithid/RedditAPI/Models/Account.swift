//
// Account.swift
// Copyright (c) 2019 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 12/24/19
//

import Foundation

public struct Account: RedditObject, Codable {
  public static func == (lhs: Account, rhs: Account) -> Bool {
    lhs.name == rhs.name
  }

  public var id: String // swiftlint:disable:this identifier_name
  public var name: String

  public var isEmployee: Bool
  public var prefNoProfanity: Bool?
}
