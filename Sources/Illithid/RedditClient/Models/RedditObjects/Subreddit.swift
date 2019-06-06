//
// Created by Tyler Gregory on 11/19/18.
// Copyright (c) 2018 flayware. All rights reserved.
//

import Cocoa
import Foundation

public enum SubredditSort {
  case popular
  case new
  case gold
  case `default`
}

public struct Subreddit: RedditObject {
  public static func == (lhs: Subreddit, rhs: Subreddit) -> Bool {
    return lhs.name == rhs.name
  }

  public let id: String // swiftlint:disable:this identifier_name
  public let name: String
  public let type: String = "t5"
  public let publicDescription: String
  public let displayName: String
  public let wikiEnabled: Bool?
  public let headerImageURL: URL?
  public var headerImage: NSImage?
  public let over18: Bool
  public let createdUTC: Date

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(String.self, forKey: .id)
    self.name = try container.decode(String.self, forKey: .name)
    self.publicDescription = try container.decode(String.self, forKey: .publicDescription)
    self.displayName = try container.decode(String.self, forKey: .displayName)
    self.wikiEnabled = try container.decodeIfPresent(Bool.self, forKey: .wikiEnabled)
    let headerImageURLString = try container.decodeIfPresent(String.self, forKey: .headerImageURL)
    self.over18 = try container.decode(Bool.self, forKey: .over18)
    self.createdUTC = try container.decode(Date.self, forKey: .createdUTC)
    if headerImageURLString != nil, !headerImageURLString!.isEmpty {
      self.headerImageURL = try container.decode(URL.self, forKey: .headerImageURL)
    } else {
      self.headerImageURL = nil
    }
  }

  private enum CodingKeys: String, CodingKey {
    case id // swiftlint:disable:this identifier_name
    case name
    case publicDescription = "public_description"
    case displayName = "display_name"
    case wikiEnabled = "wiki_enabled"
    case headerImageURL = "header_img"
    case over18
    case createdUTC = "created_utc"
  }
}

extension Subreddit {
  public func posts(_ broker: RedditClientBroker, sortBy postSort: PostSort, location: Location? = nil, topInterval: TopInterval? = nil,
                    params: ListingParams = .init(), completion: @escaping (Listing<Post>) -> Void) {
    broker.fetchPosts(for: self, sortBy: postSort, location: location, topInterval: topInterval,
                      params: params, completion: completion)
  }
}
