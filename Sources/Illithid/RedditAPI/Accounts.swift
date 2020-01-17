//
// Accounts.swift
// Copyright (c) 2019 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 12/24/19
//

#if canImport(Combine)
  import Combine
#endif
import Foundation

import Alamofire

fileprivate enum AccountRouter: URLRequestConvertible {
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
    return try URLRequest(url: URL(string: path, relativeTo: Illithid.shared.baseURL)!,
                      method: .get)
  }
}

// MARK: Account fetching

public extension Illithid {
  func fetchAccount(name: String, completion: @escaping (Swift.Result<Account, Error>) -> Void) {
    session.request(AccountRouter.account(username: name))
      .validate().responseData { response in
      switch response.result {
      case .success(let data):
        do {
          let account = try self.decoder.decode(Account.self, from: data)
          completion(.success(account))
        } catch {
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}

// MARK: Subscriptions

public extension Account {
  func subscribedSubreddits(_ completion: @escaping ([Subreddit]) -> Void) {
    let illithid: Illithid = .shared
    let subscribedSubredditsUrl = URL(string: "/subreddits/mine/subscriber", relativeTo: illithid.baseURL)!

    var subreddits: [Subreddit] = []
    illithid.readAllListings(url: subscribedSubredditsUrl) { listings in
      // Reduce memory shuffling by preallocating capacity
      let subredditCount = listings.reduce(0) { $0 + $1.subreddits.count }
      subreddits.reserveCapacity(subredditCount)
      listings.forEach { listing in
        subreddits.append(contentsOf: listing.subreddits)
      }
      completion(subreddits)
    }
  }

  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func subscribedSubreddits() -> AnyPublisher<[Subreddit], Error> {
    Future { result in
      self.subscribedSubreddits { subreddits in
        result(.success(subreddits))
      }
    }.eraseToAnyPublisher()
  }

  func multireddits(_ completion: @escaping ([Multireddit]) -> Void) {
    let illithid: Illithid = .shared

    illithid.session.request(AccountRouter.multireddits(username: self.name))
      // The multireddits endpoint is not a listing
      .validate().responseData { response in
      switch response.result {
      case let .success(data):
        let multis = try! illithid.decoder.decode([Multireddit].self, from: data)
        completion(multis)
      case let .failure(error):
        illithid.logger.errorMessage("Failed to load multireddits: \(error)")
      }
    }
  }

  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func multireddits() -> AnyPublisher<[Multireddit], Error> {
    Future { result in
      self.multireddits { multis in
        result(.success(multis))
      }
    }.eraseToAnyPublisher()
  }

  func overview(_ completion: @escaping (Swift.Result<Listing, Error>) -> Void) {
    let illithid: Illithid = .shared

    illithid.session.request(AccountRouter.overview(username: self.name))
      .validate().responseListing { response in
      switch response.result {
      case let .success(listing):
        return completion(.success(listing))
      case let .failure(error):
        completion(.failure(error))
      }
    }
  }

  func comments(_ completion: @escaping (Swift.Result<[Comment], Error>) -> Void) {
    let illithid: Illithid = .shared

    illithid.session.request(AccountRouter.comments(username: self.name))
      .validate().responseListing { response in
      switch response.result {
      case let .success(listing):
        return completion(.success(listing.comments))
      case let .failure(error):
        completion(.failure(error))
      }
    }
  }

  func submittedPosts(_ completion: @escaping (Swift.Result<[Post], Error>) -> Void) {
    let illithid: Illithid = .shared

    illithid.session.request(AccountRouter.posts(username: self.name))
      .validate().responseListing { response in
      switch response.result {
      case let .success(listing):
        return completion(.success(listing.posts))
      case let .failure(error):
        completion(.failure(error))
      }
    }
  }

  func upvotedPosts(_ completion: @escaping (Swift.Result<[Post], Error>) -> Void) {
    let illithid: Illithid = .shared

    illithid.session.request(AccountRouter.upvoted(username: self.name))
      .validate().responseListing { response in
      switch response.result {
      case let .success(listing):
        return completion(.success(listing.posts))
      case let .failure(error):
        completion(.failure(error))
      }
    }
  }

  func downvotedPosts(_ completion: @escaping (Swift.Result<[Post], Error>) -> Void) {
    let illithid: Illithid = .shared

    illithid.session.request(AccountRouter.downvoted(username: self.name))
      .validate().responseListing { response in
      switch response.result {
      case let .success(listing):
        return completion(.success(listing.posts))
      case let .failure(error):
        completion(.failure(error))
      }
    }
  }

  func hiddenPosts(_ completion: @escaping (Swift.Result<[Post], Error>) -> Void) {
    let illithid: Illithid = .shared

    illithid.session.request(AccountRouter.hidden(username: self.name))
      .validate().responseListing { response in
      switch response.result {
      case let .success(listing):
        return completion(.success(listing.posts))
      case let .failure(error):
        completion(.failure(error))
      }
    }
  }

  func savedContent(_ completion: @escaping (Swift.Result<Listing, Error>) -> Void) {
    let illithid: Illithid = .shared

    illithid.session.request(AccountRouter.saved(username: self.name))
      .validate().responseListing { response in
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
  static func fetch(name: String, completion: @escaping (Swift.Result<Account, Error>) -> Void) {
    Illithid.shared.fetchAccount(name: name) { result in
      completion(result)
    }
  }
}
