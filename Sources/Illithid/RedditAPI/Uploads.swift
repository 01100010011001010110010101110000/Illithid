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

// MARK: - UploadRouter

enum UploadRouter: URLRequestConvertible {
  case mediaAssetLease(name: String, mimeType: String)

  // MARK: Internal

  func asURLRequest() throws -> URLRequest {
    switch self {
    case let .mediaAssetLease(name, mime):
      let request = try URLRequest(url: URL(string: "api/media/asset", relativeTo: Illithid.shared.baseURL)!, method: .post)
      return try URLEncoding.httpBody.encode(request, with: [
        "filepath": name,
        "mimetype": mime,
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
      .publishDecodable(type: AssetUploadLease.self, queue: queue, decoder: decoder)
      .value()
  }

  func uploadMedia(fileUrl: URL, queue: DispatchQueue = .main)
    -> AnyPublisher<(AssetUploadLease, Data), AFError> {
    acquireMediaUploadLease(forFile: fileUrl, queue: queue)
      .flatMap { lease -> AnyPublisher<(AssetUploadLease, Data), AFError> in
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileUrl.pathExtension as CFString, nil)?.takeRetainedValue(),
              let mimeType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() else {
          return Fail(outputType: (AssetUploadLease, Data).self, failure: AFError.invalidURL(url: fileUrl))
            .eraseToAnyPublisher()
        }

        do {
          let request = try URLRequest(url: lease.lease.uploadUrl, method: .post)
          let imageData = try Data(contentsOf: fileUrl)

          // TODO: Use a dedicated session for this
          return unauthenticatedSession.upload(multipartFormData: { formData in
            lease.lease.parameters.forEach { key, value in
              guard let data = value.data(using: .utf8) else { return }
              formData.append(data, withName: key)
            }
            formData.append(imageData, withName: "file", fileName: nil, mimeType: mimeType as String)
          }, with: request, interceptor: Interceptor())
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
