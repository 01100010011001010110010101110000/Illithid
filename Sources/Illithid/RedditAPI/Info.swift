// Copyright (C) 2020 Tyler Gregory (@01100010011001010110010101110000)
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of  MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <http://www.gnu.org/licenses/>.

#if canImport(Combine)
  import Combine
#endif
import Foundation

import Alamofire

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Illithid {
  func info(names: [Fullname], queue: DispatchQueue = .main) -> AnyPublisher<Listing, AFError> {
    let endpoint = URL(string: "/api/info", relativeTo: baseURL)!
    let infoParameters: Parameters = ["id": names.joined(separator: ",")]

    return session.request(endpoint, method: .get, parameters: infoParameters)
      .publishDecodable(type: Listing.self, queue: queue, decoder: decoder)
      .value()
  }

  func info(name: Fullname, queue: DispatchQueue = .main) -> AnyPublisher<Listing, AFError> { info(names: [name], queue: queue) }
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
