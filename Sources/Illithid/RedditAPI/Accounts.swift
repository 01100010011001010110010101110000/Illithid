//
// Accounts.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 4/4/20
//

#if canImport(Combine)
  import Combine
#endif
import Foundation

import Alamofire

public enum AccountContent: String, CaseIterable {
  case overview
  case submissions
  case comments
  case upvoted
  case downvoted
  case saved
  case hidden
}

public enum AccountContentSort: String, Codable, CaseIterable, Identifiable {
  public var id: String {
    rawValue
  }

  case hot
  case new
  case top
  case controversial
}

private enum AccountRouter: URLRequestConvertible, MirrorableEnum {
  case account(username: String)
  case multireddits(username: String)
  case subscriptions

  case overview(username: String,
                sort: AccountContentSort = .new, t: TopInterval = .day,
                listingParameters: ListingParameters = .init())
  case submissions(username: String,
                   sort: AccountContentSort = .new, t: TopInterval = .day,
                   listingParameters: ListingParameters = .init())
  case comments(username: String,
                sort: AccountContentSort = .new, t: TopInterval = .day,
                listingParameters: ListingParameters = .init())
  case upvoted(username: String,
               sort: AccountContentSort = .new, t: TopInterval = .day,
               listingParameters: ListingParameters = .init())
  case downvoted(username: String,
                 sort: AccountContentSort = .new, t: TopInterval = .day,
                 listingParameters: ListingParameters = .init())
  case saved(username: String,
             sort: AccountContentSort = .new, t: TopInterval = .day,
             listingParameters: ListingParameters = .init())
  case hidden(username: String,
              sort: AccountContentSort = .new, t: TopInterval = .day,
              listingParameters: ListingParameters = .init())

  var path: String {
    switch self {
    case let .account(username):
      return "/user/\(username)/about"
    case let .comments(username, _, _, _):
      return "/user/\(username)/comments"
    case let .downvoted(username, _, _, _):
      return "/user/\(username)/downvoted"
    case let .hidden(username, _, _, _):
      return "/user/\(username)/hidden"
    case let .multireddits(username):
      return "/api/multi/user/\(username)"
    case let .overview(username, _, _, _):
      return "/user/\(username)/overview"
    case let .submissions(username, _, _, _):
      return "/user/\(username)/submitted"
    case let .saved(username, _, _, _):
      return "/user/\(username)/saved"
    case .subscriptions:
      return "/subreddits/mine/subscriber"
    case let .upvoted(username, _, _, _):
      return "/user/\(username)/upvoted"
    }
  }

  var parameters: Parameters {
    var _params = mirror.parameters.filter { $0.key != "username" }
    if let listingParams = _params.removeValue(forKey: "listingParameters") as? ListingParameters {
      _params.merge(listingParams.toParameters(), uniquingKeysWith: { $1 })
    }

    return _params
  }

  func asURLRequest() throws -> URLRequest {
    let request = try URLRequest(url: URL(string: path, relativeTo: Illithid.shared.baseURL)!, method: .get)
    return try URLEncoding.queryString.encode(request, with: parameters)
  }
}

// MARK: Account fetching

public extension Illithid {
  @discardableResult
  func fetchAccount(name: String, queue: DispatchQueue = .main,
                    completion: @escaping (Result<Account, AFError>) -> Void) -> DataRequest {
    session.request(AccountRouter.account(username: name))
      .validate()
      .responseDecodable(of: Account.self, queue: queue, decoder: decoder) { response in
        completion(response.result)
      }
  }
}

// MARK: Subscriptions

public extension Account {
  func subscribedSubreddits(queue: DispatchQueue = .main,
                            completion: @escaping (Result<[Subreddit], AFError>) -> Void) {
    let illithid: Illithid = .shared
    let subscribedSubredditsUrl = URL(string: "/subreddits/mine/subscriber", relativeTo: illithid.baseURL)!

    var subreddits: [Subreddit] = []
    illithid.readAllListings(url: subscribedSubredditsUrl, queue: queue) { result in
      switch result {
      case let .success(listings):
        // Reduce memory shuffling by preallocating capacity
        let subredditCount = listings.reduce(0) { $0 + $1.subreddits.count }
        subreddits.reserveCapacity(subredditCount)
        listings.forEach { listing in
          subreddits.append(contentsOf: listing.subreddits)
        }
        completion(.success(subreddits))
      case let .failure(error):
        completion(.failure(error))
      }
    }
  }

  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func subscribedSubreddits(queue: DispatchQueue = .main) -> AnyPublisher<[Subreddit], AFError> {
    Future { result in
      self.subscribedSubreddits(queue: queue) { subredditResult in
        result(subredditResult)
      }
    }
    .eraseToAnyPublisher()
  }

  @discardableResult
  func multireddits(queue: DispatchQueue = .main,
                    completion: @escaping (Result<[Multireddit], AFError>) -> Void) -> DataRequest {
    let illithid: Illithid = .shared

    return illithid.session.request(AccountRouter.multireddits(username: name))
      // The multireddits endpoint is not a listing
      .validate().responseDecodable(of: [Multireddit].self, queue: queue, decoder: illithid.decoder) { response in
        completion(response.result)
      }
  }

  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func multireddits(queue: DispatchQueue = .main) -> AnyPublisher<[Multireddit], AFError> {
    Future { result in
      self.multireddits(queue: queue) { multisResult in
        result(multisResult)
      }
    }.eraseToAnyPublisher()
  }

