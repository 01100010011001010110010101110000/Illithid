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

// MARK: - Ulithari

open class Ulithari {
  // MARK: Lifecycle

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

  // MARK: Public

  public static let shared = Ulithari()
  public static let gfycatBaseUrl = URL(string: "https://api.gfycat.com/v1/")!
  public static let redGifsBaseUrl = URL(string: "https://api.redgifs.com/v1/")!
  public static let redGifsV2BaseUrl = URL(string: "https://api.redgifs.com/v2/")!
  public static let imgurBaseUrl = URL(string: "https://api.imgur.com/3/")!

  public func configure(imgurClientId: String) {
    imgurAuthorizationHeader.add(.authorization("Client-ID \(imgurClientId)"))
  }

  // MARK: Internal

  internal let session: Session

  internal var imgurAuthorizationHeader: HTTPHeaders = []

  // MARK: Private

  private let imgurDecoder = JSONDecoder()
  private let gfycatDecoder = JSONDecoder()
}

public extension Ulithari {
  func fetchGfycat(id: String, queue: DispatchQueue = .main, completion: @escaping (Result<GfyItem, AFError>) -> Void) -> DataRequest {
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

  func fetchGfycat(from url: URL, queue: DispatchQueue = .main, completion: @escaping (Result<GfyItem, AFError>) -> Void) -> DataRequest {
    let gfyId = String(url.path.dropFirst())
    return fetchGfycat(id: gfyId, queue: queue, completion: completion)
  }

  func fetchRedGif(id: String, queue: DispatchQueue = .main, completion: @escaping (Result<RedGfyItem, AFError>) -> Void) -> DataRequest {
    session.request(URL(string: "gfycats/\(id)", relativeTo: Self.redGifsBaseUrl)!).validate()
      .responseDecodable(of: RedGfyWrapper.self, queue: queue, decoder: gfycatDecoder) { response in
        switch response.result {
        case let .success(wrapper):
          completion(.success(wrapper.item))
        case let .failure(error):
          completion(.failure(error))
        }
      }
  }

  func fetchRedGif(from url: URL, queue: DispatchQueue = .main, completion: @escaping (Result<RedGfyItem, AFError>) -> Void) -> DataRequest {
    let redGifId = String(url.path.dropFirst())
    return fetchRedGif(id: redGifId, queue: queue, completion: completion)
  }

  func fetchRedGifV2(id: String, queue: DispatchQueue = .main, completion: @escaping (Result<RedGif, AFError>) -> Void) -> DataRequest {
    session.request(URL(string: "gifs/\(id)", relativeTo: Self.redGifsV2BaseUrl)!).validate()
           .responseDecodable(of: RedGif.self, queue: queue, decoder: gfycatDecoder) { response in
             switch response.result {
             case let .success(gif):
               completion(.success(gif))
             case let .failure(error):
               completion(.failure(error))
             }
           }
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
                       completion: @escaping (Result<ImgurAlbum, AFError>) -> Void)
    -> DataRequest {
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
                       completion: @escaping (Result<ImgurImage, AFError>) -> Void)
    -> DataRequest {
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
