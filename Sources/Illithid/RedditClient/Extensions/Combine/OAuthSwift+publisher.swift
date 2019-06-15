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
    return Publishers.Future { result in
      self.get(url,
               success: { response in
                 result(.success(response))
               },
               failure: { error in
                 result(.failure(error))
      })
    }.eraseToAnyPublisher()
  }
}
