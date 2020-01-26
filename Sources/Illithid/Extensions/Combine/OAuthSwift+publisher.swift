//
// OAuthSwift+publisher.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 12/24/19
//

#if canImport(Combine)
  import Combine
#endif
import Foundation

import OAuthSwift

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
