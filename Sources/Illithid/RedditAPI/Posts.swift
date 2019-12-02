//
//  File.swift
//  Illithid
//
//  Created by Tyler Gregory on 4/30/19.
//  Copyright © 2019 flayware. All rights reserved.
//

#if canImport(Combine)
  import Combine
#endif
import Foundation

import Alamofire
import AlamofireImage
import SwiftyJSON
import Willow

public extension Illithid {
  func fetchPosts(for subreddit: Subreddit, sortBy postSort: PostSort,
                  location: Location? = nil, topInterval: TopInterval? = nil,
                  params: ListingParameters = .init(), completion: @escaping (Listing) -> Void) {
    var parameters = params.toParameters()
    let queryEncoding = URLEncoding(boolEncoding: .numeric)
    let postsUrl = URL(string: "/r/\(subreddit.displayName)/\(postSort)", relativeTo: baseURL)!

    // Handle nonsense magic string parameters which apply to specific sorts
    switch postSort {
    case .controversial, .top:
      parameters["t"] = topInterval ?? TopInterval.day
    case .hot:
      parameters["g"] = location ?? Location.GLOBAL
    default:
      break
    }

    session.request(postsUrl, method: .get, parameters: parameters, encoding: queryEncoding).validate()
      .responseListing { response in
        switch response.result {
        case let .success(listing):
          completion(listing)
        case let .failure(error):
          self.logger.errorMessage("Error calling posts endpoint \(error)")
        }
      }
  }

  func fetchPosts(for multireddit: Multireddit, sortBy postSort: PostSort,
                  location: Location? = nil, topInterval: TopInterval? = nil,
                  params: ListingParameters = .init(), completion: @escaping (Listing) -> Void) {
    var parameters = params.toParameters()
    let queryEncoding = URLEncoding(boolEncoding: .numeric)
    let postsUrl = URL(string: "/user/\(multireddit.owner)/m/\(multireddit.name)/\(postSort)", relativeTo: baseURL)!

    // Handle nonsense magic string parameters which apply to specific sorts
    switch postSort {
    case .controversial, .top:
      parameters["t"] = topInterval ?? TopInterval.day
    case .hot:
      parameters["g"] = location ?? Location.GLOBAL
    default:
      break
    }

    session.request(postsUrl, method: .get, parameters: parameters, encoding: queryEncoding).validate()
      .responseListing { response in
        switch response.result {
        case let .success(listing):
          completion(listing)
        case let .failure(error):
          self.logger.errorMessage("Error calling posts endpoint \(error)")
        }
      }
  }

  func fetchPosts(for frontPage: FrontPage, sortBy postSort: PostSort,
                  location: Location? = nil, topInterval: TopInterval? = nil,
                  params: ListingParameters = .init(), completion: @escaping (Listing) -> Void) {
    var parameters = params.toParameters()
    let queryEncoding = URLEncoding(boolEncoding: .numeric)

    // Handle nonsense magic string parameters which apply to specific sorts
    switch postSort {
    case .controversial, .top:
      parameters["t"] = topInterval ?? TopInterval.day
    case .hot:
      parameters["g"] = location ?? Location.GLOBAL
    default:
      break
    }

    session.request(frontPage, method: .get, parameters: parameters, encoding: queryEncoding).validate()
      .responseListing { response in
        switch response.result {
        case let .success(listing):
          completion(listing)
        case let .failure(error):
          self.logger.errorMessage("Error calling posts endpoint \(error)")
        }
      }
  }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Post {
  static func fetch(name: Fullname) -> AnyPublisher<Post, Error> {
    Illithid.shared.info(name: name)
      .compactMap { listing in
        listing.posts.last
      }.eraseToAnyPublisher()
  }
}

public extension Post {
  static func fetch(name: Fullname, completion: @escaping (Result<Post>) -> Void) {
    Illithid.shared.info(name: name) { result in
      switch result {
      case let .success(listing):
        guard let post = listing.posts.last else {
          completion(.failure(Illithid.NotFound(lookingFor: name)))
          return
        }
        completion(.success(post))
      case let .failure(error):
        completion(.failure(error))
      }
    }
  }

  /// Fetches `Posts` from `r/all`, a metasubreddit which contains posts from all `Subreddits`
  /// - Parameters:
  ///   - postSort: The `PostSort` by which to sort the `Posts`
  ///   - location:
  ///   - topInterval: The interval in which to search for top `Posts` when `postSort` is `.top`
  ///   - params: Default parameters applicable to every `Listing` returning endpoint on Reddit
  ///   - completion: The callback function to execute when we get the `Post` `Listing` back from Reddit
  func all(sortBy postSort: PostSort, location: Location? = nil, topInterval: TopInterval? = nil,
           params: ListingParameters = .init(), completion: @escaping (Listing) -> Void) {
    Illithid.shared.fetchPosts(for: .all, sortBy: postSort, location: location, topInterval: topInterval,
                               params: params, completion: completion)
  }

  /// Fetches `Posts` from `r/popular`, which is a subset of the posts from `r/all` and is the default front page for non-authenticated users
  /// The announcement of `r/popular` and further details may be found [here](https://www.reddit.com/r/announcements/comments/5u9pl5)
  /// - Parameters:
  ///   - postSort: The `PostSort` by which to sort the `Posts`
  ///   - location:
  ///   - topInterval: The interval in which to search for top `Posts` when `postSort` is `.top`
  ///   - params: Default parameters applicable to every `Listing` returning endpoint on Reddit
  ///   - completion: The callback function to execute when we get the `Post` `Listing` back from Reddit
  func popular(sortBy postSort: PostSort, location: Location? = nil, topInterval: TopInterval? = nil,
               params: ListingParameters = .init(), completion: @escaping (Listing) -> Void) {
    Illithid.shared.fetchPosts(for: .popular, sortBy: postSort, location: location, topInterval: topInterval,
                               params: params, completion: completion)
  }

  /// Fetches `Posts` from a random `Subreddit`
  /// - Parameters:
  ///   - postSort: The `PostSort` by which to sort the `Posts`
  ///   - location:
  ///   - topInterval: The interval in which to search for top `Posts` when `postSort` is `.top`
  ///   - params: Default parameters applicable to every `Listing` returning endpoint on Reddit
  ///   - completion: The callback function to execute when we get the `Post` `Listing` back from Reddit
  func random(sortBy postSort: PostSort, location: Location? = nil, topInterval: TopInterval? = nil,
              params: ListingParameters = .init(), completion: @escaping (Listing) -> Void) {
    Illithid.shared.fetchPosts(for: .random, sortBy: postSort, location: location, topInterval: topInterval,
                               params: params, completion: completion)
  }
}
