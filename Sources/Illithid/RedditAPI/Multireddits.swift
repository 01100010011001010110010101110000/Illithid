//
// Multireddits.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 12/24/19
//

import Alamofire

import Foundation

extension Multireddit: PostsProvider {
  public func posts(sortBy sort: PostSort, location: Location?, topInterval: TopInterval?,
                    parameters: ListingParameters, queue: DispatchQueue = .main,
                    completion: @escaping (Result<Listing, AFError>) -> Void) {
    Illithid.shared.fetchPosts(for: self, sortBy: sort, location: location,
                               topInterval: topInterval, params: parameters) { result in
      completion(result)
    }
  }
}

public extension Illithid {
  func addSubreddit(to multireddit: Multireddit, subreddit: Subreddit, completion: @escaping (Result<Data?, AFError>) -> Void) {
    let updateUrl = URL(string: "/api/multi\(multireddit.path.absoluteString)r/\(subreddit.displayName)", relativeTo: baseURL)!

    // The reddit API requires that `model` be JSON, but that the whole payload be URL encoded
    let updateModel = [
      "model": "{\"name\": \"\(subreddit.displayName)\"}"
    ]

    session.request(updateUrl, method: .put, parameters: updateModel, encoding: URLEncoding(destination: .httpBody)).validate().response { response in
      completion(response.result)
    }
  }

  func removeSubreddit(from multireddit: Multireddit, subreddit: Multireddit.MultiSubreddit, completion: @escaping (Result<Data?, AFError>) -> Void) {
    let deleteUrl = URL(string: "/api/multi/\(multireddit.path.absoluteString)/r/\(subreddit.name)", relativeTo: baseURL)!

    session.request(deleteUrl, method: .delete).validate().response { response in
      completion(response.result)
    }
  }
}

public extension Multireddit {
  func removeSubreddit(_ subreddit: MultiSubreddit, completion: @escaping (Result<Data?, AFError>) -> Void) {
    Illithid.shared.removeSubreddit(from: self, subreddit: subreddit, completion: completion)
  }

  func addSubreddit(_ subreddit: Subreddit, completion: @escaping (Result<Data?, AFError>) -> Void) {
    Illithid.shared.addSubreddit(to: self, subreddit: subreddit, completion: completion)
  }
}
