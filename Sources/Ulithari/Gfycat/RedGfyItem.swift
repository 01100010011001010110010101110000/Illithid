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

    avgColor = try container.decode(String.self, forKey: .avgColor)
    createDate = try container.decode(Date.self, forKey: .createDate)
    contentUrls = try container.decode([String: GfyContent].self, forKey: .contentUrls)
    duration = try container.decode(Double.self, forKey: .duration)
    gfyId = try container.decode(String.self, forKey: .gfyId)
    hasAudio = try container.decode(Bool.self, forKey: .hasAudio)
    height = try container.decode(Int.self, forKey: .height)
    likes = try container.decode(Int.self, forKey: .likes)
    published = try container.decode(Int.self, forKey: .published)
    tags = try container.decode([String].self, forKey: .tags)
    username = try container.decode(String.self, forKey: .username)
    views = try container.decode(Int.self, forKey: .views)
    width = try container.decode(Int.self, forKey: .width)
  }

  // MARK: Public

  public let tags: [String]
  public let published: Int
  public let views: Int
  public let username: String
  public let hasAudio: Bool
  public let likes: Int
  public let gfyId: String
  public let avgColor: String
  public let width: Int
  public let height: Int
  public let createDate: Date
  public let duration: Double
  public let contentUrls: [String: GfyContent]

  public static func == (lhs: RedGfyItem, rhs: RedGfyItem) -> Bool {
    lhs.gfyId == rhs.gfyId
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(gfyId)
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case tags
    case duration
    case published
    case views
    case hasAudio
    case likes
    case gfyId
    case avgColor
    case width
    case height
    case createDate
    case username = "userName"
    case contentUrls = "content_urls"
  }
}
