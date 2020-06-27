//
// Subreddit.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 6/26/20
//

import Cocoa
import Combine
import Foundation

import Alamofire

public enum SubredditSort {
  case popular
  case new
  case gold
  case `default`
}

public struct Subreddit: RedditObject {
  public let userFlairBackgroundColor: String?
  public let submitTextHtml: String?
  public let restrictPosting: Bool
  public let userIsBanned: Bool
  public let freeFormReports: Bool
  public let wikiEnabled: Bool
  public let userIsMuted: Bool
  public let userCanFlairInSr: Bool
  public let displayName: String
  public let headerImg: URL?
  public let title: String
  public let allowGalleries: Bool
  public let iconSize: [Int]?
  public let primaryColor: String
  public let activeUserCount: Int?
  public let iconImg: URL?
  public let displayNamePrefixed: String
  public let accountsActive: Int?
  public let publicTraffic: Bool
  public let subscribers: Int
  public let userFlairRichtext: [String]
  public let videostreamLinksCount: Int?
  public let name: Fullname
  public let quarantine: Bool
  public let hideAds: Bool
  public let emojisEnabled: Bool
  public let advertiserCategory: String
  public let description: String?
  public let publicDescription: String
  public let commentScoreHideMins: Int
  public let userHasFavorited: Bool
  public let userFlairTemplateId: UUID?
  public let communityIcon: URL?
  public let bannerBackgroundImage: URL?
  public let originalContentTagEnabled: Bool
  public let submitText: String
  public let descriptionHtml: String?
  public let spoilersEnabled: Bool
  public let headerTitle: String?
  public let headerSize: [Int]?
  public let userFlairPosition: String
  public let allOriginalContent: Bool
  public let hasMenuWidget: Bool
  public let isEnrolledInNewModmail: Bool?
  public let keyColor: String
  public let canAssignUserFlair: Bool
  public let created: Date
  public let wls: Int?
  public let showMediaPreview: Bool
  public let submissionType: SubmissionType
  public let userIsSubscriber: Bool
  public let disableContributorRequests: Bool
  public let allowVideogifs: Bool
  public let userFlairType: String
  public let allowPolls: Bool
  public let collapseDeletedComments: Bool
  public let emojisCustomSize: [Int]?
  public let publicDescriptionHtml: String?
  public let allowVideos: Bool
  public let isCrosspostableSubreddit: Bool
  public let notificationLevel: NotificationLevel
  public let canAssignLinkFlair: Bool
  public let accountsActiveIsFuzzed: Bool
  public let submitTextLabel: String?
  public let linkFlairPosition: String?
  public let userSrFlairEnabled: Bool
  public let userFlairEnabledInSr: Bool
  public let allowDiscovery: Bool
  public let userSrThemeEnabled: Bool
  public let linkFlairEnabled: Bool
  public let subredditType: SubredditType
  public let suggestedCommentSort: CommentsSort?
  public let bannerImg: URL?
  public let userFlairText: String?
  public let bannerBackgroundColor: String
  public let showMedia: Bool
  public let id: ID36
  public let userIsModerator: Bool
  public let over18: Bool?
  public let submitLinkLabel: String?
  public let userFlairTextColor: String?
  public let restrictCommenting: Bool
  public let userFlairCssClass: String?
  public let allowImages: Bool
  public let lang: String
  public let whitelistStatus: WhitelistStatus?
  public let url: URL
  public let createdUtc: Date
  public let bannerSize: [Int]?
  public let mobileBannerImage: URL?
  public let userIsContributor: Bool?

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    // For certain bool properties, Reddit returns null to indicate false
    wikiEnabled = try container.decodeIfPresent(Bool.self, forKey: .wikiEnabled) ?? false
    userCanFlairInSr = try container.decodeIfPresent(Bool.self, forKey: .userCanFlairInSr) ?? false
    userSrFlairEnabled = try container.decodeIfPresent(Bool.self, forKey: .userSrFlairEnabled) ?? false
    isCrosspostableSubreddit = try container.decodeIfPresent(Bool.self, forKey: .isCrosspostableSubreddit) ?? false

