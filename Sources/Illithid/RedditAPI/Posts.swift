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
#if canImport(SwiftUI)
import SwiftUI
#endif
import Foundation

import Alamofire
import AlamofireImage
import Willow
import SwiftyJSON

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
      .responseData { response in
        switch response.result {
        case let .success(data):
          do {
            let list = try self.decoder.decode(Listing.self, from: data)
            completion(list)
          } catch let error as DecodingError {
            let json = try? JSON(data: data).rawString(options: [.sortedKeys, .prettyPrinted])
            let response = json ?? String(data: data, encoding: .utf8) ?? "All decoding attempts failed"
            self.logger.errorMessage("Error decoding post list: \(error)")
            self.logger.errorMessage("JSON data response: \(response)")
          } catch {
            let json = try? JSON(data: data).rawString(options: [.sortedKeys, .prettyPrinted])
            let response = json ?? String(data: data, encoding: .utf8) ?? "All decoding attempts failed"
            self.logger.errorMessage("Error decoding post list: \(error)")
            self.logger.errorMessage("JSON data response: \(response)")
          }
        case let .failure(error):
          self.logger.errorMessage("Failed to call posts API endpoint: \(error)")
        }
    }
  }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Post {
  static func fetch(name: Fullname, client: Illithid) -> AnyPublisher<Post, Error> {
    client.info(name: name)
      .compactMap { listing in
        return listing.posts.last
    }.eraseToAnyPublisher()
  }
}

public extension Post {
  static func fetch(name: Fullname, client: Illithid, completion: @escaping (Result<Post>) -> Void) {
    client.info(name: name) { result in
      switch result {
      case .success(let listing):
        guard let post = listing.posts.last else {
          completion(.failure(Illithid.NotFound(lookingFor: name)))
          return
        }
        completion(.success(post))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Post {
  func content() -> some View {
    switch postHint {
    case .`self`:
      return GroupBox {
        Text(selftext)
      }.eraseToAnyView()
    case .link:
      return EmptyView().eraseToAnyView()
    case .image:
      return EmptyView().eraseToAnyView()
    case .hostedVideo:
      return EmptyView().eraseToAnyView()
    case .richVideo:
      return EmptyView().eraseToAnyView()
    default:
      // If there is no hint, assume self post. Later we will attempt to guess the post type by other available attributes
      return GroupBox {
        Text(selftext)
      }.eraseToAnyView()
    }
  }
}
