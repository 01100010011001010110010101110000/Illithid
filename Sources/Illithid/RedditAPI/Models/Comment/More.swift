//
// More.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 3/21/20
//

import Foundation

public struct More: RedditObject {
  public let count: Int
  public let name: Fullname
  public let id: ID36
  public let parentId: Fullname
  public let depth: Int
  public let children: [ID36]
}

/// Data structure returned from `/api/morechildren`
internal struct MoreChildren: Codable {
  fileprivate let json: Json

  public var allComments: [CommentWrapper] {
    json.data.things.compactMap { child in
      if case let Listing.Content.comment(comment) = child { return .comment(comment) }
      else if case let Listing.Content.more(more) = child { return .more(more) }
      else { return nil }
    }
  }

  fileprivate struct Json: Codable {
    public let errors: [String]
    public let data: Data

    fileprivate struct Data: Codable {
      public let things: [Listing.Content]
    }
  }
}
