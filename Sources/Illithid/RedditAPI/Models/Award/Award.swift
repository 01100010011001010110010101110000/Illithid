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
