//
//  File.swift
//
//
//  Created by Tyler Gregory on 7/6/19.
//

#if canImport(Combine)
import Combine
#endif
import Foundation

import Alamofire

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension RedditClientBroker {
  func info(names: [Fullname]) -> AnyPublisher<Listing, Error> {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .secondsSince1970
    let endpoint = URL(string: "https://oauth.reddit.com/api/info")!
    let queryEncoding = URLEncoding(boolEncoding: .numeric)
    let infoParameters: Parameters = [
      "id": names.joined(separator: ","),
      "raw_json": true
    ]

    return session.requestPublisher(url: endpoint, method: .get, parameters: infoParameters, encoding: queryEncoding)
      .compactMap { $0.data }
      .decode(type: Listing.self, decoder: decoder)
      .eraseToAnyPublisher()
  }
  func info(name: Fullname) -> AnyPublisher<Listing, Error> {
    return info(names: [name])
  }
}

public extension RedditClientBroker {
  func info(names: [Fullname], completion: @escaping (Result<Listing>) -> Void) {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .secondsSince1970
    let endpoint = URL(string: "https://oauth.reddit.com/api/info")!
    let queryEncoding = URLEncoding(boolEncoding: .numeric)
    let infoParameters: Parameters = [
      "id": names.joined(separator: ","),
      "raw_json": true
    ]

    session.request(endpoint, method: .get, parameters: infoParameters, encoding: queryEncoding).validate().responseData { response in
      switch response.result {
      case .success(let data):
        do {
          let listing = try decoder.decode(Listing.self, from: data)
          completion(.success(listing))
        } catch {
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
  func info(name: Fullname, completion: @escaping (Result<Listing>) -> Void) {
    info(names: [name]) { completion($0) }
  }
}