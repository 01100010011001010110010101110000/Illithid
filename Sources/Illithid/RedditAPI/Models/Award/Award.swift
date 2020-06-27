//
// Award.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 3/21/20
//

import Foundation

public struct Award: Codable {
  public let isEnabled: Bool
  public let count: Int
  public let subredditId: String?
  public let description: String?
  public let coinReward: Int
  public let iconWidth: Int
  public let iconHeight: Int
  public let iconUrl: URL
  public let daysOfPremium: Int
  public let daysOfDripExtension: Int
  public let awardType: String
  public let coinPrice: Int

  // TODO: Reddit has (recently?) implemented "community" awards, which have GUID IDs and can have any name;
  // decide whether to leave this unhandled as strings or special case it via custom coding
  public let id: String
  public let name: String
  public let resizedIcons: [AwardIcons]

  public enum AwardID: String, Codable {
    case gid1
    case gid2
    case gid3
  }

  public enum AwardName: String, Codable {
    case Silver
    case Gold
    case Platinum
  }

  public struct AwardIcons: Codable {
    public let url: URL
    public let width: Int
    public let height: Int
  }

  private enum CodingKeys: String, CodingKey {
    case isEnabled = "is_enabled"
    case count
    case subredditId = "subreddit_id"
    case description
    case coinReward = "coin_reward"
    case iconWidth = "icon_width"
    case iconHeight = "icon_height"
    case iconUrl = "icon_url"
    case daysOfPremium = "days_of_premium"
    case daysOfDripExtension = "days_of_drip_extension"
    case awardType = "award_type"
    case coinPrice = "coin_price"
    case id
    case name
    case resizedIcons = "resized_icons"
  }
}
