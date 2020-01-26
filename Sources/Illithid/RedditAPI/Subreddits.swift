//
// Subreddits.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 12/24/19
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
                  params: ListingParameters = .init(), queue: DispatchQueue? = nil,
                  completion: @escaping (Swift.Result<Listing, Error>) -> Void) {
    let parameters = params.toParameters()
    let subredditsListUrl = URL(string: "/subreddits/\(subredditSort)", relativeTo: baseURL)!

    readListing(url: subredditsListUrl, parameters: parameters, queue: queue) { result in
      completion(result)
    }
  }
}

extension Subreddit: PostsProvider {
  public func posts(sortBy sort: PostSort, location: Location?, topInterval: TopInterval?,
                    parameters: ListingParameters, queue: DispatchQueue? = nil,
                    completion: @escaping (Swift.Result<Listing, Error>) -> Void) {
    Illithid.shared.fetchPosts(for: self, sortBy: sort, location: location, topInterval: topInterval, params: parameters, queue: queue) { result in
      completion(result)
    }
  }
}

public extension Subreddit {
  /// Fetches `Posts` on a `Subreddit`
  func posts(sortBy postSort: PostSort, location: Location? = nil, topInterval: TopInterval? = nil,
             params: ListingParameters = .init(), queue: DispatchQueue? = nil,
             completion: @escaping (Swift.Result<Listing, Error>) -> Void) {
    Illithid.shared.fetchPosts(for: self, sortBy: postSort, location: location, topInterval: topInterval,
                               params: params, queue: queue, completion: completion)
  }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Subreddit {
  /// Loads a specific `Subreddit` by its `Fullname`
  static func fetch(name: Fullname, queue: DispatchQueue? = nil) -> AnyPublisher<Subreddit, Error> {
    Illithid.shared.info(name: name, queue: queue)
      .compactMap { listing in
        listing.subreddits.last
      }.eraseToAnyPublisher()
  }
}

public extension Subreddit {
  /// Loads a specific `Subreddit` by its `Fullname`
  static func fetch(name: Fullname, queue: DispatchQueue? = nil,
                    completion: @escaping (Swift.Result<Subreddit, Error>) -> Void) {
    Illithid.shared.info(name: name, queue: queue) { result in
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
