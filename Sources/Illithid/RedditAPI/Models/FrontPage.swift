//
// FrontPage.swift
// Copyright (c) 2019 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 12/24/19
//

import Foundation

import Alamofire

/// Contains cases for the different front page types
public enum FrontPage: String, Codable, URLConvertible {
  // Drawn from the user's subscribed Subreddits
  case hot
  case best
  case new
  case rising
  case top
  case controversial

  // Drawn from posts across Reddit

  /// A susbset of `r/all` which excludes certain content
  case popular
  /// `Posts` from every `Subreddit` on Reddit, excluding those which have opted out
  case all
  /// Posts from a random `Subreddit`
  case random

  public func asURL() throws -> URL {
    switch self {
    case .popular, .all:
      return URL(string: "/r/\(self)", relativeTo: Illithid.shared.baseURL)!
    default:
      return URL(string: "/\(self)", relativeTo: Illithid.shared.baseURL)!
    }
  }
}

extension FrontPage: PostsProvider {
  public func posts(sortBy sort: PostSort, location: Location? = nil, topInterval: TopInterval? = nil,
                    parameters: ListingParameters, queue: DispatchQueue? = nil,
                    completion: @escaping (Swift.Result<Listing, Error>) -> Void) {
    Illithid.shared.fetchPosts(for: self, sortBy: sort, location: location, topInterval: topInterval, params: parameters, queue: queue) { result in
      completion(result)
    }
  }
}
