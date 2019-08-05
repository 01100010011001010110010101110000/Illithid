//
// Created by Tyler Gregory on 11/19/18.
// Copyright (c) 2018 flayware. All rights reserved.
//

import Cocoa
import Combine
import Foundation

import Alamofire

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

  /// The Reddit API sometimes returns the empty string for the `header_img` parameter, and also may return `nil`, so we handle the empty srtring, then
  /// decode the actual URL if it is present
  /// - Parameter decoder: A `Decoder` conforming object
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(String.self, forKey: .id)
    self.name = try container.decode(String.self, forKey: .name)
    self.publicDescription = try container.decode(String.self, forKey: .publicDescription)
    self.displayName = try container.decode(String.self, forKey: .displayName)
    self.wikiEnabled = try container.decodeIfPresent(Bool.self, forKey: .wikiEnabled)
    self.over18 = try container.decode(Bool.self, forKey: .over18)
    self.createdUTC = try container.decode(Date.self, forKey: .createdUTC)

    if let emptyString = try? container.decode(String.self, forKey: .headerImageURL), emptyString.isEmpty {
      headerImageURL = nil
    } else {
      headerImageURL = try container.decodeIfPresent(URL.self, forKey: .headerImageURL)
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
                    params: ListingParameters = .init(), completion: @escaping (Listing) -> Void) {
    broker.fetchPosts(for: self, sortBy: postSort, location: location, topInterval: topInterval,
                      params: params, completion: completion)
  }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Subreddit {
  static func fetch(name: Fullname, client: RedditClientBroker) -> AnyPublisher<Subreddit, Error> {
    client.info(name: name)
      .compactMap { listing in
        return listing.subreddits.last
    }.eraseToAnyPublisher()
  }
}

public extension Post {
  static func fetch(name: Fullname, client: RedditClientBroker, completion: @escaping (Result<Subreddit>) -> Void) {
    client.info(name: name) { result in
      switch result {
      case .success(let listing):
        guard let subreddit = listing.subreddits.last else {
          completion(.failure(RedditClientBroker.NotFound(lookingFor: name)))
          return
        }
        completion(.success(subreddit))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}
