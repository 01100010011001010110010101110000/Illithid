//
// Multireddits.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 12/24/19
//

import Alamofire

import Foundation

extension Multireddit: PostProvider {
  @discardableResult
  public func posts(sortBy sort: PostSort, location: Location?, topInterval: TopInterval?,
                    parameters: ListingParameters, queue: DispatchQueue = .main,
                    completion: @escaping (Result<Listing, AFError>) -> Void) -> DataRequest {
    Illithid.shared.fetchPosts(for: self, sortBy: sort, location: location,
                               topInterval: topInterval, params: parameters) { result in
      completion(result)
    }
  }
}

public extension Illithid {
  @discardableResult
  func addSubreddit(to multireddit: Multireddit, subreddit: Subreddit,
                    completion: @escaping (Result<Data?, AFError>) -> Void) -> DataRequest {
    let updateUrl = URL(string: "/api/multi\(multireddit.path.absoluteString)r/\(subreddit.displayName)", relativeTo: baseURL)!

    // The reddit API requires that `model` be JSON, but that the whole payload be URL encoded
    let updateModel = [
      "model": "{\"name\": \"\(subreddit.displayName)\"}"
    ]

    return session.request(updateUrl, method: .put, parameters: updateModel, encoding: URLEncoding(destination: .httpBody)).validate().response { response in
      completion(response.result)
    }
  }

  @discardableResult
  func removeSubreddit(from multireddit: Multireddit, subreddit: Multireddit.MultiSubreddit,
                       completion: @escaping (Result<Data?, AFError>) -> Void) -> DataRequest {
    let deleteUrl = URL(string: "/api/multi/\(multireddit.path.absoluteString)/r/\(subreddit.name)", relativeTo: baseURL)!

    return session.request(deleteUrl, method: .delete).validate().response { response in
      completion(response.result)
    }
  }
}

public extension Multireddit {
  @discardableResult
  func removeSubreddit(_ subreddit: MultiSubreddit,
                       completion: @escaping (Result<Data?, AFError>) -> Void) -> DataRequest {
    Illithid.shared.removeSubreddit(from: self, subreddit: subreddit, completion: completion)
  }

  @discardableResult
  func addSubreddit(_ subreddit: Subreddit,
                    completion: @escaping (Result<Data?, AFError>) -> Void) -> DataRequest {
    Illithid.shared.addSubreddit(to: self, subreddit: subreddit, completion: completion)
  }
}

public extension Multireddit {
  @discardableResult
  static func fetch(user: String, name: String, queue: DispatchQueue = .main,
             completion: @escaping (Result<Multireddit, AFError>) -> Void) -> DataRequest {
    let multiUrl = URL(string: "/api/multi/user/\(user)/m/\(name)",
      relativeTo: Illithid.shared.baseURL)!
    return Illithid.shared.session.request(multiUrl, method: .get)
      .validate()
      .responseDecodable(of: Multireddit.self, queue: queue, decoder: Illithid.shared.decoder) { response in
        completion(response.result)
    }
  }
}
