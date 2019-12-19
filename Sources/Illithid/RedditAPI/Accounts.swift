//
//  Accounts.swift
//
//
//  Created by Tyler Gregory on 11/20/19.
//

#if canImport(Combine)
  import Combine
#endif
import Foundation

import Alamofire

// TODO: Ensure these methods switch the user context to their user prior to issuing these requests

public extension RedditAccount {
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
    let multiredditsUrl = URL(string: "/api/multi/mine", relativeTo: illithid.baseURL)!

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
