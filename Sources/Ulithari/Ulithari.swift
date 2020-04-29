//
// Ulithari.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 4/27/20
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

  private let imgurDecoder = JSONDecoder()
  private let gfycatDecoder = JSONDecoder()

  private init() {
    let alamoConfiguration = URLSessionConfiguration.default

    // Construct default HTTP headers
    let osVersion = ProcessInfo().operatingSystemVersion
    let userAgentComponents = [
      "Ulithari/1",
      "macOS \(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
    ]
    let headers: HTTPHeaders = [
      .userAgent(userAgentComponents.joined(separator: ":")),
      .accept("application/json")
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
  func fetchGfycat(id: String, queue: DispatchQueue = .main, completion: @escaping (Result<GfyItem, AFError>) -> Void) {
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

  func fetchGfycat(from url: URL, queue: DispatchQueue = .main, completion: @escaping (Result<GfyItem, AFError>) -> Void) {
    let gfyId = String(url.path.dropFirst())
    fetchGfycat(id: gfyId, queue: queue, completion: completion)
  }
}

public extension Ulithari {
  enum ImgurLinkType: Equatable {
    case image(id: String)
    case gallery(id: String)
    case album(id: String)
  }

  enum ImgurGallerySection: String, Codable {
    case hot
    case top
    case user
  }

  enum ImgurGallerySort: String, Codable {
    case viral
    case top
    case time
    case rising
  }

  enum ImgurTopWindow: String, Codable {
    case day
    case week
    case month
    case year
    case all
  }

  func imgurLinkType(_ link: URL) -> ImgurLinkType? {
    // Drop first '/' from the path to avoid an empty element in the array
    let splitPath = link.path.dropFirst().components(separatedBy: "/")
    guard !splitPath.isEmpty else { return nil }

    if splitPath.count == 1 {
      // We are an image, which has no type identifier prefix in the URL
      guard let id = splitPath.last?.components(separatedBy: ".").first else { return nil }
      return .image(id: id)
    } else {
      // We are a gallery or album, which has a type identifier prefix in the URL
      guard let type = splitPath.first, let id = splitPath.last else { return nil }
      if type == "a" { return .album(id: id) }
      else if type == "gallery" { return .gallery(id: id) }
      else { return nil }
    }
  }

  // TODO: Implement gallery methods

//  @discardableResult
//  func fetchImgurGallery(id: String, section: ImgurGallerySection = .hot, sort: ImgurGallerySort = .viral,
//                         page: Int, window: ImgurTopWindow = .day, showViral: Bool = true,
//                         showMature: Bool = false, queue: DispatchQueue = .main,
//                         completion: @escaping (Result<[ImgurImage], AFError>) -> Void) -> DataRequest {
//    session.request(URL(string: "image/\(id)", relativeTo: Self.imgurBaseUrl)!, headers: imgurAuthorizationHeader).validate()
//    .responseDecodable(of: [ImgurImage].self, queue: queue, decoder: imgurDecoder) { response in
//      completion(response.result)
//    }
//  }
//
//  @discardableResult
//  func fetchImgurSubredditGallery() -> DataRequest {
//
//  }

  @discardableResult
  func fetchImgurAlbum(id: String, queue: DispatchQueue = .main,
                       completion: @escaping (Result<ImgurAlbum, AFError>) -> Void) -> DataRequest {
    session.request(URL(string: "album/\(id)", relativeTo: Self.imgurBaseUrl)!, headers: imgurAuthorizationHeader).validate()
      .responseDecodable(of: ImgurAlbumWrapper.self, queue: queue, decoder: imgurDecoder) { response in
        switch response.result {
        case let .success(wrapper):
          completion(.success(wrapper.data))
        case let .failure(error):
          completion(.failure(error))
        }
      }
  }

  @discardableResult
  func fetchImgurImage(id: String, queue: DispatchQueue = .main,
                       completion: @escaping (Result<ImgurImage, AFError>) -> Void) -> DataRequest {
    session.request(URL(string: "image/\(id)", relativeTo: Self.imgurBaseUrl)!, headers: imgurAuthorizationHeader).validate()
      .responseDecodable(of: ImgurImageWrapper.self, queue: queue, decoder: imgurDecoder) { response in
        switch response.result {
        case let .success(wrapper):
          completion(.success(wrapper.data))
        case let .failure(error):
          completion(.failure(error))
        }
      }
  }
}
