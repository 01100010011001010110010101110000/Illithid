//
// Account.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 3/21/20
//

import Foundation

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
    case isEmployee
    case seenLayoutSwitch
    case hasVisitedNewProfile
    case prefNoProfanity
    case hasExternalAccount
    case prefGeopopular
    case seenRedesignModal
    case prefShowTrending
    case subreddit
    case isSponsor
    case goldExpiration
    case hasGoldSubscription
    case numFriends
    case hasAndroidSubscription
    case verified
    case prefAutoplay
    case coins
    case hasPaypalSubscription
    case hasSubscribedToPremium
    case id
    case hasStripeSubscription
    case seenPremiumAdblockModal
    case canCreateSubreddit
    case over18
    case isGold
    case isMod
    case suspensionExpirationUtc
    case hasVerifiedEmail
    case isSuspended
    case prefVideoAutoplay
    case inRedesignBeta
    case iconImg
    case prefNightmode
    case oauthClientId
    case hideFromRobots
    case linkKarma
    case forcePasswordReset
    case seenGiveAwardTooltip
    case inboxCount
    case prefTopKarmaSubreddits
    case prefShowSnoovatar
    case name
    case prefClickgadget
    case created
    case goldCreddits
    case createdUtc
    case hasIosSubscription
    case prefShowTwitter
    case inBeta
    case commentKarma
    case hasSubscribed
    case seenSubredditChatFtux
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

  public var id: String {
    name
  }

  public let defaultSet: Bool
  public let userIsContributor: Bool
  public let bannerImg: RedditURL
  public let restrictPosting: Bool
  public let userIsBanned: Bool
  public let freeFormReports: Bool
  public let communityIcon: String
  public let showMedia: Bool
  public let iconColor: String
  public let userIsMuted: Bool
  public let displayName: String
  public let headerImg: URL?
  public let title: String
  public let coins: Int?
  public let over18: Bool
  public let iconSize: [Int]
  public let primaryColor: String
  public let iconImg: URL
  public let userSubredditDescription: String?
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
  public let isDefaultBanner: Bool
  public let url: URL
  public let bannerSize: [Int]?
  public let userIsModerator: Bool
  public let publicDescription: String
  public let linkFlairEnabled: Bool
  public let disableContributorRequests: Bool
  public let subredditType: String
  public let userIsSubscriber: Bool

  enum CodingKeys: String, CodingKey {
    case defaultSet
    case userIsContributor
    case bannerImg
    case restrictPosting
    case userIsBanned
    case freeFormReports
    case communityIcon
    case showMedia
    case iconColor
    case userIsMuted
    case displayName
    case headerImg
    case title
    case coins
    case over18
    case iconSize
    case primaryColor
    case iconImg
    case userSubredditDescription
    case submitLinkLabel
    case headerSize
    case restrictCommenting
    case subscribers
    case submitTextLabel
    case isDefaultIcon
    case linkFlairPosition
    case displayNamePrefixed
    case keyColor
    case name
    case isDefaultBanner
    case url
    case bannerSize
    case userIsModerator
    case publicDescription
    case linkFlairEnabled
    case disableContributorRequests
    case subredditType
    case userIsSubscriber
  }
}
