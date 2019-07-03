//
//  Listable.swift
//  Illithid
//
//  Created by Tyler Gregory on 3/3/19.
//  Copyright © 2019 flayware. All rights reserved.
//

import Foundation

public struct Listing<RedditType: RedditObject>: Codable {
  public let kind: Kind
  public let metadata: ListData

  private enum CodingKeys: String, CodingKey {
    case kind
    case metadata = "data"
  }

  public struct ListData: Codable {
    public let modhash: String?
    public let dist: Int?
    public let children: [ListChild]
    public let after: String?
    public let before: String?
  }

  public struct ListChild: Codable {
    public let kind: Kind
    public let object: RedditType

    private enum CodingKeys: String, CodingKey {
      case kind
      case object = "data"
    }
  }

  lazy var children: [RedditType] = {
    metadata.children.map { $0.object }
  }()
}

public enum Kind: String, Codable {
  case comment = "t1" // Comment
  case account = "t2" // Account
  case post = "t3" // Link (Post)
  case message = "t4" // Message
  case subreddit = "t5" // Subreddit
  case award = "t6" // Award
  case more
  case listing = "Listing"
}

public struct GeneralListing: Codable {
  public let kind: Kind = .listing
  public let data: ListingData

  public struct ListingData: Codable {
    public let modhash: String?
    public let dist: Int?
    public let children: [Content]
    public let after: String?
    public let before: String?
  }
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
    //case .message:
      //return .message
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
      try container.encode(more, forKey: .data )
    }
  }
}
