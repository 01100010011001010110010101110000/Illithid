//
//  SessionManager+subreddits.swift
//  Illithid
//
//  Created by Tyler Gregory on 3/3/19.
//  Copyright © 2019 flayware. All rights reserved.
//

#if canImport(Combine)
  import Combine
#endif
import Foundation

import Alamofire
import SwiftyJSON

public extension Illithid {
  /**
   Loads subreddits from the Reddit API

   - Parameters:
     - subredditSort: Subreddit sort method
     - params: Standard listing parameters object
     - completion: Completion handler, is passed the listable as an argument
   */
  func subreddits(sortBy subredditSort: SubredditSort = .popular,
                  params: ListingParameters = .init(), completion: @escaping (Listing) -> Void) {
    let parameters = params.toParameters()
    let queryEncoding = URLEncoding(boolEncoding: .numeric)
    let subredditsListUrl = URL(string: "/subreddits/\(subredditSort)", relativeTo: baseURL)!

    session.request(subredditsListUrl, method: .get, parameters: parameters, encoding: queryEncoding)
      .validate().responseListing { response in
        switch response.result {
        case let .success(listing):
          completion(listing)
        case let .failure(error):
          self.logger.errorMessage("Error calling posts endpoint \(error)")
        }
      }
  }
}

public extension Subreddit {
  /// Fetches `Posts` on a `Subreddit`
  func posts(sortBy postSort: PostSort, location: Location? = nil, topInterval: TopInterval? = nil,
                    params: ListingParameters = .init(), completion: @escaping (Listing) -> Void) {
    Illithid.shared.fetchPosts(for: self, sortBy: postSort, location: location, topInterval: topInterval,
                      params: params, completion: completion)
  }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Subreddit {
  /// Loads a specific `Subreddit` by its `Fullname`
  static func fetch(name: Fullname) -> AnyPublisher<Subreddit, Error> {
    Illithid.shared.info(name: name)
      .compactMap { listing in
        listing.subreddits.last
      }.eraseToAnyPublisher()
  }
}

public extension Subreddit {
  /// Loads a specific `Subreddit` by its `Fullname`
  static func fetch(name: Fullname, completion: @escaping (Result<Subreddit>) -> Void) {
    Illithid.shared.info(name: name) { result in
      switch result {
      case let .success(listing):
        guard let subreddit = listing.subreddits.last else {
          completion(.failure(Illithid.NotFound(lookingFor: name)))
          return
        }
        completion(.success(subreddit))
      case let .failure(error):
        completion(.failure(error))
      }
    }
  }
}
