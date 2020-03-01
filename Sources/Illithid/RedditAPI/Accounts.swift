//
// Accounts.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 12/24/19
//

#if canImport(Combine)
  import Combine
#endif
import Foundation

import Alamofire

private enum AccountRouter: URLRequestConvertible {
  case account(username: String)
  case comments(username: String)
  case downvoted(username: String)
  case hidden(username: String)
  case multireddits(username: String)
  case overview(username: String)
  case posts(username: String)
  case saved(username: String)
  case subscriptions
  case upvoted(username: String)

  var path: String {
    switch self {
    case let .account(username):
      return "/user/\(username)/about"
    case let .comments(username):
      return "/user/\(username)/comments"
    case let .downvoted(username):
      return "/user/\(username)/downvoted"
    case let .hidden(username):
      return "/user/\(username)/hidden"
    case let .multireddits(username):
      return "/api/multi/user/\(username)"
    case let .overview(username):
      return "/user/\(username)/overview"
    case let .posts(username):
      return "/user/\(username)/submitted"
    case let .saved(username):
      return "/user/\(username)/saved"
    case .subscriptions:
      return "/subreddits/mine/subscriber"
    case let .upvoted(username):
      return "/user/\(username)/upvoted"
    }
  }

  func asURLRequest() throws -> URLRequest {
    try URLRequest(url: URL(string: path, relativeTo: Illithid.shared.baseURL)!,
                   method: .get)
  }
}

// MARK: Account fetching

public extension Illithid {
  @discardableResult
  func fetchAccount(name: String, queue: DispatchQueue = .main,
                    completion: @escaping (Result<Account, AFError>) -> Void) -> DataRequest {
    return session.request(AccountRouter.account(username: name))
      .validate().responseData(queue: queue) { response in
        switch response.result {
        case let .success(data):
          do {
            let account = try self.decoder.decode(Account.self, from: data)
            completion(.success(account))
          } catch {
            completion(.failure(AFError.responseSerializationFailed(reason: .decodingFailed(error: error))))
          }
        case let .failure(error):
          completion(.failure(error))
        }
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
    .validate().responseData(queue: queue) { response in
        switch response.result {
        case let .success(data):
          let multis = try! illithid.decoder.decode([Multireddit].self, from: data)
          completion(.success(multis))
        case let .failure(error):
          illithid.logger.errorMessage("Failed to load multireddits: \(error)")
          completion(.failure(error))
        }
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
  func overview(queue: DispatchQueue = .main,
                completion: @escaping (Result<Listing, AFError>) -> Void) -> DataRequest {
    let illithid: Illithid = .shared

    return illithid.session.request(AccountRouter.overview(username: name))
      .validate().responseDecodable(of: Listing.self, queue: queue, decoder: illithid.decoder) { response in
        completion(response.result)
      }
  }

  @discardableResult
  func comments(queue: DispatchQueue = .main,
                completion: @escaping (Result<[Comment], AFError>) -> Void) -> DataRequest {
    let illithid: Illithid = .shared

    return illithid.session.request(AccountRouter.comments(username: name))
      .validate().responseDecodable(of: Listing.self, queue: queue, decoder: illithid.decoder) { response in
        switch response.result {
        case let .success(listing):
          return completion(.success(listing.comments))
        case let .failure(error):
          completion(.failure(error))
        }
      }
  }

  @discardableResult
  func submittedPosts(queue: DispatchQueue = .main,
                      completion: @escaping (Result<[Post], AFError>) -> Void) -> DataRequest {
    let illithid: Illithid = .shared

    return illithid.session.request(AccountRouter.posts(username: name))
      .validate().responseDecodable(of: Listing.self, queue: queue, decoder: illithid.decoder) { response in
        switch response.result {
        case let .success(listing):
          return completion(.success(listing.posts))
        case let .failure(error):
          completion(.failure(error))
        }
      }
  }

  @discardableResult
  func upvotedPosts(queue: DispatchQueue = .main,
                    completion: @escaping (Result<[Post], AFError>) -> Void) -> DataRequest {
    let illithid: Illithid = .shared

    return illithid.session.request(AccountRouter.upvoted(username: name))
      .validate().responseDecodable(of: Listing.self, queue: queue, decoder: illithid.decoder) { response in
        switch response.result {
        case let .success(listing):
          return completion(.success(listing.posts))
        case let .failure(error):
          completion(.failure(error))
        }
      }
  }

  @discardableResult
  func downvotedPosts(queue: DispatchQueue = .main,
                      completion: @escaping (Result<[Post], AFError>) -> Void) -> DataRequest {
    let illithid: Illithid = .shared

    return illithid.session.request(AccountRouter.downvoted(username: name))
      .validate().responseDecodable(of: Listing.self, queue: queue, decoder: illithid.decoder) { response in
        switch response.result {
        case let .success(listing):
          return completion(.success(listing.posts))
        case let .failure(error):
          completion(.failure(error))
        }
      }
  }

  @discardableResult
  func hiddenPosts(queue: DispatchQueue = .main,
                   completion: @escaping (Result<[Post], AFError>) -> Void) -> DataRequest {
    let illithid: Illithid = .shared

    return illithid.session.request(AccountRouter.hidden(username: name))
      .validate().responseDecodable(of: Listing.self, queue: queue, decoder: illithid.decoder) { response in
        switch response.result {
        case let .success(listing):
          return completion(.success(listing.posts))
        case let .failure(error):
          completion(.failure(error))
        }
      }
  }

  @discardableResult
  func savedContent(queue: DispatchQueue = .main,
                    completion: @escaping (Result<Listing, AFError>) -> Void) -> DataRequest {
    let illithid: Illithid = .shared

    return illithid.session.request(AccountRouter.saved(username: name))
      .validate().responseDecodable(of: Listing.self, queue: queue, decoder: illithid.decoder) { response in
        switch response.result {
        case let .success(listing):
          return completion(.success(listing))
        case let .failure(error):
          completion(.failure(error))
        }
      }
  }
}

public extension Account {
  @discardableResult
  static func fetch(name: String, queue: DispatchQueue = .main,
                    completion: @escaping (Result<Account, AFError>) -> Void) -> DataRequest {
    return Illithid.shared.fetchAccount(name: name, queue: queue) { result in
      completion(result)
    }
  }
}
