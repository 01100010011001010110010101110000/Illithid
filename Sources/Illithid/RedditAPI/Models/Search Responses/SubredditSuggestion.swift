//
// SubredditSuggestion.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 6/21/20
//

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
