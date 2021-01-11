//
//  File.swift
//  
//
//  Created by Tyler Gregory on 1/10/21.
//

#if canImport(Combine)
import Combine
#endif
import Foundation

import Alamofire

enum UploadRouter: URLRequestConvertible {
  case mediaAssetLease(name: String, mimeType: String)


  func asURLRequest() throws -> URLRequest {
    switch self {
    case let .mediaAssetLease(name, mime):
      let request = try URLRequest(url: URL(string: "api/media/asset", relativeTo: Illithid.shared.baseURL)!, method: .get)
      return try URLEncoding.httpBody.encode(request, with: [
        "filepath": name,
        "mimetype": mime
      ])
    }
  }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Illithid {
  func acquireMediaUploadLease(forFile fileUrl: URL, queue: DispatchQueue = .main)
  -> AnyPublisher<AssetUploadLease, AFError> {
    guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileUrl.pathExtension as CFString, nil)?.takeRetainedValue(),
          let mimeType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue(),
          !fileUrl.lastPathComponent.isEmpty else {
      return Fail(outputType: AssetUploadLease.self, failure: AFError.invalidURL(url: fileUrl))
        .eraseToAnyPublisher()
    }
    return session.request(UploadRouter.mediaAssetLease(name: fileUrl.lastPathComponent.lowercased(), mimeType: mimeType as String))
      .validate()
      .publishDecodable(type: AssetUploadLease.self, queue: queue, decoder: decoder)
      .value()
  }

  func uploadMedia(fileUrl: URL, queue: DispatchQueue = .main)
  -> AnyPublisher<(AssetUploadLease, Data), AFError> {
    acquireMediaUploadLease(forFile: fileUrl, queue: queue)
      .flatMap { lease -> AnyPublisher<(AssetUploadLease, Data), AFError> in
        let request = URLRequest(url: lease.lease.uploadUrl)
        do {
          let encodedRequest = try URLEncoding.httpBody.encode(request, with: lease.lease.parameters)
          return self.session.upload(fileUrl, with: encodedRequest)
            .validate()
            .publishData(queue: queue)
            .value()
            .map { data in
              (lease, data)
            }
            .eraseToAnyPublisher()
        } catch {
          return Fail(outputType: (AssetUploadLease, Data).self, failure: AFError.parameterEncodingFailed(reason: .customEncodingFailed(error: error)))
            .eraseToAnyPublisher()
        }
      }
      .eraseToAnyPublisher()
  }
}
