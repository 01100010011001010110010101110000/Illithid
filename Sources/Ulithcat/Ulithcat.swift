//
// Ulithcat.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 1/13/20
//

#if canImport(Combine)
  import Combine
#endif
import Foundation

import Alamofire

open class Ulithcat {
  public let gfycatBaseUrl = URL(string: "https://api.gfycat.com/v1/")!
  public let imgurBaseUrl = URL(string: "https://api.imgur.com/3/")!

  internal let session: SessionManager

  internal let decoder: JSONDecoder = .init()
  public init() {
    let alamoConfiguration = URLSessionConfiguration.default
    let osVersion = ProcessInfo().operatingSystemVersion
    let userAgentComponents = [
      "Ulithcat/1",
      "macOS \(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)",
    ]
    let headers = SessionManager.defaultHTTPHeaders.merging([
      "User-Agent": userAgentComponents.joined(separator: ":"),
      "Accept": "application/json",
    ]) { _, new in new }
    alamoConfiguration.httpAdditionalHeaders = headers
    session = SessionManager(configuration: alamoConfiguration)
  }
}

public extension Ulithcat {
  func fetchGfycat(id: String, queue: DispatchQueue? = nil, completion: @escaping (Swift.Result<GfyItem, Error>) -> Void) {
    session.request(URL(string: "gfycats/\(id)", relativeTo: gfycatBaseUrl)!).validate()
      .responseGfyWrapper(queue: queue) { response in
        switch response.result {
        case let .success(wrapper):
          completion(.success(wrapper.item))
        case let .failure(error):
          completion(.failure(error))
        }
      }
  }

  func fetchGfycat(from url: URL, queue: DispatchQueue? = nil, completion: @escaping (Swift.Result<GfyItem, Error>) -> Void) {
    let gfyId = String(url.path.dropFirst())
    fetchGfycat(id: gfyId, queue: queue, completion: completion)
  }
}

public extension Ulithcat {
  func fetchImgurImage(id: String, queue: DispatchQueue? = nil, completion: @escaping (Swift.Result<ImgurImage, Error>) -> Void) {
    session.request(URL(string: "image/\(id)", relativeTo: imgurBaseUrl)!).validate()
      .responseImgurImage(queue: queue) { response in
        switch response.result {
        case let .success(image):
          completion(.success(image))
        case let .failure(error):
          completion(.failure(error))
        }
    }
  }
}
