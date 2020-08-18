//
// More.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 8/1/20
//

import Foundation

public struct More: RedditObject {
  public let count: Int
  public let name: Fullname
  public let id: ID36
  public let parentId: Fullname
  public let depth: Int
  public let children: [ID36]

  private enum CodingKeys: String, CodingKey {
    case count
    case name
    case id
    case parentId = "parent_id"
    case depth
    case children
  }
}

/// Data structure returned from `/api/morechildren`
internal struct MoreChildren: Codable {
  fileprivate let json: Json

  public var comments: [Comment] {
    json.data.things.compactMap { thing in
      if case let Listing.Content.comment(comment) = thing { return comment }
      else { return nil }
    }
  }

  public var more: More? {
    for thing in json.data.things {
      if case let Listing.Content.more(more) = thing { return more }
    }
    return nil
  }

  fileprivate struct Json: Codable {
    public let errors: [String]
    public let data: Data

    fileprivate struct Data: Codable {
      public let things: [Listing.Content]
    }
  }
}
