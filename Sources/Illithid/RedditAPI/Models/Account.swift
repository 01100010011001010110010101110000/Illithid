//
// Account.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 3/21/20
//

import Foundation

/// A Reddit account
/// - Note: Many proprties are nullable because they are only visible when logged in as that account
public struct Account: RedditObject, Codable {
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

  private enum WrapperKeys: String, CodingKey {
    case kind
    case data
  }

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
}

public struct AccountSubreddit: Codable, Hashable, Identifiable {
  public static func == (lhs: AccountSubreddit, rhs: AccountSubreddit) -> Bool {
    lhs.name == rhs.name
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(name)
  }

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
  public let created: Date
  public let createdUtc: Date
  public let isDefaultBanner: Bool
  public let url: URL
  public let bannerSize: [Int]?
  public let userIsModerator: Bool
  public let publicDescription: String
  public let linkFlairEnabled: Bool
  public let disableContributorRequests: Bool
  public let subredditType: Subreddit.SubredditType
  public let userIsSubscriber: Bool

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
    id = try container.decode(ID36.self, forKey: .id)
    userIsModerator = try container.decode(Bool.self, forKey: .userIsModerator)
    over18 = try container.decode(Bool.self, forKey: .over18)
    submitLinkLabel = try container.decode(String.self, forKey: .submitLinkLabel)
    restrictCommenting = try container.decode(Bool.self, forKey: .restrictCommenting)
    url = try container.decode(URL.self, forKey: .url)
    created = try container.decode(Date.self, forKey: .created)
    createdUtc = try container.decode(Date.self, forKey: .createdUtc)
    bannerSize = try container.decodeIfPresent([Int].self, forKey: .bannerSize)
    userIsContributor = try container.decode(Bool.self, forKey: .userIsContributor)
  }

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
    case over18
    case iconSize = "icon_size"
    case primaryColor = "primary_color"
    case created
    case createdUtc = "created_utc"
    case iconImg = "icon_img"
    case submitLinkLabel = "submit_link_label"
    case headerSize = "header_size"
    case restrictCommenting = "restrict_commenting"
    case subscribers
    case submitTextLabel = "submit_text_label"
    case id
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
