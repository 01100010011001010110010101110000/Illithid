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

import Foundation

import Alamofire

// MARK: - RedGfyWrapper

public struct RedGfyWrapper: Codable, Hashable, Equatable {
  // MARK: Public

  public let item: RedGfyItem

  public static func == (lhs: RedGfyWrapper, rhs: RedGfyWrapper) -> Bool {
    lhs.item == rhs.item
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(item)
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case item = "gfyItem"
  }
}

// MARK: - RedGfyItem

public struct RedGfyItem: Codable, Hashable, Equatable {
  // MARK: Lifecycle

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let oldContainer = try decoder.container(keyedBy: OldCodingKeys.self)

    // API Changes
    if let unwrapped = try? container.decode(String.self, forKey: .username) {
      username = unwrapped
    } else if let unwrapped = try? oldContainer.decode(String.self, forKey: .userName) {
      username = unwrapped
    } else {
      throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath,
                                                              debugDescription: "Invalid username"))
    }
    if let number = try? container.decode(Int.self, forKey: .likes) {
      likes = number
    } else if let string = try? container.decode(String.self, forKey: .likes), let number = Int(string) {
      likes = number
    } else {
      throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath,
                                                              debugDescription: "Could not decode number from likes"))
    }
    if let number = try? container.decode(Int.self, forKey: .dislikes) {
      dislikes = number
    } else if let string = try? container.decode(String.self, forKey: .dislikes), let number = Int(string) {
      dislikes = number
    } else {
      throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath,
                                                              debugDescription: "Could not decode number from dislikes"))
    }

    tags = try container.decode([String].self, forKey: .tags)
    languageCategories = try container.decode([String].self, forKey: .languageCategories)
    domainWhitelist = try container.decode([String].self, forKey: .domainWhitelist)
    geoWhitelist = try container.decode([String].self, forKey: .geoWhitelist)
    published = try container.decode(Int.self, forKey: .published)
    nsfw = try container.decode(Nsfw.self, forKey: .nsfw)
    gatekeeper = try container.decodeIfPresent(Int.self, forKey: .gatekeeper)
    mp4URL = try container.decode(URL.self, forKey: .mp4URL)
    gifURL = try container.decode(URL.self, forKey: .gifURL)
    mobileURL = try container.decode(URL.self, forKey: .mobileURL)
    mobilePosterURL = try container.decode(URL.self, forKey: .mobilePosterURL)
    thumb100PosterURL = try container.decode(URL.self, forKey: .thumb100PosterURL)
    miniURL = try container.decode(URL.self, forKey: .miniURL)
    gif100Px = try container.decodeIfPresent(URL.self, forKey: .gif100Px)
    miniPosterURL = try container.decode(URL.self, forKey: .miniPosterURL)
    max5MBGIF = try container.decodeIfPresent(URL.self, forKey: .max5MBGIF)
    title = try container.decodeIfPresent(String.self, forKey: .title)
    max2MBGIF = try container.decodeIfPresent(URL.self, forKey: .max2MBGIF)
    max1MBGIF = try container.decodeIfPresent(URL.self, forKey: .max1MBGIF)
    posterURL = try container.decode(URL.self, forKey: .posterURL)
    views = try container.decode(Int.self, forKey: .views)
    hasTransparency = try container.decode(Bool.self, forKey: .hasTransparency)
    hasAudio = try container.decode(Bool.self, forKey: .hasAudio)
    gfyId = try container.decode(String.self, forKey: .gfyId)
    gfyName = try container.decode(String.self, forKey: .gfyName)
    avgColor = try container.decode(String.self, forKey: .avgColor)
    gfySlug = try container.decodeIfPresent(String.self, forKey: .gfySlug)
    width = try container.decode(Int.self, forKey: .width)
    height = try container.decode(Int.self, forKey: .height)
    frameRate = try container.decode(Double.self, forKey: .frameRate)
    numFrames = try container.decode(Int.self, forKey: .numFrames)
    createDate = try container.decode(Date.self, forKey: .createDate)
    source = try container.decode(Int.self, forKey: .source)
    gifSize = try container.decodeIfPresent(Int.self, forKey: .gifSize)
    contentUrls = try container.decode([String: GfyContent].self, forKey: .contentUrls)
  }

  // MARK: Public

  /// Representation of Gfycat's ternary `nsfw` state
  public enum Nsfw: Int, Codable {
    case safe = 0
    case notSafe = 1
    /// Unclear what precisely this would imply, but that is how Gfycat's documentation puts it
    case potentiallyOffensive = 3
    /// Meaning not currently known
    case unknown = 12

    // MARK: Lifecycle

    public init?(rawValue: Int) {
      switch rawValue {
      case 0:
        self = .safe
      case 1:
        self = .notSafe
      case 3:
        self = .potentiallyOffensive
      case 12:
        self = .unknown
      default:
        return nil
      }
    }

    public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()

      if let number = try? container.decode(Int.self), let unwrapped = Nsfw(rawValue: number) {
        self = unwrapped
      } else if let string = try? container.decode(String.self), let number = Int(string), let unwrapped = Nsfw(rawValue: number) {
        self = unwrapped
      } else {
        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath,
                                                                debugDescription: "Invalid NSFW ternary"))
      }
    }
  }

  public let tags: [String]
  public let languageCategories: [String]
  public let domainWhitelist: [String]
  public let geoWhitelist: [String]
  public let published: Int
  public let nsfw: Nsfw
  public let gatekeeper: Int?
  public let mp4URL: URL
  public let gifURL: URL
  public let mobileURL: URL
  public let mobilePosterURL: URL
  public let thumb100PosterURL: URL
  public let miniURL: URL
  public let gif100Px: URL?
  public let miniPosterURL: URL
  public let max5MBGIF: URL?
  public let title: String?
  public let max2MBGIF: URL?
  public let max1MBGIF: URL?
  public let posterURL: URL
  public let views: Int
  public let username: String
  public let hasTransparency: Bool
  public let hasAudio: Bool
  public let likes: Int
  public let dislikes: Int
  public let gfyId: String
  public let gfyName: String
  public let avgColor: String
  public let gfySlug: String?
  public let width: Int
  public let height: Int
  public let frameRate: Double
  public let numFrames: Int
  public let createDate: Date
  public let source: Int
  public let gifSize: Int?
  public let contentUrls: [String: GfyContent]

  public static func == (lhs: RedGfyItem, rhs: RedGfyItem) -> Bool {
    lhs.gfyId == rhs.gfyId
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(gfyId)
  }

  // MARK: Internal

  enum OldCodingKeys: String, CodingKey {
    case userName
  }

  enum CodingKeys: String, CodingKey {
    case tags
    case languageCategories
    case domainWhitelist
    case geoWhitelist
    case published
    case nsfw
    case gatekeeper
    case mp4URL = "mp4Url"
    case gifURL = "gifUrl"
    case mobileURL = "mobileUrl"
    case mobilePosterURL = "mobilePosterUrl"
    case thumb100PosterURL = "thumb100PosterUrl"
    case miniURL = "miniUrl"
    case gif100Px = "gif100px"
    case miniPosterURL = "miniPosterUrl"
    case max5MBGIF = "max5mbGif"
    case title
    case max2MBGIF = "max2mbGif"
    case max1MBGIF = "max1mbGif"
    case posterURL = "posterUrl"
    case views
    case username
    case hasTransparency
    case hasAudio
    case likes
    case dislikes
    case gfyId
    case gfyName
    case avgColor
    case gfySlug
    case width
    case height
    case frameRate
    case numFrames
    case createDate
    case source
    case gifSize
    case contentUrls = "content_urls"
  }
}
