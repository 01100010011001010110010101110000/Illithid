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

import Alamofire
import Foundation

// MARK: - ImgurImageWrapper

internal struct ImgurImageWrapper: Codable, Hashable {
  // MARK: Lifecycle

  public init(data: ImgurImage, success: Bool, status: Int) {
    self.data = data
    self.success = success
    self.status = status
  }

  // MARK: Public

  public let data: ImgurImage
  public let success: Bool
  public let status: Int

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case data
    case success
    case status
  }
}

// MARK: - ImgurImage

public struct ImgurImage: Codable, Hashable, Identifiable {
  // MARK: Public

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
  public let nsfw: Bool?
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
  public let adConfig: AdConfig?

  // MARK: Internal

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
  // MARK: Lifecycle

  public init(safeFlags: [String], highRiskFlags: [String], unsafeFlags: [String], wallUnsafeFlags: [String], showsAds: Bool) {
    self.safeFlags = safeFlags
    self.highRiskFlags = highRiskFlags
    self.unsafeFlags = unsafeFlags
    self.wallUnsafeFlags = wallUnsafeFlags
    self.showsAds = showsAds
  }

  // MARK: Public

  public let safeFlags: [String]
  public let highRiskFlags: [String]
  public let unsafeFlags: [String]
  public let wallUnsafeFlags: [String]
  public let showsAds: Bool

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case safeFlags
    case highRiskFlags
    case unsafeFlags
    case wallUnsafeFlags
    case showsAds
  }
}

// MARK: - Processing

public struct Processing: Codable, Hashable {
  // MARK: Lifecycle

  public init(status: String) {
    self.status = status
  }

  // MARK: Public

  public let status: String

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case status
  }
}
