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

public struct SubredditSuggestion: Codable {
  public let activeUserCount: Int
  public let iconImage: URL?
  public let keyColor: String
  public let name: String
  public let subscriberCount: Int
  public let isChatPostFeatureEnabled: Bool
  public let allowChatPostCreation: Bool
  public let allowImages: Bool

  enum CodingKeys: String, CodingKey {
    case activeUserCount = "active_user_count"
    case iconImage = "icon_img"
    case keyColor = "key_color"
    case name
    case subscriberCount = "subscriber_count"
    case isChatPostFeatureEnabled = "is_chat_post_feature_enabled"
    case allowChatPostCreation = "allow_chat_post_creation"
    case allowImages = "allow_images"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    if let emptyString = try? container.decode(String.self, forKey: .iconImage), emptyString.isEmpty {
      iconImage = nil
    } else {
      iconImage = try container.decode(URL.self, forKey: .iconImage)
    }
    activeUserCount = try container.decode(Int.self, forKey: .activeUserCount)
    keyColor = try container.decode(String.self, forKey: .keyColor)
    name = try container.decode(String.self, forKey: .name)
    subscriberCount = try container.decode(Int.self, forKey: .subscriberCount)
    isChatPostFeatureEnabled = try container.decode(Bool.self, forKey: .isChatPostFeatureEnabled)
    allowChatPostCreation = try container.decode(Bool.self, forKey: .allowChatPostCreation)
    allowImages = try container.decode(Bool.self, forKey: .allowImages)
  }
}

struct SubredditSuggestions: Codable {
  let subreddits: [SubredditSuggestion]
}
