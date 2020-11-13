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

public struct AccountSubreddit: Codable, Hashable, Identifiable {
  // MARK: Lifecycle

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    defaultSet = try container.decode(Bool.self, forKey: .defaultSet)
    iconColor = try container.decode(String.self, forKey: .iconColor)
    isDefaultIcon = try container.decode(Bool.self, forKey: .isDefaultIcon)
    isDefaultBanner = try container.decode(Bool.self, forKey: .isDefaultBanner)

    // When a URL property does not exist, Reddit returns the empty string
    headerImg = try? container.decode(URL.self, forKey: .headerImg)
    iconImg = try container.decode(URL.self, forKey: .iconImg)
    communityIcon = try? container.decode(URL.self, forKey: .communityIcon)
    bannerImg = try? container.decode(URL.self, forKey: .bannerImg)

    restrictPosting = try container.decode(Bool.self, forKey: .restrictPosting)
    userIsBanned = try container.decode(Bool.self, forKey: .userIsBanned)
    freeFormReports = try container.decode(Bool.self, forKey: .freeFormReports)
    userIsMuted = try container.decode(Bool.self, forKey: .userIsMuted)
    displayName = try container.decode(String.self, forKey: .displayName)
    title = try container.decode(String.self, forKey: .title)
    iconSize = try container.decode([Int].self, forKey: .iconSize)
    primaryColor = try container.decode(String.self, forKey: .primaryColor)
    displayNamePrefixed = try container.decode(String.self, forKey: .displayNamePrefixed)
    subscribers = try container.decode(Int.self, forKey: .subscribers)

    name = try container.decode(Fullname.self, forKey: .name)
    id = String(name.split(separator: "_").last!)

    publicDescription = try container.decode(String.self, forKey: .publicDescription)
    headerSize = try container.decodeIfPresent([Int].self, forKey: .headerSize)
    keyColor = try container.decode(String.self, forKey: .keyColor)
    userIsSubscriber = try container.decode(Bool.self, forKey: .userIsSubscriber)
    disableContributorRequests = try container.decode(Bool.self, forKey: .disableContributorRequests)
    submitTextLabel = try container.decode(String.self, forKey: .submitTextLabel)
    linkFlairPosition = try container.decode(String.self, forKey: .linkFlairPosition)
    linkFlairEnabled = try container.decode(Bool.self, forKey: .linkFlairEnabled)
    subredditType = try container.decode(Subreddit.SubredditType.self, forKey: .subredditType)
    showMedia = try container.decode(Bool.self, forKey: .showMedia)
    userIsModerator = try container.decode(Bool.self, forKey: .userIsModerator)
    over18 = try container.decode(Bool.self, forKey: .over18)
    submitLinkLabel = try container.decode(String.self, forKey: .submitLinkLabel)
    restrictCommenting = try container.decode(Bool.self, forKey: .restrictCommenting)
    url = try container.decode(URL.self, forKey: .url)
    bannerSize = try container.decodeIfPresent([Int].self, forKey: .bannerSize)
    userIsContributor = try container.decode(Bool.self, forKey: .userIsContributor)
  }

  // MARK: Public

  public let defaultSet: Bool
  public let userIsContributor: Bool
  public let bannerImg: URL?
  public let restrictPosting: Bool
  public let userIsBanned: Bool
  public let freeFormReports: Bool
  public let communityIcon: URL?
  public let showMedia: Bool
  public let iconColor: String
  public let userIsMuted: Bool
  public let displayName: String
  public let headerImg: URL?
  public let title: String
  public let over18: Bool
  public let iconSize: [Int]
  public let primaryColor: String
  public let iconImg: URL
  public let submitLinkLabel: String
  public let headerSize: [Int]?
  public let restrictCommenting: Bool
  public let subscribers: Int
  public let submitTextLabel: String
  public let isDefaultIcon: Bool
  public let linkFlairPosition: String
  public let displayNamePrefixed: String
  public let keyColor: String
  public let name: Fullname
  public let id: ID36
  public let isDefaultBanner: Bool
  public let url: URL
  public let bannerSize: [Int]?
  public let userIsModerator: Bool
  public let publicDescription: String
  public let linkFlairEnabled: Bool
  public let disableContributorRequests: Bool
  public let subredditType: Subreddit.SubredditType
  public let userIsSubscriber: Bool

  public static func == (lhs: AccountSubreddit, rhs: AccountSubreddit) -> Bool {
    lhs.name == rhs.name
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(name)
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case defaultSet = "default_set"
    case userIsContributor = "user_is_contributor"
    case bannerImg = "banner_img"
    case restrictPosting = "restrict_posting"
    case userIsBanned = "user_is_banned"
    case freeFormReports = "free_form_reports"
    case communityIcon = "community_icon"
    case showMedia = "show_media"
    case iconColor = "icon_color"
    case userIsMuted = "user_is_muted"
    case displayName = "display_name"
    case headerImg = "header_img"
    case title
    case over18 = "over_18"
    case iconSize = "icon_size"
    case primaryColor = "primary_color"
    case iconImg = "icon_img"
    case submitLinkLabel = "submit_link_label"
    case headerSize = "header_size"
    case restrictCommenting = "restrict_commenting"
    case subscribers
    case submitTextLabel = "submit_text_label"
    case isDefaultIcon = "is_default_icon"
    case linkFlairPosition = "link_flair_position"
    case displayNamePrefixed = "display_name_prefixed"
    case keyColor = "key_color"
    case name
    case isDefaultBanner = "is_default_banner"
    case url
    case bannerSize = "banner_size"
    case userIsModerator = "user_is_moderator"
    case publicDescription = "public_description"
    case linkFlairEnabled = "link_flair_enabled"
    case disableContributorRequests = "disable_contributor_requests"
    case subredditType = "subreddit_type"
    case userIsSubscriber = "user_is_subscriber"
  }
}
