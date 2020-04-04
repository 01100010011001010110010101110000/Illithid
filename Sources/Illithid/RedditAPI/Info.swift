//
// Info.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 4/4/20
//

#if canImport(Combine)
  import Combine
#endif
import Foundation

import Alamofire

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Illithid {
  func info(names: [Fullname], queue: DispatchQueue = .main) -> AnyPublisher<Listing, Error> {
    let endpoint = URL(string: "/api/info", relativeTo: baseURL)!
    let infoParameters: Parameters = ["id": names.joined(separator: ",")]

    return session.requestPublisher(url: endpoint, method: .get, parameters: infoParameters, queue: queue)
      .decode(type: Listing.self, decoder: decoder)
      .eraseToAnyPublisher()
  }

  func info(name: Fullname, queue: DispatchQueue = .main) -> AnyPublisher<Listing, Error> { info(names: [name], queue: queue) }
}

public extension Illithid {
  @discardableResult
  func info(names: [Fullname], queue: DispatchQueue = .main,
            completion: @escaping (Result<Listing, AFError>) -> Void) -> DataRequest {
    let endpoint = URL(string: "/api/info", relativeTo: baseURL)!
    let infoParameters: Parameters = ["id": names.joined(separator: ",")]

    return session.request(endpoint, method: .get, parameters: infoParameters)
      .validate()
      .responseDecodable(of: Listing.self, queue: queue, decoder: decoder) { response in
        completion(response.result)
      }
  }

  @discardableResult
  func info(name: Fullname, queue: DispatchQueue = .main,
            completion: @escaping (Result<Listing, AFError>) -> Void) -> DataRequest {
    info(names: [name], queue: queue) { completion($0) }
  }
}
