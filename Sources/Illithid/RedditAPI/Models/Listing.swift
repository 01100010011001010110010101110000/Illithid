//
// Listing.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 12/24/19
//

import Foundation

import Alamofire

public struct Listing: Codable {
  public let kind: Kind = .listing
  private let data: ListingData

  fileprivate struct ListingData: Codable {
    let modhash: String?
    let dist: Int?
    let children: [Content]
    let after: Fullname?
    let before: Fullname?

    init(modhash: String? = nil, dist: Int? = nil, children: [Content] = [],
         after: Fullname? = nil, before: Fullname? = nil) {
      self.modhash = modhash
      self.dist = dist
      self.children = children
      self.after = after
      self.before = before
    }
  }

  public var after: Fullname? { data.after }
  public var before: Fullname? { data.before }
  public var dist: Int? { data.dist }
  public var modhash: String? { data.modhash }
  public var isEmpty: Bool { data.children.isEmpty }

  internal var children: [Content] { data.children }
}

private extension Listing {
  func items<T>(kind: Kind) -> [T] {
    data.children.compactMap { child in
      if child.kind == kind {
        switch child {
        case let .comment(comment):
          return comment as? T
        case let .account(account):
          return account as? T
        case let .post(post):
          return post as? T
        case let .subreddit(subreddit):
          return subreddit as? T
        case let .award(award):
          return award as? T
        case let .more(more):
          return more as? T
        }
      } else { return nil }
    }
  }
}

public extension Listing {
  var allComments: [CommentWrapper] {
    data.children.compactMap { child in
      switch child {
      case let .comment(comment):
        return .comment(comment)
      case let .more(more):
        return .more(more)
      default:
        return nil
      }
    }
  }

  var comments: [Comment] { items(kind: .comment)}

  var accounts: [Account] { items(kind: .account) }

  var posts: [Post] { items(kind: .post) }

  //  var messages: [Message] {
  //    return data.children.compactMap { wrappedMessage in
  //      if case .message(let message) = wrappedMessage { return message }
  //      else { return nil }
  //    }
  //  }

  var subreddits: [Subreddit] { items(kind: .subreddit) }

  var awards: [Award] { items(kind: .award) }

  var more: More? { items(kind: .more).first }

  internal enum Content: Codable {
    case comment(Comment)
    case account(Account)
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
        self = .account(try container.decode(Account.self, forKey: .data))
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
      case let .comment(comment):
        try container.encode(comment, forKey: .data)
      case let .account(account):
        try container.encode(account, forKey: .data)
      case let .post(post):
        try container.encode(post, forKey: .data)
  //    case .message:
  //      break
      case let .subreddit(subreddit):
        try container.encode(subreddit, forKey: .data)
      case let .award(award):
        try container.encode(award, forKey: .data)
      case let .more(more):
        try container.encode(more, forKey: .data)
      }
    }
  }
}
