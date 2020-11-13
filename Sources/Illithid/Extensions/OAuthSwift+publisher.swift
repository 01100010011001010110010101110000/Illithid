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

import OAuthSwift

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension OAuthSwiftClient {
  func requestPublisher(_ url: URLConvertible) -> AnyPublisher<OAuthSwiftResponse, Error> {
    Future { result in
      _ = self.get(url) { innerResult in
        switch innerResult {
        case let .success(response):
          result(.success(response))
        case let .failure(error):
          result(.failure(error))
        }
      }
    }.eraseToAnyPublisher()
  }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension OAuth2Swift {
  func requestPublisher(_ url: URLConvertible, method: OAuthSwiftHTTPRequest.Method, parameters: OAuthSwift.Parameters,
                        headers: OAuthSwift.Headers? = nil, renewHeaders: OAuthSwift.Headers? = nil,
                        body: Data? = nil, onTokenRenewal: TokenRenewedHandler? = nil)
    -> AnyPublisher<OAuthSwiftResponse, OAuthSwiftError> {
    Future { result in
      self.startAuthorizedRequest(url, method: method, parameters: parameters, headers: headers,
                                  renewHeaders: renewHeaders, body: body, onTokenRenewal: onTokenRenewal) { innerResult in
        switch innerResult {
        case let .success(response):
          result(.success(response))
        case let .failure(error):
          result(.failure(error))
        }
      }
    }.eraseToAnyPublisher()
  }
}