    // When a URL property does not exist, Reddit returns the empty string
    headerImg = try? container.decode(URL.self, forKey: .headerImg)
    iconImg = try? container.decode(URL.self, forKey: .iconImg)
    communityIcon = try? container.decode(URL.self, forKey: .communityIcon)
    bannerBackgroundImage = try? container.decode(URL.self, forKey: .bannerBackgroundImage)
    bannerImg = try? container.decode(URL.self, forKey: .bannerImg)
    mobileBannerImage = try? container.decode(URL.self, forKey: .mobileBannerImage)

    userFlairBackgroundColor = try container.decodeIfPresent(String.self, forKey: .userFlairBackgroundColor)
    submitTextHtml = try container.decodeIfPresent(String.self, forKey: .submitTextHtml)
    restrictPosting = try container.decode(Bool.self, forKey: .restrictPosting)
    userIsBanned = try container.decode(Bool.self, forKey: .userIsBanned)
    freeFormReports = try container.decode(Bool.self, forKey: .freeFormReports)
    userIsMuted = try container.decode(Bool.self, forKey: .userIsMuted)
    displayName = try container.decode(String.self, forKey: .displayName)
    title = try container.decode(String.self, forKey: .title)
    allowGalleries = try container.decode(Bool.self, forKey: .allowGalleries)
    iconSize = try container.decodeIfPresent([Int].self, forKey: .iconSize)
    primaryColor = try container.decode(String.self, forKey: .primaryColor)
    activeUserCount = try container.decodeIfPresent(Int.self, forKey: .activeUserCount)
    displayNamePrefixed = try container.decode(String.self, forKey: .displayNamePrefixed)
    accountsActive = try container.decodeIfPresent(Int.self, forKey: .accountsActive)
    publicTraffic = try container.decode(Bool.self, forKey: .publicTraffic)
    subscribers = try container.decode(Int.self, forKey: .subscribers)
    userFlairRichtext = try container.decode([String].self, forKey: .userFlairRichtext)
    videostreamLinksCount = try container.decodeIfPresent(Int.self, forKey: .videostreamLinksCount)
    name = try container.decode(Fullname.self, forKey: .name)
    quarantine = try container.decode(Bool.self, forKey: .quarantine)
    hideAds = try container.decode(Bool.self, forKey: .hideAds)
    emojisEnabled = try container.decode(Bool.self, forKey: .emojisEnabled)
    advertiserCategory = try container.decode(String.self, forKey: .advertiserCategory)
    description = try container.decodeIfPresent(String.self, forKey: .description)
    publicDescription = try container.decode(String.self, forKey: .publicDescription)
    commentScoreHideMins = try container.decode(Int.self, forKey: .commentScoreHideMins)
    userHasFavorited = try container.decode(Bool.self, forKey: .userHasFavorited)
    userFlairTemplateId = try container.decodeIfPresent(UUID.self, forKey: .userFlairTemplateId)
    originalContentTagEnabled = try container.decode(Bool.self, forKey: .originalContentTagEnabled)
    submitText = try container.decode(String.self, forKey: .submitText)
    descriptionHtml = try container.decodeIfPresent(String.self, forKey: .descriptionHtml)
    spoilersEnabled = try container.decode(Bool.self, forKey: .spoilersEnabled)
    headerTitle = try container.decodeIfPresent(String.self, forKey: .headerTitle)
    headerSize = try container.decodeIfPresent([Int].self, forKey: .headerSize)
    userFlairPosition = try container.decode(String.self, forKey: .userFlairPosition)
    allOriginalContent = try container.decode(Bool.self, forKey: .allOriginalContent)
    hasMenuWidget = try container.decode(Bool.self, forKey: .hasMenuWidget)
    isEnrolledInNewModmail = try container.decodeIfPresent(Bool.self, forKey: .isEnrolledInNewModmail)
    keyColor = try container.decode(String.self, forKey: .keyColor)
    canAssignUserFlair = try container.decode(Bool.self, forKey: .canAssignUserFlair)
    created = try container.decode(Date.self, forKey: .created)
    wls = try container.decodeIfPresent(Int.self, forKey: .wls)
    showMediaPreview = try container.decode(Bool.self, forKey: .showMediaPreview)
    submissionType = try container.decode(SubmissionType.self, forKey: .submissionType)
    userIsSubscriber = try container.decode(Bool.self, forKey: .userIsSubscriber)
    disableContributorRequests = try container.decode(Bool.self, forKey: .disableContributorRequests)
    allowVideogifs = try container.decode(Bool.self, forKey: .allowVideogifs)
    userFlairType = try container.decode(String.self, forKey: .userFlairType)
    allowPolls = try container.decode(Bool.self, forKey: .allowPolls)
    collapseDeletedComments = try container.decode(Bool.self, forKey: .collapseDeletedComments)
    emojisCustomSize = try container.decodeIfPresent([Int].self, forKey: .emojisCustomSize)
    publicDescriptionHtml = try container.decodeIfPresent(String.self, forKey: .publicDescriptionHtml)
    allowVideos = try container.decode(Bool.self, forKey: .allowVideos)
    notificationLevel = try container.decode(NotificationLevel.self, forKey: .notificationLevel)
    canAssignLinkFlair = try container.decode(Bool.self, forKey: .canAssignLinkFlair)
    accountsActiveIsFuzzed = try container.decode(Bool.self, forKey: .accountsActiveIsFuzzed)
    submitTextLabel = try container.decodeIfPresent(String.self, forKey: .submitTextLabel)
    linkFlairPosition = try container.decodeIfPresent(String.self, forKey: .linkFlairPosition)
    userFlairEnabledInSr = try container.decode(Bool.self, forKey: .userFlairEnabledInSr)
    allowDiscovery = try container.decode(Bool.self, forKey: .allowDiscovery)
    userSrThemeEnabled = try container.decode(Bool.self, forKey: .userSrThemeEnabled)
    linkFlairEnabled = try container.decode(Bool.self, forKey: .linkFlairEnabled)
    subredditType = try container.decode(SubredditType.self, forKey: .subredditType)
    suggestedCommentSort = try container.decodeIfPresent(CommentsSort.self, forKey: .suggestedCommentSort)
    userFlairText = try container.decodeIfPresent(String.self, forKey: .userFlairText)
    bannerBackgroundColor = try container.decode(String.self, forKey: .bannerBackgroundColor)
    showMedia = try container.decode(Bool.self, forKey: .showMedia)
    id = try container.decode(ID36.self, forKey: .id)
    userIsModerator = try container.decode(Bool.self, forKey: .userIsModerator)
    over18 = try container.decode(Bool.self, forKey: .over18)
    submitLinkLabel = try container.decodeIfPresent(String.self, forKey: .submitLinkLabel)
    userFlairTextColor = try container.decodeIfPresent(String.self, forKey: .userFlairTextColor)
    restrictCommenting = try container.decode(Bool.self, forKey: .restrictCommenting)
    userFlairCssClass = try container.decodeIfPresent(String.self, forKey: .userFlairCssClass)
    allowImages = try container.decode(Bool.self, forKey: .allowImages)
    lang = try container.decode(String.self, forKey: .lang)
    whitelistStatus = try container.decodeIfPresent(WhitelistStatus.self, forKey: .whitelistStatus)
    url = try container.decode(URL.self, forKey: .url)
    createdUtc = try container.decode(Date.self, forKey: .createdUtc)
    bannerSize = try container.decodeIfPresent([Int].self, forKey: .bannerSize)
    userIsContributor = try container.decode(Bool.self, forKey: .userIsContributor)
  }

  private enum CodingKeys: String, CodingKey {
    case userFlairBackgroundColor = "user_flair_background_color"
    case submitTextHtml = "submit_text_html"
    case restrictPosting = "restrict_posting"
    case userIsBanned = "user_is_banned"
    case freeFormReports = "free_form_reports"
    case wikiEnabled = "wiki_enabled"
    case userIsMuted = "user_is_muted"
    case userCanFlairInSr = "user_can_flair_in_sr"
    case displayName = "display_name"
    case headerImg = "header_img"
    case title
    case allowGalleries = "allow_galleries"
    case iconSize = "icon_size"
    case primaryColor = "primary_color"
    case activeUserCount = "active_user_count"
    case iconImg = "icon_img"
    case displayNamePrefixed = "display_name_prefixed"
    case accountsActive = "accounts_active"
    case publicTraffic = "public_traffic"
    case subscribers
    case userFlairRichtext = "user_flair_richtext"
    case videostreamLinksCount = "videostream_links_count"
    case name
    case quarantine
    case hideAds = "hide_ads"
    case emojisEnabled = "emojis_enabled"
    case advertiserCategory = "advertiser_category"
    case description
    case publicDescription = "public_description"
    case commentScoreHideMins = "comment_score_hide_mins"
    case userHasFavorited = "user_has_favorited"
    case userFlairTemplateId = "user_flair_template_id"
    case communityIcon = "community_icon"
    case bannerBackgroundImage = "banner_background_image"
    case originalContentTagEnabled = "original_content_tag_enabled"
    case submitText = "submit_text"
    case descriptionHtml = "description_html"
    case spoilersEnabled = "spoilers_enabled"
    case headerTitle = "header_title"
    case headerSize = "header_size"
    case userFlairPosition = "user_flair_position"
    case allOriginalContent = "all_original_content"
    case hasMenuWidget = "has_menu_widget"
    case isEnrolledInNewModmail = "is_enrolled_in_new_modmail"
    case keyColor = "key_color"
    case canAssignUserFlair = "can_assign_user_flair"
    case created
    case wls
    case showMediaPreview = "show_media_preview"
    case submissionType = "submission_type"
    case userIsSubscriber = "user_is_subscriber"
    case disableContributorRequests = "disable_contributor_requests"
    case allowVideogifs = "allow_videogifs"
    case userFlairType = "user_flair_type"
    case allowPolls = "allow_polls"
    case collapseDeletedComments = "collapse_deleted_comments"
    case emojisCustomSize = "emojis_custom_size"
    case publicDescriptionHtml = "public_description_html"
    case allowVideos = "allow_videos"
    case isCrosspostableSubreddit = "is_crosspostable_subreddit"
    case notificationLevel = "notification_level"
    case canAssignLinkFlair = "can_assign_link_flair"
    case accountsActiveIsFuzzed = "accounts_active_is_fuzzed"
    case submitTextLabel = "submit_text_label"
    case linkFlairPosition = "link_flair_position"
    case userSrFlairEnabled = "user_sr_flair_enabled"
    case userFlairEnabledInSr = "user_flair_enabled_in_sr"
    case allowDiscovery = "allow_discovery"
    case userSrThemeEnabled = "user_sr_theme_enabled"
    case linkFlairEnabled = "link_flair_enabled"
    case subredditType = "subreddit_type"
    case suggestedCommentSort = "suggested_comment_sort"
    case bannerImg = "banner_img"
    case userFlairText = "user_flair_text"
    case bannerBackgroundColor = "banner_background_color"
    case showMedia = "show_media"
    case id
    case userIsModerator = "user_is_moderator"
    case over18
    case submitLinkLabel = "submit_link_label"
    case userFlairTextColor = "user_flair_text_color"
    case restrictCommenting = "restrict_commenting"
    case userFlairCssClass = "user_flair_css_class"
    case allowImages = "allow_images"
    case lang
    case whitelistStatus = "whitelist_status"
    case url
    case createdUtc = "created_utc"
    case bannerSize = "banner_size"
    case mobileBannerImage = "mobile_banner_image"
    case userIsContributor = "user_is_contributor"
  }
}

public extension Subreddit {
  /// The type of submission allowed by a subreddit
  enum SubmissionType: String, Codable {
    case any
    case link
    case `self`
  }

  enum NotificationLevel: String, Codable {
    case low
  }

  enum WhitelistStatus: String, Codable {
    case allAds = "all_ads"
    case someAds = "some_ads"
    case noAds = "no_ads"
    case promoAll = "promo_all"
    case promoAdultNsfw = "promo_adult_nsfw"
    case houseOnly = "house_only"
  }

  enum SubredditType: String, Codable {
    case user
    case `public`
    case restricted
    case `private`
    case employeesOnly = "employees_only"
  }
}
