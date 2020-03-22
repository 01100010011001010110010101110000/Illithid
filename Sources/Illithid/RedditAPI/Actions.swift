//
// Actions.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 3/21/20
//

import Foundation

import Alamofire

internal extension Illithid {
  @discardableResult
  func vote(fullname: Fullname, direction: VoteDirection, queue: DispatchQueue = .main,
            completion: @escaping (Result<Data, AFError>) -> Void) -> DataRequest {
    let voteUrl = URL(string: "/api/vote", relativeTo: baseURL)!
    let voteParameters: [String: Any] = [
      "id": fullname,
      "dir": direction.rawValue
    ]

    return session.request(voteUrl, method: .post, parameters: voteParameters, encoding: URLEncoding(destination: .httpBody)).validate().responseData(queue: queue) { response in
      completion(response.result)
    }
  }

  @discardableResult
  func save(fullname: Fullname, queue: DispatchQueue = .main,
            completion: @escaping (Result<Data, AFError>) -> Void) -> DataRequest {
    let saveUrl = URL(string: "/api/save", relativeTo: baseURL)!
    let saveParameters: [String: Any] = [
      "id": fullname
    ]

    return session.request(saveUrl, method: .post, parameters: saveParameters, encoding: URLEncoding(destination: .httpBody)).validate().responseData(queue: queue) { response in
      completion(response.result)
    }
  }

  @discardableResult
  func unsave(fullname: Fullname, queue: DispatchQueue = .main,
              completion: @escaping (Result<Data, AFError>) -> Void) -> DataRequest {
    let saveUrl = URL(string: "/api/unsave", relativeTo: baseURL)!
    let saveParameters: [String: Any] = [
      "id": fullname
    ]

    return session.request(saveUrl, method: .post, parameters: saveParameters, encoding: URLEncoding(destination: .httpBody)).validate().responseData(queue: queue) { response in
      completion(response.result)
    }
  }

  @discardableResult
  func changeSubscription(of subreddits: [Subreddit], isSubscribed: Bool, queue: DispatchQueue = .main,
                          completion: @escaping (Result<Data, AFError>) -> Void) -> DataRequest {
    let subscribeUrl = URL(string: "/api/subscribe", relativeTo: baseURL)!
    let action = isSubscribed ? "sub" : "unsub"
    let subscribeParameters = [
      "action": action,
      "sr": subreddits.map { $0.name }.joined(separator: ",")
    ]

    return session.request(subscribeUrl, method: .post, parameters: subscribeParameters, encoding: URLEncoding(destination: .httpBody)).validate().responseData(queue: queue) { response in
      completion(response.result)
    }
  }

  @discardableResult
  func changeSubscription(of subreddit: Subreddit, isSubscribed: Bool, queue: DispatchQueue = .main,
                          completion: @escaping (Result<Data, AFError>) -> Void) -> DataRequest {
    changeSubscription(of: [subreddit], isSubscribed: isSubscribed, queue: queue, completion: completion)
  }
}
