//
//  SpecialSubreddits.swift
//
//
//  Created by Tyler Gregory on 11/22/19.
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
