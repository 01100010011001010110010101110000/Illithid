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

// MARK: - FrontPage

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

  // MARK: Public

  public var title: String {
    rawValue.capitalized
  }

  public func asURL() throws -> URL {
    URL(string: postsPath, relativeTo: Illithid.shared.baseURL)!
  }
}

// MARK: PostProvider

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

  public var postsPath: String {
    switch self {
    case .all, .popular, .random:
      return "/r/\(self)/"
    default:
      return "/"
    }
  }

  public func posts(sortBy sort: PostSort, location: Location? = nil, topInterval: TopInterval? = nil,
                    parameters: ListingParameters, queue: DispatchQueue = .main,
                    completion: @escaping (Result<Listing, AFError>) -> Void)
    -> DataRequest {
    Illithid.shared.fetchPosts(for: self, sortBy: sort, location: location, topInterval: topInterval, params: parameters, queue: queue) { result in
      completion(result)
    }
  }
}
