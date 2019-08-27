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
import AlamofireImage
import Willow
import SwiftyJSON

public extension RedditClientBroker {
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
      .validate().responseData { response in
        switch response.result {
        case let .success(data):
          do {
            let list = try self.decoder.decode(Listing.self, from: data)
            completion(list)
          } catch let error as DecodingError {
            let json = try? JSON(data: data).rawString(options: [.sortedKeys, .prettyPrinted])
            let response = json ?? String(data: data, encoding: .utf8) ?? "All decoding attempts failed"
            self.logger.errorMessage("Error decoding subreddits list: \(error)")
            self.logger.errorMessage("JSON data response: \(response)")
          } catch {
            let json = try? JSON(data: data).rawString(options: [.sortedKeys, .prettyPrinted])
            let response = json ?? String(data: data, encoding: .utf8) ?? "All decoding attempts failed"
            self.logger.errorMessage("Unknown error decoding data: \(error)")
            self.logger.errorMessage("JSON data response: \(response)")
          }
        case let .failure(error):
          self.logger.errorMessage("Failed to call subreddits API endpoint: \(error)")
        }
      }
  }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Subreddit {
  static func fetch(name: Fullname, client: RedditClientBroker) -> AnyPublisher<Subreddit, Error> {
    client.info(name: name)
      .compactMap { listing in
        return listing.subreddits.last
    }.eraseToAnyPublisher()
  }
}

public extension Post {
  static func fetch(name: Fullname, client: RedditClientBroker, completion: @escaping (Result<Subreddit>) -> Void) {
    client.info(name: name) { result in
      switch result {
      case .success(let listing):
        guard let subreddit = listing.subreddits.last else {
          completion(.failure(RedditClientBroker.NotFound(lookingFor: name)))
          return
        }
        completion(.success(subreddit))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}
