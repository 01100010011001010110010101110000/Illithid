//
//  File.swift
//
//
//  Created by Tyler Gregory on 6/14/19.
//

#if canImport(Combine)
import Combine
#endif
import Foundation

import OAuthSwift

public extension OAuthSwiftClient {
  func requestPublisher(_ url: URLConvertible) -> AnyPublisher<OAuthSwiftResponse, Error> {
    return Future { result in
      _ = self.get(url) { innerResult in
        switch innerResult {
        case .success(let response):
          result(.success(response))
        case .failure(let error):
          result(.failure(error))
        }
      }
    }.eraseToAnyPublisher()
  }
}

public extension OAuth2Swift {
  func requestPublisher(_ url: URLConvertible, method: OAuthSwiftHTTPRequest.Method, parameters: OAuthSwift.Parameters,
                        headers: OAuthSwift.Headers? = nil, renewHeaders: OAuthSwift.Headers? = nil,
                        body: Data? = nil, onTokenRenewal: TokenRenewedHandler? = nil)
    -> AnyPublisher<OAuthSwiftResponse, OAuthSwiftError> {
    return Future { result in
      self.startAuthorizedRequest(url, method: method, parameters: parameters, headers: headers,
                                  renewHeaders: renewHeaders, body: body, onTokenRenewal: onTokenRenewal) { innerResult in
        switch innerResult {
        case .success(let response):
          result(.success(response))
        case .failure(let error):
          result(.failure(error))
        }
      }
    }.eraseToAnyPublisher()
  }
}
