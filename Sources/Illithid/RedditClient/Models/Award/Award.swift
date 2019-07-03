//
//  Award.swift
//  Illithid
//
//  Created by Tyler Gregory on 5/2/19.
//  Copyright © 2019 flayware. All rights reserved.
//

import Foundation

public struct Award: Codable {
  public let is_enabled: Bool
  public let count: Int
  public let subreddit_id: String?
  public let description: String?
  public let coin_reward: Int
  public let icon_width: Int
  public let icon_height: Int
  public let icon_url: URL
  public let days_of_premium: Int
  public let days_of_drip_extension: Int
  public let award_type: String
  public let coin_price: Int

  // TODO Reddit has (recently?) implemented "community" awards, which have GUID IDs and can have any name;
  // decide whether to leave this unhandled as strings or special case it via custom coding
  public let id: String
  public let name: String
  public let resized_icons: [AwardIcons]
  
  public enum AwardID: String, Codable {
    case gid_1
    case gid_2
    case gid_3
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
}
