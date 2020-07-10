//
// FrontPage.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 4/12/20
//

import Foundation

import Alamofire

/// Contains cases for the different front page types
public enum FrontPage: String, Codable, URLConvertible, Identifiable, CaseIterable {
  // Drawn from the user's subscribed Subreddits
  case home

  // Drawn from posts across Reddit

  /// A susbset of `r/all` which excludes certain content
  case popular
  /// `Posts` from every `Subreddit` on Reddit, excluding those which have opted out
  case all
  /// Posts from a random `Subreddit`
  case random

  public var title: String {
    rawValue.capitalized
  }

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
  public var isNsfw: Bool {
    false
  }

  public var displayName: String {
    rawValue.capitalized
  }

  public var id: String {
    try! asURL().absoluteString
  }

  public func posts(sortBy sort: PostSort, location: Location? = nil, topInterval: TopInterval? = nil,
                    parameters: ListingParameters, queue: DispatchQueue = .main,
                    completion: @escaping (Result<Listing, AFError>) -> Void) -> DataRequest {
    Illithid.shared.fetchPosts(for: self, sortBy: sort, location: location, topInterval: topInterval, params: parameters, queue: queue) { result in
      completion(result)
    }
  }
}
