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

public struct ModeratedSubreddit: Codable {
  public let iconImage: URL?
  public let bannerImage: URL?
  public let name: Fullname
  public let primaryColor: String
  public let title: String
  public let url: URL
  public let subredditDisplayName: String
  public let subredditDisplayNamePrefixed: String
  public let created: Date
  public let createdUtc: Date
  public let bannerSize: [Int]?
  public let userCanCrosspost: Bool
  public let modPermissions: [String]
  public let over18: Bool
  public let subscribers: Int
  public let communityIcon: URL?
  public let iconSize: [Int]?
  public let keyColor: String
  public let subredditType: Subreddit.SubredditType
  public let whitelistStatus: Subreddit.WhitelistStatus?
  public let userIsSubscriber: Bool

  enum CodingKeys: String, CodingKey {
    case iconImage = "icon_img"
    case bannerImage = "banner_img"
    case name
    case primaryColor = "primary_color"
    case title
    case url
    case subredditDisplayName = "sr"
    case subredditDisplayNamePrefixed = "sr_display_name_prefixed"
    case created
    case createdUtc = "created_utc"
    case bannerSize = "banner_size"
    case userCanCrosspost = "user_can_crosspost"
    case modPermissions = "mod_permissions"
    case over18 = "over_18"
    case subscribers
    case communityIcon = "community_icon"
    case iconSize = "icon_size"
    case keyColor = "key_color"
    case subredditType = "subreddit_type"
    case whitelistStatus = "whitelist_status"
    case userIsSubscriber = "user_is_subscriber"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    // When a URL property does not exist, Reddit returns the empty string
    iconImage = try? container.decode(URL.self, forKey: .iconImage)
    bannerImage = try? container.decode(URL.self, forKey: .bannerImage)
    communityIcon = try? container.decode(URL.self, forKey: .communityIcon)

    name = try container.decode(Fullname.self, forKey: .name)
    primaryColor = try container.decode(String.self, forKey: .primaryColor)
    title = try container.decode(String.self, forKey: .title)
    url = try container.decode(URL.self, forKey: .url)
    subredditDisplayName = try container.decode(String.self, forKey: .subredditDisplayName)
    subredditDisplayNamePrefixed = try container.decode(String.self, forKey: .subredditDisplayNamePrefixed)
    created = try container.decode(Date.self, forKey: .created)
    createdUtc = try container.decode(Date.self, forKey: .createdUtc)
    bannerSize = try container.decodeIfPresent([Int].self, forKey: .bannerSize)
    userCanCrosspost = try container.decode(Bool.self, forKey: .userCanCrosspost)
    modPermissions = try container.decode([String].self, forKey: .modPermissions)
    over18 = try container.decode(Bool.self, forKey: .over18)
    subscribers = try container.decode(Int.self, forKey: .subscribers)
    iconSize = try container.decodeIfPresent([Int].self, forKey: .iconSize)
    keyColor = try container.decode(String.self, forKey: .keyColor)
    subredditType = try container.decode(Subreddit.SubredditType.self, forKey: .subredditType)
    whitelistStatus = try container.decode(Subreddit.WhitelistStatus.self, forKey: .whitelistStatus)
    userIsSubscriber = try container.decode(Bool.self, forKey: .userIsSubscriber)
  }
}

struct ModeratedSubredditsList: Decodable {
  let kind: String
  let data: [ModeratedSubreddit]
}
