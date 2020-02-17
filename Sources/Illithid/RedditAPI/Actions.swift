//
// Actions.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 02/02/2020
//

import Foundation

import Alamofire

internal extension Illithid {
  func vote(fullname: Fullname, direction: VoteDirection, queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) {
    let voteUrl = URL(string: "/api/vote", relativeTo: baseURL)!
    let voteParameters: [String: Any] = [
      "id": fullname,
      "dir": direction.rawValue,
    ]
    session.request(voteUrl, method: .post, parameters: voteParameters, encoding: URLEncoding(destination: .httpBody)).validate().responseData(queue: queue) { response in
      completion(response.result)
    }
  }

  func save(fullname: Fullname, queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) -> Void {
    let saveUrl = URL(string: "/api/save", relativeTo: baseURL)!
    let saveParameters: [String: Any] = [
      "id": fullname
    ]
    session.request(saveUrl, method: .post, parameters: saveParameters, encoding: URLEncoding(destination: .httpBody)).validate().responseData(queue: queue) { response in
      completion(response.result)
    }
  }

  func unsave(fullname: Fullname, queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) -> Void {
    let saveUrl = URL(string: "/api/unsave", relativeTo: baseURL)!
    let saveParameters: [String: Any] = [
      "id": fullname
    ]
    session.request(saveUrl, method: .post, parameters: saveParameters, encoding: URLEncoding(destination: .httpBody)).validate().responseData(queue: queue) { response in
      completion(response.result)
    }
  }

  func changeSubscription(of subreddits: [Subreddit], isSubscribed: Bool, queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) {
    let subscribeUrl = URL(string: "/api/subscribe", relativeTo: baseURL)!
    let action = isSubscribed ? "sub" : "unsub"
    let subscribeParameters = [
      "action": action,
      "sr": subreddits.map { $0.name }.joined(separator: ",")
    ]

    session.request(subscribeUrl, method: .post, parameters: subscribeParameters, encoding: URLEncoding(destination: .httpBody)).validate().responseData(queue: queue) { response in
      completion(response.result)
    }
  }

  func changeSubscription(of subreddit: Subreddit, isSubscribed: Bool, queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) {
    changeSubscription(of: [subreddit], isSubscribed: isSubscribed, queue: queue, completion: completion)
  }
}
