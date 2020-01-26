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
import AlamofireImage

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension SessionManager {
  func requestPublisher(url: URLConvertible,
                        method: HTTPMethod = .get,
                        parameters: Parameters? = nil,
                        encoding: ParameterEncoding = URLEncoding.default,
                        headers: HTTPHeaders? = nil,
                        queue: DispatchQueue? = nil)
    -> AnyPublisher<DataResponse<Data>, Error> {
    Future { result in
      self.request(url, method: method, parameters: parameters,
                   encoding: encoding, headers: headers).validate().responseData(queue: queue) { response in
        switch response.result {
        case .success:
          result(.success(response))
        case let .failure(error):
          result(.failure(error))
        }
      }
    }.eraseToAnyPublisher()
  }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension ImageDownloader {
  func imagePublisher(for url: URL) -> AnyPublisher<Image, Never> {
    Future { result in
      let urlRequest = URLRequest(url: url)
      self.download(urlRequest) { response in
        if let image = response.result.value {
          result(.success(image))
        }
      }
    }.eraseToAnyPublisher()
  }
}
