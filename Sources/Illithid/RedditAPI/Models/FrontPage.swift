//
// FrontPage.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 12/24/19
//

import Foundation

import Alamofire

/// Contains cases for the different front page types
public enum FrontPage: String, Codable, URLConvertible {
  // Drawn from the user's subscribed Subreddits
  case home

  // Drawn from posts across Reddit

  /// A susbset of `r/all` which excludes certain content
  case popular
  /// `Posts` from every `Subreddit` on Reddit, excluding those which have opted out
  case all
  /// Posts from a random `Subreddit`
  case random

  public func asURL() throws -> URL {
    switch self {
    case .popular, .all, .random:
      return URL(string: "/r/\(self)/", relativeTo: Illithid.shared.baseURL)!
    default:
      return URL(string: "/", relativeTo: Illithid.shared.baseURL)!
    }
  }
}

extension FrontPage: PostProvider {
  public var id: String {
    try! self.asURL().absoluteString
  }
  public func posts(sortBy sort: PostSort, location: Location? = nil, topInterval: TopInterval? = nil,
                    parameters: ListingParameters, queue: DispatchQueue = .main,
                    completion: @escaping (Result<Listing, AFError>) -> Void) -> DataRequest {
    Illithid.shared.fetchPosts(for: self, sortBy: sort, location: location, topInterval: topInterval, params: parameters, queue: queue) { result in
      completion(result)
    }
  }
}
