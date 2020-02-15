//
// {file}
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on {created}
//

#if canImport(Combine)
  import Combine
#endif
import Foundation

import Alamofire

open class Ulithari {
  public static let shared = Ulithari()
  public static let gfycatBaseUrl = URL(string: "https://api.gfycat.com/v1/")!
  public static let imgurBaseUrl = URL(string: "https://api.imgur.com/3/")!

  internal let session: Session

  internal var imgurAuthorizationHeader: HTTPHeaders = []

  fileprivate let imgurDecoder = JSONDecoder()
  fileprivate let gfycatDecoder = JSONDecoder()

  private init() {
    let alamoConfiguration = URLSessionConfiguration.default

    // Construct default HTTP headers
    let osVersion = ProcessInfo().operatingSystemVersion
    let userAgentComponents = [
      "Ulithari/1",
      "macOS \(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)",
    ]
    let headers: HTTPHeaders = [
      .userAgent(userAgentComponents.joined(separator: ":")),
      .accept("application/json"),
    ]
    alamoConfiguration.httpAdditionalHeaders = headers.dictionary

    session = Session(configuration: alamoConfiguration)

    // Setup JSON decoders
    imgurDecoder.dateDecodingStrategy = .iso8601
    gfycatDecoder.dateDecodingStrategy = .secondsSince1970
  }

  public func configure(imgurClientId: String) {
    imgurAuthorizationHeader.add(.authorization("Client-ID \(imgurClientId)"))
  }
}

public extension Ulithari {
  func fetchGfycat(id: String, queue: DispatchQueue = .main, completion: @escaping (Result<GfyItem, Error>) -> Void) {
    session.request(URL(string: "gfycats/\(id)", relativeTo: Self.gfycatBaseUrl)!).validate()
      .responseDecodable(of: GfyWrapper.self, queue: queue, decoder: gfycatDecoder) { response in
        switch response.result {
        case let .success(wrapper):
          completion(.success(wrapper.item))
        case let .failure(error):
          completion(.failure(error))
        }
      }
  }

  func fetchGfycat(from url: URL, queue: DispatchQueue = .main, completion: @escaping (Result<GfyItem, Error>) -> Void) {
    let gfyId = String(url.path.dropFirst())
    fetchGfycat(id: gfyId, queue: queue, completion: completion)
  }
}

public extension Ulithari {
  func fetchImgurImage(id: String, queue: DispatchQueue = .main, completion: @escaping (Result<ImgurImage, Error>) -> Void) {
    session.request(URL(string: "image/\(id)", relativeTo: Self.imgurBaseUrl)!, headers: imgurAuthorizationHeader).validate()
      .responseDecodable(of: ImgurImage.self, queue: queue, decoder: imgurDecoder) { response in
        switch response.result {
        case let .success(image):
          completion(.success(image))
        case let .failure(error):
          completion(.failure(error))
        }
      }
  }
}
