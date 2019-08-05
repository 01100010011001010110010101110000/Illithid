//
//  Listable.swift
//  Illithid
//
//  Created by Tyler Gregory on 3/3/19.
//  Copyright © 2019 flayware. All rights reserved.
//

import Foundation

public struct Listing: Codable {
  public let kind: Kind = .listing
  private let data: ListingData

  fileprivate struct ListingData: Codable {
    fileprivate let modhash: String?
    fileprivate let dist: Int?
    fileprivate let children: [Content]
    fileprivate let after: String?
    fileprivate let before: String?
  }

  public var after: String? { data.after }
  public var before: String? { data.before }
  public var dist: Int? { data.dist }
  public var children: [Content] { data.children }
  public var modhash: String? { data.modhash }
}

private extension Listing {
  func items<T>(kind: Kind) -> [T] {
    return data.children.compactMap { child in
      if child.kind == kind {
        switch child {
        case .comment(let comment):
          return comment as? T
        case .account(let account):
          return account as? T
        case .post(let post):
          return post as? T
        case .subreddit(let subreddit):
          return subreddit as? T
        case .award(let award):
          return award as? T
        case .more(let more):
          return more as? T
        }
      } else { return nil }
    }
  }
}

public extension Listing {
  var comments: [Comment] { items(kind: .comment) }

  var accounts: [RedditAccount] { items(kind: .account) }

  var posts: [Post] { items(kind: .post) }

//  var messages: [Message] {
//    return data.children.compactMap { wrappedMessage in
//      if case .message(let message) = wrappedMessage { return message }
//      else { return nil }
//    }
//  }

  var subreddits: [Subreddit] { items(kind: .subreddit) }

  var awards: [Award] { items(kind: .award) }
}

public enum Content: Codable {
  case comment(Comment)
  case account(RedditAccount)
  case post(Post)
  //    case message(Message)
  case subreddit(Subreddit)
  case award(Award)
  case more(More)

  public var kind: Kind {
    switch self {
    case .comment:
      return .comment
    case .account:
      return .account
    case .post:
      return .post
    // case .message:
    // return .message
    case .subreddit:
      return .subreddit
    case .award:
      return .award
    case .more:
      return .more
    }
  }

  enum CodingKeys: String, CodingKey {
    case kind
    case data
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    switch try container.decode(Kind.self, forKey: .kind) {
    case .comment:
      self = .comment(try container.decode(Comment.self, forKey: .data))
    case .account:
      self = .account(try container.decode(RedditAccount.self, forKey: .data))
    case .post:
      self = .post(try container.decode(Post.self, forKey: .data))
    case .message:
      throw DecodingError.typeMismatch(Kind.self,
                                       DecodingError.Context(codingPath: container.codingPath,
                                                             debugDescription: "Message is yet to be implemented"))
    //      self.data = .message(try container.decode(Message.self, forKey: .data))
    case .subreddit:
      self = .subreddit(try container.decode(Subreddit.self, forKey: .data))
    case .award:
      self = .award(try container.decode(Award.self, forKey: .data))
    case .more:
      self = .more(try container.decode(More.self, forKey: .data))
    case .listing:
      throw DecodingError.typeMismatch(Kind.self,
                                       DecodingError.Context(codingPath: container.codingPath,
                                                             debugDescription: "Listings should not contain anothe listing"))
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(self.kind, forKey: .kind)

    switch self {
    case .comment(let comment):
      try container.encode(comment, forKey: .data)
    case .account(let account):
      try container.encode(account, forKey: .data)
    case .post(let post):
      try container.encode(post, forKey: .data)
//    case .message:
//      break
    case .subreddit(let subreddit):
      try container.encode(subreddit, forKey: .data)
    case .award(let award):
      try container.encode(award, forKey: .data)
    case .more(let more):
      try container.encode(more, forKey: .data)
    }
  }
}
