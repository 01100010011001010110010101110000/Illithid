//
// Actions.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 02/02/2020
//

import Foundation

import Alamofire

internal extension Illithid {
  func vote(fullname: Fullname, direction: VoteDirection, queue: DispatchQueue? = nil, completion: @escaping (Swift.Result<Data, Error>) -> Void) {
    let voteUrl = URL(string: "/api/vote", relativeTo: baseURL)!
    let voteParameters: [String: Any] = [
      "id": fullname,
      "dir": direction.rawValue,
    ]
    session.request(voteUrl, method: .post, parameters: voteParameters, encoding: URLEncoding(destination: .httpBody)).validate().responseData(queue: queue) { response in
      completion(Swift.Result(from: response.result))
    }
  }

  func save(fullname: Fullname, queue: DispatchQueue? = nil, completion: @escaping (Swift.Result<Data, Error>) -> Void) -> Void {
    let saveUrl = URL(string: "/api/save", relativeTo: baseURL)!
    let saveParameters: [String: Any] = [
      "id": fullname
    ]
    session.request(saveUrl, method: .post, parameters: saveParameters, encoding: URLEncoding(destination: .httpBody)).validate().responseData { response in
      completion(Swift.Result(from: response.result))
    }
  }

  func unsave(fullname: Fullname, queue: DispatchQueue? = nil, completion: @escaping (Swift.Result<Data, Error>) -> Void) -> Void {
    let saveUrl = URL(string: "/api/unsave", relativeTo: baseURL)!
    let saveParameters: [String: Any] = [
      "id": fullname
    ]
    session.request(saveUrl, method: .post, parameters: saveParameters, encoding: URLEncoding(destination: .httpBody)).validate().responseData { response in
      completion(Swift.Result(from: response.result))
    }
  }
}
