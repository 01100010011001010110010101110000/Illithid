//
// Alamofire+publisher.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 12/24/19
//

#if canImport(Combine)
  import Combine
#endif

import Foundation

import Alamofire

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Session {
  func requestPublisher(url: URLConvertible,
                        method: HTTPMethod = .get,
                        parameters: Parameters? = nil,
                        encoding: ParameterEncoding = URLEncoding.default,
                        headers: HTTPHeaders? = nil,
                        queue: DispatchQueue = .main)
    -> AnyPublisher<Data, AFError> {
    Future { result in
      self.request(url, method: method, parameters: parameters,
                   encoding: encoding, headers: headers).validate().responseData(queue: queue) { response in
                    result(response.result)
      }
    }.eraseToAnyPublisher()
  }
}
