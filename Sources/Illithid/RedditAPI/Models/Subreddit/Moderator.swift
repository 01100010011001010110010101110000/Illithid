//
// Moderator.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 3/21/20
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

  private enum CodingKeys: String, CodingKey {
    case name
    case authorFlairText = "author_flair_text"
    case modPermissions = "mod_permissions"
    case date
    case relId = "rel_id"
    case id
    case authorFlairCssClass = "author_flair_css_class"
  }
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
