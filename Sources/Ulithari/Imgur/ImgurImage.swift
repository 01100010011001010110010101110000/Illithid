//
// {file}
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on {created}
//

import Alamofire
import Foundation

// MARK: - ImgurImage

public struct ImgurImage: Codable, Hashable {
  public let data: DataClass
  public let success: Bool
  public let status: Int

  enum CodingKeys: String, CodingKey {
    case data
    case success
    case status
  }

  public init(data: DataClass, success: Bool, status: Int) {
    self.data = data
    self.success = success
    self.status = status
  }
}

// MARK: - DataClass

public struct DataClass: Codable, Hashable {
  public let id: String
  public let title: String?
  public let dataDescription: String?
  public let datetime: Int
  public let type: String
  public let animated: Bool
  public let width: Int
  public let height: Int
  public let size: Int
  public let views: Int
  public let bandwidth: Int
  public let vote: Int?
  public let favorite: Bool
  public let nsfw: Bool
  public let section: String?
  public let accountUrl: URL?
  public let accountId: String?
  public let isAd: Bool
  public let inMostViral: Bool
  public let hasSound: Bool
  public let tags: [String]
  public let adType: Int
  public let adUrl: String
  public let edited: String
  public let inGallery: Bool
  public let link: URL
  public let mp4Size: Int?
  public let mp4: URL?
  public let gifv: URL?
  public let hls: URL?
  public let processing: Processing?
  public let adConfig: AdConfig

  enum CodingKeys: String, CodingKey {
    case id
    case title
    case dataDescription = "description"
    case datetime
    case type
    case animated
    case width
    case height
    case size
    case views
    case bandwidth
    case vote
    case favorite
    case nsfw
    case section
    case accountUrl = "account_url"
    case accountId = "account_id"
    case isAd = "is_ad"
    case inMostViral = "in_most_viral"
    case hasSound = "has_sound"
    case tags
    case adType = "ad_type"
    case adUrl = "ad_url"
    case edited
    case inGallery = "in_gallery"
    case link
    case mp4Size = "mp4_size"
    case mp4
    case gifv
    case hls
    case processing
    case adConfig = "ad_config"
  }
}

// MARK: - AdConfig

public struct AdConfig: Codable, Hashable {
  public let safeFlags: [String]
  public let highRiskFlags: [String]
  public let unsafeFlags: [String]
  public let wallUnsafeFlags: [String]
  public let showsAds: Bool

  enum CodingKeys: String, CodingKey {
    case safeFlags
    case highRiskFlags
    case unsafeFlags
    case wallUnsafeFlags
    case showsAds
  }

  public init(safeFlags: [String], highRiskFlags: [String], unsafeFlags: [String], wallUnsafeFlags: [String], showsAds: Bool) {
    self.safeFlags = safeFlags
    self.highRiskFlags = highRiskFlags
    self.unsafeFlags = unsafeFlags
    self.wallUnsafeFlags = wallUnsafeFlags
    self.showsAds = showsAds
  }
}

// MARK: - Processing

public struct Processing: Codable, Hashable {
  public let status: String

  enum CodingKeys: String, CodingKey {
    case status
  }

  public init(status: String) {
    self.status = status
  }
}

// MARK: - Helper functions for creating encoders and decoders

func newJSONDecoder() -> JSONDecoder {
  let decoder = JSONDecoder()
  if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
    decoder.dateDecodingStrategy = .iso8601
  }
  return decoder
}

func newJSONEncoder() -> JSONEncoder {
  let encoder = JSONEncoder()
  if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
    encoder.dateEncodingStrategy = .iso8601
  }
  return encoder
}

// MARK: - Alamofire response handlers

public extension DataRequest {
  fileprivate func decodableResponseSerializer<T: Decodable>() -> DataResponseSerializer<T> {
    return DataResponseSerializer { _, _, data, error in
      guard error == nil else { return .failure(error!) }

      guard let data = data else {
        return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
      }

      return Result { try newJSONDecoder().decode(T.self, from: data) }
    }
  }

  @discardableResult
  fileprivate func responseDecodable<T: Decodable>(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
    return response(queue: queue, responseSerializer: decodableResponseSerializer(), completionHandler: completionHandler)
  }

  @discardableResult
  func responseImgurImage(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<ImgurImage>) -> Void) -> Self {
    return responseDecodable(queue: queue, completionHandler: completionHandler)
  }
}
