//
//  File.swift
//
//
//  Created by Tyler Gregory on 6/11/19.
//

#if canImport(Combine)
import Combine
#endif

import Foundation

import Alamofire
import AlamofireImage

@available(iOS 13.0, macOS 10.15, *)
public extension SessionManager {
  func requestPublisher(url: URLConvertible,
                        method: HTTPMethod = .get,
                        parameters: Parameters? = nil,
                        encoding: ParameterEncoding = URLEncoding.default,
                        headers: HTTPHeaders? = nil)
    -> AnyPublisher<DataResponse<Data>, Never> {
    return Publishers.Future { result in
      self.request(url).validate().responseData { response in
        switch response.result {
        case .success:
          result(.success(response))
        case let .failure(error):
          break
//          result(.failure(error))
        }
      }
    }.eraseToAnyPublisher()
  }

  func requestPublisher(urlRequest: URLRequestConvertible,
                        method: HTTPMethod = .get,
                        parameters: Parameters? = nil,
                        encoding: ParameterEncoding = URLEncoding.default,
                        headers: HTTPHeaders? = nil)
    -> AnyPublisher<DataResponse<Data>, Never> {
    return Publishers.Future { result in
      self.request(urlRequest).validate().responseData { response in
        switch response.result {
        case .success:
          result(.success(response))
        case let .failure(error):
          break
//          result(.failure(error))
        }
      }
    }.eraseToAnyPublisher()
  }
}

@available(iOS 13.0, macOS 10.15, *)
public extension ImageDownloader {
  func imagePublisher(for url: URL) -> AnyPublisher<Image, Never> {
    return Publishers.Future { result in
      let urlRequest = URLRequest(url: url)
      self.download(urlRequest) { response in
        if let image = response.result.value {
          result(.success(image))
        }
      }
    }.eraseToAnyPublisher()
  }
}
