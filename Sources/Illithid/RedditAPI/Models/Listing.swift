// Copyright (C) 2020 Tyler Gregory (@01100010011001010110010101110000)
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of  MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <http://www.gnu.org/licenses/>.

import Foundation

import Alamofire

// MARK: - Listing

public struct Listing: Codable {
  // MARK: Public

  public let kind: Kind

  public var after: Fullname? { data.after }
  public var before: Fullname? { data.before }
  public var dist: Int? { data.dist }
  public var modhash: String? { data.modhash }
  public var isEmpty: Bool { data.children.isEmpty }

  public var children: [Content] { data.children }

  // MARK: Fileprivate

  fileprivate struct ListingData: Codable {
    // MARK: Lifecycle

    init(modhash: String? = nil, dist: Int? = nil, children: [Content] = [],
         after: Fullname? = nil, before: Fullname? = nil) {
      self.modhash = modhash
      self.dist = dist
      self.children = children
      self.after = after
      self.before = before
    }

    // MARK: Internal

    let modhash: String?
    let dist: Int?
    let children: [Content]
    let after: Fullname?
    let before: Fullname?
  }

  // MARK: Private

  private let data: ListingData
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
  var comments: [Comment] { items(kind: .comment) }

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

  enum Content: Codable, Identifiable, Equatable {
    case comment(Comment)
    case account(Account)
    case post(Post)
    //    case message(Message)
    case subreddit(Subreddit)
    case award(Award)
    case more(More)

    // MARK: Lifecycle

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

    // MARK: Public

    public var id: String {
      switch self {
      case let .account(account):
        return account.id
      case let .award(award):
        return award.id
      case let .comment(comment):
        return comment.id
      case let .post(post):
        return post.id
      case let .subreddit(subreddit):
        return subreddit.id
      case let .more(more):
        return more.id
      }
    }

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

    public static func == (lhs: Listing.Content, rhs: Listing.Content) -> Bool {
      if lhs.kind != rhs.kind { return false }
      return lhs.id == rhs.id
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)

      try container.encode(kind, forKey: .kind)

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

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
      case kind
      case data
    }
  }
}
