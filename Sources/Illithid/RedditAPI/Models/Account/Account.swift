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

/// A Reddit account
/// - Note: Many proprties are nullable because they are only visible when logged in as that account
public struct Account: RedditObject, Codable {
  // MARK: Lifecycle

  public init(from decoder: Decoder) throws {
    let wrappedContainer = try? decoder.container(keyedBy: WrapperKeys.self)
    let nestedContainer = try? wrappedContainer?.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)

    let unwrappedContainer = try? decoder.container(keyedBy: CodingKeys.self)

    let workingContainer = nestedContainer != nil ? nestedContainer! : unwrappedContainer!

    isEmployee = try workingContainer.decode(Bool.self, forKey: .isEmployee)
    seenLayoutSwitch = try workingContainer.decodeIfPresent(Bool.self, forKey: .seenLayoutSwitch)
    hasVisitedNewProfile = try workingContainer.decodeIfPresent(Bool.self, forKey: .hasVisitedNewProfile)
    prefNoProfanity = try workingContainer.decodeIfPresent(Bool.self, forKey: .prefNoProfanity)
    hasExternalAccount = try workingContainer.decodeIfPresent(Bool.self, forKey: .hasExternalAccount)
    prefGeopopular = try workingContainer.decodeIfPresent(String.self, forKey: .prefGeopopular)
    seenRedesignModal = try workingContainer.decodeIfPresent(Bool.self, forKey: .seenRedesignModal)
    prefShowTrending = try workingContainer.decodeIfPresent(Bool.self, forKey: .prefShowTrending)
    subreddit = try workingContainer.decode(AccountSubreddit.self, forKey: .subreddit)
    isSponsor = try workingContainer.decodeIfPresent(Bool.self, forKey: .isSponsor)
    goldExpiration = try workingContainer.decodeIfPresent(Date.self, forKey: .goldExpiration)
    hasGoldSubscription = try workingContainer.decodeIfPresent(Bool.self, forKey: .hasGoldSubscription)
    numFriends = try workingContainer.decodeIfPresent(Int.self, forKey: .numFriends)
    hasAndroidSubscription = try workingContainer.decodeIfPresent(Bool.self, forKey: .hasAndroidSubscription)
    verified = try workingContainer.decode(Bool.self, forKey: .verified)
    prefAutoplay = try workingContainer.decodeIfPresent(Bool.self, forKey: .prefAutoplay)
    coins = try workingContainer.decodeIfPresent(Int.self, forKey: .coins)
    hasPaypalSubscription = try workingContainer.decodeIfPresent(Bool.self, forKey: .hasPaypalSubscription)
    hasSubscribedToPremium = try workingContainer.decodeIfPresent(Bool.self, forKey: .hasSubscribedToPremium)
    id = try workingContainer.decode(ID36.self, forKey: .id)
    hasStripeSubscription = try workingContainer.decodeIfPresent(Bool.self, forKey: .hasStripeSubscription)
    seenPremiumAdblockModal = try workingContainer.decodeIfPresent(Bool.self, forKey: .seenPremiumAdblockModal)
    canCreateSubreddit = try workingContainer.decodeIfPresent(Bool.self, forKey: .canCreateSubreddit)
    over18 = try workingContainer.decodeIfPresent(Bool.self, forKey: .over18)
    isGold = try workingContainer.decode(Bool.self, forKey: .isGold)
    isMod = try workingContainer.decode(Bool.self, forKey: .isMod)
    suspensionExpirationUtc = try workingContainer.decodeIfPresent(Date.self, forKey: .suspensionExpirationUtc)
    hasVerifiedEmail = try workingContainer.decode(Bool.self, forKey: .hasVerifiedEmail)
    isSuspended = try workingContainer.decodeIfPresent(Bool.self, forKey: .isSuspended)
    prefVideoAutoplay = try workingContainer.decodeIfPresent(Bool.self, forKey: .prefVideoAutoplay)
    inRedesignBeta = try workingContainer.decodeIfPresent(Bool.self, forKey: .inRedesignBeta)
    iconImg = try workingContainer.decode(URL.self, forKey: .iconImg)
    prefNightmode = try workingContainer.decodeIfPresent(Bool.self, forKey: .prefNightmode)
    oauthClientId = try workingContainer.decodeIfPresent(String.self, forKey: .oauthClientId)
    hideFromRobots = try workingContainer.decode(Bool.self, forKey: .hideFromRobots)
    linkKarma = try workingContainer.decode(Int.self, forKey: .linkKarma)
    forcePasswordReset = try workingContainer.decodeIfPresent(Bool.self, forKey: .forcePasswordReset)
    seenGiveAwardTooltip = try workingContainer.decodeIfPresent(Bool.self, forKey: .seenGiveAwardTooltip)
    inboxCount = try workingContainer.decodeIfPresent(Int.self, forKey: .inboxCount)
    prefTopKarmaSubreddits = try workingContainer.decodeIfPresent(Bool.self, forKey: .prefTopKarmaSubreddits)
    prefShowSnoovatar = try workingContainer.decodeIfPresent(Bool.self, forKey: .prefShowSnoovatar)
    name = try workingContainer.decode(String.self, forKey: .name)
    prefClickgadget = try workingContainer.decodeIfPresent(Int.self, forKey: .prefClickgadget)
    created = try workingContainer.decode(Date.self, forKey: .created)
    goldCreddits = try workingContainer.decodeIfPresent(Int.self, forKey: .goldCreddits)
    createdUtc = try workingContainer.decode(Date.self, forKey: .createdUtc)
    hasIosSubscription = try workingContainer.decodeIfPresent(Bool.self, forKey: .hasIosSubscription)
    prefShowTwitter = try workingContainer.decodeIfPresent(Bool.self, forKey: .prefShowTwitter)
    inBeta = try workingContainer.decodeIfPresent(Bool.self, forKey: .inBeta)
    commentKarma = try workingContainer.decode(Int.self, forKey: .commentKarma)
    hasSubscribed = try workingContainer.decode(Bool.self, forKey: .hasSubscribed)
    seenSubredditChatFtux = try workingContainer.decodeIfPresent(Bool.self, forKey: .seenSubredditChatFtux)
  }

  // MARK: Public

  public let isEmployee: Bool
  public let seenLayoutSwitch: Bool?
  public let hasVisitedNewProfile: Bool?
  public let prefNoProfanity: Bool?
  public let hasExternalAccount: Bool?
  public let prefGeopopular: String?
  public let seenRedesignModal: Bool?
  public let prefShowTrending: Bool?
  public let subreddit: AccountSubreddit
  public let isSponsor: Bool?
  public let goldExpiration: Date?
  public let hasGoldSubscription: Bool?
  public let numFriends: Int?
  public let hasAndroidSubscription: Bool?
  public let verified: Bool
  public let prefAutoplay: Bool?
  public let coins: Int?
  public let hasPaypalSubscription: Bool?
  public let hasSubscribedToPremium: Bool?
  public let id: String
  public let hasStripeSubscription: Bool?
  public let seenPremiumAdblockModal: Bool?
  public let canCreateSubreddit: Bool?
  public let over18: Bool?
  public let isGold: Bool
  public let isMod: Bool
  public let suspensionExpirationUtc: Date?
  public let hasVerifiedEmail: Bool
  public let isSuspended: Bool?
  public let prefVideoAutoplay: Bool?
  public let inRedesignBeta: Bool?
  public let iconImg: URL
  public let prefNightmode: Bool?
  public let oauthClientId: String?
  public let hideFromRobots: Bool
  public let linkKarma: Int
  public let forcePasswordReset: Bool?
  public let seenGiveAwardTooltip: Bool?
  public let inboxCount: Int?
  public let prefTopKarmaSubreddits: Bool?
  public let prefShowSnoovatar: Bool?
  public let name: String
  public let prefClickgadget: Int?
  public let created: Date
  public let goldCreddits: Int?
  public let createdUtc: Date
  public let hasIosSubscription: Bool?
  public let prefShowTwitter: Bool?
  public let inBeta: Bool?
  public let commentKarma: Int
  public let hasSubscribed: Bool
  public let seenSubredditChatFtux: Bool?

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case isEmployee = "is_employee"
    case seenLayoutSwitch = "seen_layout_switch"
    case hasVisitedNewProfile = "has_visited_new_profile"
    case prefNoProfanity = "pref_no_profanity"
    case hasExternalAccount = "has_external_account"
    case prefGeopopular = "pref_geopopular"
    case seenRedesignModal = "seen_redesign_modal"
    case prefShowTrending = "pref_show_trending"
    case subreddit
    case isSponsor = "is_sponsor"
    case goldExpiration = "gold_expiration"
    case hasGoldSubscription = "has_gold_subscription"
    case numFriends = "num_friends"
    case hasAndroidSubscription = "has_android_subscription"
    case verified
    case prefAutoplay = "pref_autoplay"
    case coins
    case hasPaypalSubscription = "has_paypal_subscription"
    case hasSubscribedToPremium = "has_subscribed_to_premium"
    case id
    case hasStripeSubscription = "has_stripe_subscription"
    case seenPremiumAdblockModal = "seen_premium_adblock_modal"
    case canCreateSubreddit = "can_create_subreddit"
    case over18 = "over_18"
    case isGold = "is_gold"
    case isMod = "is_mod"
    case suspensionExpirationUtc = "suspension_expiration_utc"
    case hasVerifiedEmail = "has_verified_email"
    case isSuspended = "is_suspended"
    case prefVideoAutoplay = "pref_video_autoplay"
    case inRedesignBeta = "in_redesign_beta"
    case iconImg = "icon_img"
    case prefNightmode = "pref_nightmode"
    case oauthClientId = "oauth_client_id"
    case hideFromRobots = "hide_from_robots"
    case linkKarma = "link_karma"
    case forcePasswordReset = "force_password_reset"
    case seenGiveAwardTooltip = "seen_give_award_tooltip"
    case inboxCount = "inbox_count"
    case prefTopKarmaSubreddits = "pref_top_karma_subreddits"
    case prefShowSnoovatar = "pref_show_snoovatar"
    case name
    case prefClickgadget = "pref_clickgadget"
    case created
    case goldCreddits = "gold_creddits"
    case createdUtc = "created_utc"
    case hasIosSubscription = "has_ios_subscription"
    case prefShowTwitter = "pref_show_twitter"
    case inBeta = "in_beta"
    case commentKarma = "comment_karma"
    case hasSubscribed = "has_subscribed"
    case seenSubredditChatFtux = "seen_subreddit_chat_ftux"
  }

  // MARK: Private

  private enum WrapperKeys: String, CodingKey {
    case kind
    case data
  }
}
