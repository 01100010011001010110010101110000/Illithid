//
// Info.swift
// Copyright (c) 2019 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 12/24/19
//

#if canImport(Combine)
  import Combine
#endif
import Foundation

import Alamofire

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Illithid {
  func info(names: [Fullname], queue: DispatchQueue? = nil) -> AnyPublisher<Listing, Error> {
    let endpoint = URL(string: "/api/info", relativeTo: baseURL)!
    let queryEncoding = URLEncoding(boolEncoding: .numeric)
    let infoParameters: Parameters = [
      "id": names.joined(separator: ","),
      "raw_json": true,
    ]

    return session.requestPublisher(url: endpoint, method: .get, parameters: infoParameters, encoding: queryEncoding, queue: queue)
      .compactMap { $0.data }
      .decode(type: Listing.self, decoder: decoder)
      .eraseToAnyPublisher()
  }

  func info(name: Fullname, queue: DispatchQueue? = nil) -> AnyPublisher<Listing, Error> { info(names: [name], queue: queue) }
}

public extension Illithid {
  func info(names: [Fullname], queue: DispatchQueue? = nil, completion: @escaping (Result<Listing>) -> Void) {
    let endpoint = URL(string: "/api/info", relativeTo: baseURL)!
    let queryEncoding = URLEncoding(boolEncoding: .numeric)
    let infoParameters: Parameters = [
      "id": names.joined(separator: ","),
      "raw_json": true,
    ]

    session.request(endpoint, method: .get, parameters: infoParameters, encoding: queryEncoding).validate().responseData(queue: queue) { response in
      switch response.result {
      case let .success(data):
        do {
          let listing = try self.decoder.decode(Listing.self, from: data)
          completion(.success(listing))
        } catch {
          completion(.failure(error))
        }
      case let .failure(error):
        completion(.failure(error))
      }
    }
  }

  func info(name: Fullname, queue: DispatchQueue? = nil, completion: @escaping (Result<Listing>) -> Void) {
    info(names: [name], queue: queue) { completion($0) }
  }
}
