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

// MARK: Account fetching

public extension Illithid {
  func fetchAccount(name: String, completion: @escaping (Swift.Result<Account, Error>) -> Void) {
    let accountUrl = URL(string: "/user/\(name)/about", relativeTo: baseURL)!

    session.request(accountUrl, method: .get).validate().responseData { response in
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
    let multiredditsUrl = URL(string: "/api/multi/user/\(self.name)", relativeTo: illithid.baseURL)!

    illithid.session.request(multiredditsUrl).validate().responseData { response in
      switch response.result {
      case let .success(data):
        let multis = try! illithid.decoder.decode([Multireddit].self, from: data)
        completion(multis)
      case let .failure(error):
        return
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
}

public extension Account {
  static func fetch(name: String, completion: @escaping (Swift.Result<Account, Error>) -> Void) {
    Illithid.shared.fetchAccount(name: name) { result in
      completion(result)
    }
  }
}
