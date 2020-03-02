//
// Moderator.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 03/02/2020
//

import Foundation

public typealias Moderator = User

public struct User: Codable, Identifiable {
  public let name: String
  public let authorFlairText: String?
  public let modPermissions: [String]
  public let date: Date
  public let relId: String
  public let id: Fullname
  public let authorFlairCssClass: String?
}

internal struct UserList: Codable {
  let kind: String
  fileprivate let data: UserListData
  var users: [User] {
    data.children
  }

  fileprivate struct UserListData: Codable {
    let children: [User]
  }
}
