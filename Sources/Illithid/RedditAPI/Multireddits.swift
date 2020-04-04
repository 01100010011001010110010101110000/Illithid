//
// Multireddits.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 3/21/20
//

import Alamofire

import Foundation

enum MultiredditRouter: URLRequestConvertible {
  case userMulti(username: String, multiName: String)
  case addSubreddit(path: URL, name: String)
  case removeSubreddit(path: URL, name: String)

  private var baseUrl: URL {
    Illithid.shared.baseURL
  }

  private var path: URL {
    switch self {
    case let .userMulti(username, multiName):
      return URL(string: "/api/multi/user/\(username)/m/\(multiName)",
                 relativeTo: baseUrl)!
    case let .addSubreddit(path, name):
      return URL(string: "/api/multi\(path.absoluteString)r/\(name)", relativeTo: baseUrl)!
    case let .removeSubreddit(path, name):
      return URL(string: "/api/multi/\(path.absoluteString)/r/\(name)", relativeTo: baseUrl)!
    }
  }

  private var parameters: Parameters {
    switch self {
    case .userMulti:
      return [:]
    case let .addSubreddit(_, name):
      // The reddit API requires that `model` be JSON, but that the whole payload be URL encoded
      return [
        "model": "{\"name\": \"\(name)\"}"
      ]
    case .removeSubreddit:
      return [:]
    }
  }

  func asURLRequest() throws -> URLRequest {
    switch self {
    case .userMulti:
      return URLRequest(url: path)
    case .addSubreddit:
      let request = try URLRequest(url: path, method: .put)
      return try URLEncoding.httpBody.encode(request, with: parameters)
    case .removeSubreddit:
      return try URLRequest(url: path, method: .delete)
    }
  }
}

extension Multireddit: PostProvider {
  public var isNsfw: Bool {
    over18 ?? false
  }

  @discardableResult
  public func posts(sortBy sort: PostSort, location: Location?, topInterval: TopInterval?,
                    parameters: ListingParameters, queue _: DispatchQueue = .main,
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
    session.request(MultiredditRouter.addSubreddit(path: multireddit.path, name: subreddit.displayName))
      .validate()
      .response { response in
        completion(response.result)
      }
  }

  @discardableResult
  func removeSubreddit(from multireddit: Multireddit, subreddit: Multireddit.MultiSubreddit,
                       completion: @escaping (Result<Data?, AFError>) -> Void) -> DataRequest {
    session.request(MultiredditRouter.removeSubreddit(path: multireddit.path, name: subreddit.name))
      .validate()
      .response { response in
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
    Illithid.shared.session.request(MultiredditRouter.userMulti(username: user, multiName: name))
      .validate()
      .responseDecodable(of: Multireddit.self, queue: queue, decoder: Illithid.shared.decoder) { response in
        completion(response.result)
      }
  }
}
