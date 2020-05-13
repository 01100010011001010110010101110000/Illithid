//
// Actions.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 4/4/20
//

import Foundation

import Alamofire

enum ActionRouter: URLRequestConvertible, MirrorableEnum {
  case vote(id: Fullname, dir: VoteDirection)
  case save(id: Fullname)
  case unsave(id: Fullname)
  case changeSubscription(sr: [Subreddit], action: SubscribeAction)

  private var path: String {
    switch self {
    case .vote:
      return "/api/vote"
    case .save:
      return "/api/save"
    case .unsave:
      return "/api/unsave"
    case .changeSubscription:
      return "/api/subscribe"
    }
  }

  var parameters: Parameters {
    switch self {
    case let .vote(id, dir):
      return [
        "id": id,
        "dir": dir.rawValue
      ]
    case let .changeSubscription(sr, action):
      return [
        "sr": sr.map { $0.name }.joined(separator: ","),
        "action": action.rawValue
      ]
    default:
      return mirror.parameters
    }
  }

  func asURLRequest() throws -> URLRequest {
    let request = try URLRequest(url: URL(string: path, relativeTo: Illithid.shared.baseURL)!, method: .post)
    return try URLEncoding.httpBody.encode(request, with: parameters)
  }
}

enum SubscribeAction: String, Codable {
  case subscribe = "sub"
  case unsubscribe = "unsub"
}

internal extension Illithid {
  @discardableResult
  func vote(fullname: Fullname, direction: VoteDirection, queue: DispatchQueue = .main,
            completion: @escaping (Result<Data, AFError>) -> Void) -> DataRequest {
    session.request(ActionRouter.vote(id: fullname, dir: direction))
      .validate()
      .responseData(queue: queue) { response in
        completion(response.result)
      }
  }

  @discardableResult
  func save(fullname: Fullname, queue: DispatchQueue = .main,
            completion: @escaping (Result<Data, AFError>) -> Void) -> DataRequest {
    session.request(ActionRouter.save(id: fullname))
      .validate()
      .responseData(queue: queue) { response in
        completion(response.result)
      }
  }

  @discardableResult
  func unsave(fullname: Fullname, queue: DispatchQueue = .main,
              completion: @escaping (Result<Data, AFError>) -> Void) -> DataRequest {
    session.request(ActionRouter.unsave(id: fullname))
      .validate()
      .responseData(queue: queue) { response in
        completion(response.result)
      }
  }

  @discardableResult
  func changeSubscription(of subreddits: [Subreddit], action: SubscribeAction, queue: DispatchQueue = .main,
                          completion: @escaping (Result<Data, AFError>) -> Void) -> DataRequest {
    session.request(ActionRouter.changeSubscription(sr: subreddits, action: action))
      .validate()
      .responseData(queue: queue) { response in
        completion(response.result)
      }
  }

  @discardableResult
  func changeSubscription(of subreddit: Subreddit, action: SubscribeAction, queue: DispatchQueue = .main,
                          completion: @escaping (Result<Data, AFError>) -> Void) -> DataRequest {
    changeSubscription(of: [subreddit], action: action, queue: queue, completion: completion)
  }
}
