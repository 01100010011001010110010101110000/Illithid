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
import AppKit
import CoreGraphics
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
extension Illithid {
  func acquireMediaUploadLease(for fileUrl: URL, queue: DispatchQueue = .main)
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

  func acquireMediaUploadLease(named fileName: String, mimeType: String, queue: DispatchQueue = .main)
    -> AnyPublisher<AssetUploadLease, AFError> {
    session.request(UploadRouter.mediaAssetLease(name: fileName, mimeType: mimeType))
      .validate()
      .publishDecodable(type: AssetUploadLease.self, queue: queue, decoder: decoder)
      .value()
  }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Illithid {
  func receiveUploadResponse(lease: AssetUploadLease)
    -> AnyPublisher<MediaUploadResponse?, AFError> {
    Future<MediaUploadResponse?, AFError> { promise in
      let connection = URLSession.shared.webSocketTask(with: lease.asset.websocketUrl)
      connection.resume()
      connection.receive { result in
        switch result {
        case let .success(message):
          switch message {
          case let .string(string):
            guard let data = string.data(using: .utf8) else { promise(.success(nil)); return }
            do {
              let response = try self.decoder.decode(MediaUploadResponse.self, from: data)
              promise(.success(response))
            } catch {
              promise(.failure(AFError.responseSerializationFailed(reason: .decodingFailed(error: error))))
            }
          default:
            break
          }
        case let .failure(error):
          promise(.failure(error.asAFError ?? AFError.sessionTaskFailed(error: error)))
        }
      }
    }
    .eraseToAnyPublisher()
  }

  func uploadMedia(fileUrl: URL, queue: DispatchQueue = .main)
    -> AnyPublisher<(lease: AssetUploadLease, uploadResponse: Data), AFError> {
    acquireMediaUploadLease(for: fileUrl, queue: queue)
      .flatMap { lease -> AnyPublisher<(lease: AssetUploadLease, uploadResponse: Data), AFError> in
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileUrl.pathExtension as CFString, nil)?.takeRetainedValue(),
              let mimeType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() else {
          return Fail(outputType: (lease: AssetUploadLease, uploadResponse: Data).self, failure: AFError.invalidURL(url: fileUrl))
            .eraseToAnyPublisher()
        }

        do {
          let request = try URLRequest(url: lease.lease.uploadUrl, method: .post)
          let imageData = try Data(contentsOf: fileUrl)

          return self.unauthenticatedSession.upload(multipartFormData: { formData in
            lease.lease.parameters.forEach { key, value in
              guard let data = value.data(using: .utf8) else { return }
              formData.append(data, withName: key)
            }
            formData.append(imageData, withName: "file", fileName: nil, mimeType: mimeType as String)
          }, with: request, interceptor: Interceptor())
            .validate()
            .publishData(queue: queue)
            .value()
            .map { data in
              (lease, data)
            }
            .eraseToAnyPublisher()
        } catch {
          return Fail(outputType: (lease: AssetUploadLease, uploadResponse: Data).self, failure: AFError.parameterEncodingFailed(reason: .customEncodingFailed(error: error)))
            .eraseToAnyPublisher()
        }
      }
      .eraseToAnyPublisher()
  }

  func uploadMedia(image: CGImage, queue: DispatchQueue = .main)
    -> AnyPublisher<(lease: AssetUploadLease, uploadResponse: Data), AFError> {
    let mimeType = "image/png"
    return acquireMediaUploadLease(named: UUID().uuidString, mimeType: mimeType, queue: queue)
      .flatMap { lease -> AnyPublisher<(lease: AssetUploadLease, uploadResponse: Data), AFError> in
        do {
          let request = try URLRequest(url: lease.lease.uploadUrl, method: .post)
          let bitmap = NSBitmapImageRep(cgImage: image)
          let png = bitmap.representation(using: .png, properties: [:])!

          return self.unauthenticatedSession.upload(multipartFormData: { formData in
            lease.lease.parameters.forEach { key, value in
              guard let data = value.data(using: .utf8) else { return }
              formData.append(data, withName: key)
            }
            formData.append(png, withName: "file", fileName: nil, mimeType: mimeType as String)
          }, with: request, interceptor: Interceptor())
            .validate()
            .publishData(queue: queue)
            .value()
            .map { data in
              (lease, data)
            }
            .eraseToAnyPublisher()
        } catch {
          return Fail(outputType: (lease: AssetUploadLease, uploadResponse: Data).self, failure: AFError.parameterEncodingFailed(reason: .customEncodingFailed(error: error)))
            .eraseToAnyPublisher()
        }
      }
      .eraseToAnyPublisher()
  }
}

public extension Illithid {
  /// The maximum number of items a gallery post can contain
  /// - Note: This is set by Reddit
  static let maximumGalleryItems: Int = 20
}
