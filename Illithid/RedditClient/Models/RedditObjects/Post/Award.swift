//
//  Award.swift
//  Illithid
//
//  Created by Tyler Gregory on 5/2/19.
//  Copyright © 2019 flayware. All rights reserved.
//

import Foundation

struct Award: Codable {
  let is_enabled: Bool
  let count: Int
  let subreddit_id: String?
  let description: String
  let coin_reward: Int
  let icon_width: Int
  let icon_height: Int
  let icon_url: URL
  let days_of_premium: Int
  let days_of_drip_extension: Int
  let award_type: String
  let coin_price: Int
  let id: AwardID
  let name: AwardName
  let resized_icons: [AwardIcons]
  
  enum AwardID: String, Codable {
    case gid_1
    case gid_2
    case gid_3
  }
  enum AwardName: String, Codable {
    case Silver
    case Gold
    case Platinum
  }
  
  struct AwardIcons: Codable {
    let url: URL
    let width: Int
    let height: Int
  }
}