  @discardableResult
  func content(content: AccountContent, sort: AccountContentSort = .new, topInterval: TopInterval = .day,
               parameters: ListingParameters = .init(), queue: DispatchQueue = .main,
               completion: @escaping (Result<Listing, AFError>) -> Void) -> DataRequest {
    switch content {
    case .overview:
      return overview(sort: sort, topInterval: topInterval, parameters: parameters, queue: queue, completion: completion)
    case .saved:
      return savedContent(sort: sort, topInterval: topInterval, parameters: parameters, queue: queue, completion: completion)
    case .submissions:
      return submissions(sort: sort, topInterval: topInterval, parameters: parameters, queue: queue, completion: completion)
    case .comments:
      return comments(sort: sort, topInterval: topInterval, parameters: parameters, queue: queue, completion: completion)
    case .upvoted:
      return upvotedPosts(sort: sort, topInterval: topInterval, parameters: parameters, queue: queue, completion: completion)
    case .downvoted:
      return downvotedPosts(sort: sort, topInterval: topInterval, parameters: parameters, queue: queue, completion: completion)
    case .hidden:
      return hiddenPosts(sort: sort, topInterval: topInterval, parameters: parameters, queue: queue, completion: completion)
    }
  }

  @discardableResult
  func overview(sort: AccountContentSort = .new, topInterval: TopInterval = .day,
                parameters: ListingParameters = .init(), queue: DispatchQueue = .main,
                completion: @escaping (Result<Listing, AFError>) -> Void) -> DataRequest {
    let illithid: Illithid = .shared
    let request = AccountRouter.overview(username: name, sort: sort, t: topInterval,
                                         listingParameters: parameters)

    return illithid.readListing(request: request, queue: queue, completion: completion)
  }

  @discardableResult
  func comments(sort: AccountContentSort = .new, topInterval: TopInterval = .day,
                parameters: ListingParameters = .init(), queue: DispatchQueue = .main,
                completion: @escaping (Result<Listing, AFError>) -> Void) -> DataRequest {
    let illithid: Illithid = .shared
    let request = AccountRouter.comments(username: name, sort: sort, t: topInterval,
                                         listingParameters: parameters)

    return illithid.readListing(request: request, queue: queue, completion: completion)
  }

  @discardableResult
  func submissions(sort: AccountContentSort = .new, topInterval: TopInterval = .day,
                   parameters: ListingParameters = .init(), queue: DispatchQueue = .main,
                   completion: @escaping (Result<Listing, AFError>) -> Void) -> DataRequest {
    let illithid: Illithid = .shared
    let request = AccountRouter.submissions(username: name, sort: sort, t: topInterval,
                                            listingParameters: parameters)

    return illithid.readListing(request: request, queue: queue, completion: completion)
  }

  @discardableResult
  func upvotedPosts(sort: AccountContentSort = .new, topInterval: TopInterval = .day,
                    parameters: ListingParameters = .init(), queue: DispatchQueue = .main,
                    completion: @escaping (Result<Listing, AFError>) -> Void) -> DataRequest {
    let illithid: Illithid = .shared
    let request = AccountRouter.upvoted(username: name, sort: sort, t: topInterval,
                                        listingParameters: parameters)

    return illithid.readListing(request: request, queue: queue, completion: completion)
  }

  @discardableResult
  func downvotedPosts(sort: AccountContentSort = .new, topInterval: TopInterval = .day,
                      parameters: ListingParameters = .init(), queue: DispatchQueue = .main,
                      completion: @escaping (Result<Listing, AFError>) -> Void) -> DataRequest {
    let illithid: Illithid = .shared
    let request = AccountRouter.downvoted(username: name, sort: sort, t: topInterval,
                                          listingParameters: parameters)

    return illithid.readListing(request: request, queue: queue, completion: completion)
  }

  @discardableResult
  func hiddenPosts(sort: AccountContentSort = .new, topInterval: TopInterval = .day,
                   parameters: ListingParameters = .init(), queue: DispatchQueue = .main,
                   completion: @escaping (Result<Listing, AFError>) -> Void) -> DataRequest {
    let illithid: Illithid = .shared
    let request = AccountRouter.hidden(username: name, sort: sort, t: topInterval,
                                       listingParameters: parameters)

    return illithid.readListing(request: request, queue: queue, completion: completion)
  }

  @discardableResult
  func savedContent(sort: AccountContentSort = .new, topInterval: TopInterval = .day, context _: Int = 2,
                    parameters: ListingParameters = .init(), queue: DispatchQueue = .main,
                    completion: @escaping (Result<Listing, AFError>) -> Void) -> DataRequest {
    let illithid: Illithid = .shared
    let request = AccountRouter.saved(username: name, sort: sort, t: topInterval,
                                      listingParameters: parameters)

    return illithid.readListing(request: request, queue: queue, completion: completion)
  }
}

public extension Account {
  @discardableResult
  static func fetch(username: String, queue: DispatchQueue = .main,
                    completion: @escaping (Result<Account, AFError>) -> Void) -> DataRequest {
    Illithid.shared.fetchAccount(name: username, queue: queue) { result in
      completion(result)
    }
  }
}
