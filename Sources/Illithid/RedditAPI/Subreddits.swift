//
// Subreddits.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 3/21/20
//

#if canImport(Combine)
  import Combine
#endif
import Foundation

import Alamofire

public extension Illithid {
  /**
   Loads subreddits from the Reddit API

   - Parameters:
     - subredditSort: Subreddit sort method
     - params: Standard listing parameters object
     - completion: Completion handler, is passed the listable as an argument
   */
  func subreddits(sortBy subredditSort: SubredditSort = .popular,
                  params: ListingParameters = .init(), queue: DispatchQueue = .main,
                  completion: @escaping (Result<Listing, AFError>) -> Void) {
    let parameters = params.toParameters()
    let subredditsListUrl = URL(string: "/subreddits/\(subredditSort)", relativeTo: baseURL)!

    readListing(url: subredditsListUrl, parameters: parameters, queue: queue) { result in
      completion(result)
    }
  }
}

// MARK: Getting posts

extension Subreddit: PostProvider {
  public var isNsfw: Bool {
    over18 ?? false
  }

  public func posts(sortBy sort: PostSort, location: Location?, topInterval: TopInterval?,
                    parameters: ListingParameters, queue: DispatchQueue = .main,
                    completion: @escaping (Result<Listing, AFError>) -> Void) -> DataRequest {
    Illithid.shared.fetchPosts(for: self, sortBy: sort, location: location, topInterval: topInterval, params: parameters, queue: queue) { result in
      completion(result)
    }
  }
}

public extension Subreddit {
  /// Fetches `Posts` on a `Subreddit`
  func posts(sortBy postSort: PostSort, location: Location? = nil, topInterval: TopInterval? = nil,
             params: ListingParameters = .init(), queue: DispatchQueue = .main,
             completion: @escaping (Result<Listing, AFError>) -> Void) {
    Illithid.shared.fetchPosts(for: self, sortBy: postSort, location: location, topInterval: topInterval,
                               params: params, queue: queue, completion: completion)
  }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Subreddit {
  /// Loads a specific `Subreddit` by its `Fullname`
  static func fetch(name: Fullname, queue: DispatchQueue = .main) -> AnyPublisher<Subreddit, Error> {
    Illithid.shared.info(name: name, queue: queue)
      .compactMap { listing in
        listing.subreddits.last
      }.eraseToAnyPublisher()
  }
}

public extension Subreddit {
  /// Loads a specific `Subreddit` by its `Fullname`
  static func fetch(name: Fullname, queue: DispatchQueue = .main,
                    completion: @escaping (Result<Subreddit, Error>) -> Void) {
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

  /// Load a `Subreddit` by its `displayName`
  static func fetch(displayName: String, queue: DispatchQueue = .main,
                    completion: @escaping (Result<Subreddit, AFError>) -> Void) {
    let aboutUrl = URL(string: "/r/\(displayName)/about", relativeTo: Illithid.shared.baseURL)!
    Illithid.shared.session.request(aboutUrl, method: .get)
      .validate()
      .responseDecodable(of: Subreddit.self, queue: queue, decoder: Illithid.shared.decoder) { response in
        completion(response.result)
      }
  }
}

// MARK: Subscription

public extension Subreddit {
  func subscribe(queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) {
    Illithid.shared.changeSubscription(of: self, isSubscribed: true, queue: queue, completion: completion)
  }

  func unsubscribe(queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) {
    Illithid.shared.changeSubscription(of: self, isSubscribed: false, queue: queue, completion: completion)
  }
}

// MARK: Moderator fetching

extension Illithid {
  public func moderatorsOf(displayName subredditName: String, queue: DispatchQueue = .main,
                           completion: @escaping (Result<[Moderator], AFError>) -> Void) -> DataRequest {
    let moderatorsUrl = URL(string: "/r/\(subredditName)/about/moderators", relativeTo: baseURL)!

    return session.request(moderatorsUrl, method: .get)
      .validate()
      .responseDecodable(of: UserList.self, queue: queue, decoder: decoder) { response in
        switch response.result {
        case let .success(list):
          completion(.success(list.users))
        case let .failure(error):
          completion(.failure(error))
        }
      }
  }

  public func moderatorsOf(subreddit: Subreddit, queue: DispatchQueue = .main,
                           completion: @escaping (Result<[Moderator], AFError>) -> Void) -> DataRequest {
    moderatorsOf(displayName: subreddit.displayName, queue: queue, completion: completion)
  }
}

public extension Subreddit {
  func moderators(queue: DispatchQueue = .main,
                  completion: @escaping (Result<[Moderator], AFError>) -> Void) -> DataRequest {
    Illithid.shared.moderatorsOf(subreddit: self, queue: queue, completion: completion)
  }
}
