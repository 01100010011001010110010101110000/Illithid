//
// Posts.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 12/24/19
//

#if canImport(Combine)
  import Combine
#endif
import Foundation

import Alamofire
import Willow

public extension Illithid {
  @discardableResult
  func fetchPosts(for subreddit: Subreddit, sortBy postSort: PostSort,
                  location: Location? = nil, topInterval: TopInterval? = nil,
                  params: ListingParameters = .init(), queue: DispatchQueue = .main,
                  completion: @escaping (Result<Listing, AFError>) -> Void) -> DataRequest {
    var parameters = params.toParameters()
    let postsUrl = URL(string: "/r/\(subreddit.displayName)/\(postSort)", relativeTo: baseURL)!

   if let interval = topInterval { parameters["t"] = interval }
    if let location = location { parameters["g"] = location }

    return readListing(url: postsUrl, parameters: parameters, queue: queue) { result in
      completion(result)
    }
  }

  @discardableResult
  func fetchPosts(for multireddit: Multireddit, sortBy postSort: PostSort,
                  location: Location? = nil, topInterval: TopInterval? = nil,
                  params: ListingParameters = .init(), queue: DispatchQueue = .main,
                  completion: @escaping (Result<Listing, AFError>) -> Void) -> DataRequest {
    var parameters = params.toParameters()
    let postsUrl = URL(string: "/user/\(multireddit.owner)/m/\(multireddit.name)/\(postSort)", relativeTo: baseURL)!

    if let interval = topInterval { parameters["t"] = interval }
    if let location = location { parameters["g"] = location }

    return readListing(url: postsUrl, parameters: parameters, queue: queue) { result in
      completion(result)
    }
  }

  @discardableResult
  func fetchPosts(for frontPage: FrontPage, sortBy postSort: PostSort,
                  location: Location? = nil, topInterval: TopInterval? = nil,
                  params: ListingParameters = .init(), queue: DispatchQueue = .main,
                  completion: @escaping (Result<Listing, AFError>) -> Void) -> DataRequest {
    let frontPageUrl = try! frontPage.asURL().appendingPathComponent("\(postSort)")
    var parameters = params.toParameters()

    if let interval = topInterval { parameters["t"] = interval }
    if let location = location { parameters["g"] = location }

    return readListing(url: frontPageUrl, parameters: parameters, queue: queue) { result in
      completion(result)
    }
  }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Post {
  static func fetch(name: Fullname, queue: DispatchQueue = .main) -> AnyPublisher<Post, Error> {
    Illithid.shared.info(name: name, queue: queue)
      .compactMap { listing in
        listing.posts.last
      }.eraseToAnyPublisher()
  }
}

public extension Post {
  func upvote(queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) {
    Illithid.shared.vote(fullname: fullname, direction: .up, queue: queue, completion: completion)
  }
  func downvote(queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) {
    Illithid.shared.vote(fullname: fullname, direction: .down, queue: queue, completion: completion)
  }
  func clearVote(queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) {
    Illithid.shared.vote(fullname: fullname, direction: .clear, queue: queue, completion: completion)
  }

  func save(queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) {
    Illithid.shared.save(fullname: fullname, queue: queue, completion: completion)
  }
  func unsave(queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) {
    Illithid.shared.unsave(fullname: fullname, queue: queue, completion: completion)
  }
}

public extension Post {
  static func fetch(name: Fullname, queue: DispatchQueue = .main, completion: @escaping (Result<Post, Error>) -> Void) {
    Illithid.shared.info(name: name, queue: queue) { result in
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
           params: ListingParameters = .init(), queue: DispatchQueue = .main, completion: @escaping (Result<Listing, AFError>) -> Void) {
    Illithid.shared.fetchPosts(for: .all, sortBy: postSort, location: location, topInterval: topInterval,
                               params: params, queue: queue, completion: completion)
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
               params: ListingParameters = .init(), queue: DispatchQueue = .main, completion: @escaping (Result<Listing, AFError>) -> Void) {
    Illithid.shared.fetchPosts(for: .popular, sortBy: postSort, location: location, topInterval: topInterval,
                               params: params, queue: queue, completion: completion)
  }

  /// Fetches `Posts` from a random `Subreddit`
  /// - Parameters:
  ///   - postSort: The `PostSort` by which to sort the `Posts`
  ///   - location:
  ///   - topInterval: The interval in which to search for top `Posts` when `postSort` is `.top`
  ///   - params: Default parameters applicable to every `Listing` returning endpoint on Reddit
  ///   - completion: The callback function to execute when we get the `Post` `Listing` back from Reddit
  func random(sortBy postSort: PostSort, location: Location? = nil, topInterval: TopInterval? = nil,
              params: ListingParameters = .init(), queue: DispatchQueue = .main, completion: @escaping (Result<Listing, AFError>) -> Void) {
    Illithid.shared.fetchPosts(for: .random, sortBy: postSort, location: location, topInterval: topInterval,
                               params: params, queue: queue, completion: completion)
  }
}
