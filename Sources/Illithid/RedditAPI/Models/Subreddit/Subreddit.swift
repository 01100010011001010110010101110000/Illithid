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
  /// The HTML formatted text that appears when submitting a new post to this subreddit
  /// - Note: `nil` if the subreddit is private and the current user does not have access, or if no submission text has been defined
  public let submitTextHtml: String?
  /// Whether posting in the subreddit is restricted to approved users
  /// - Note: `nil` if the subreddit is private and the current user does not have access
  public let restrictPosting: Bool?
  /// Whether the current user is banned from the subreddit
  /// - Note: `nil` if the subreddit is private and the current user does not have access
  public let userIsBanned: Bool?
  /// Whether the subreddit allows custom report messages
  /// - Note: `nil` if the subreddit is private and the current user context does not have access
  public let freeFormReports: Bool?
  /// Whether the current user can edit the subreddit's wiki
  /// - Note: `nil` if the subreddit is private and the current user context does not have access
  public let wikiEnabled: Bool?
  /// Whether the current user is muted in the subreddit
  /// - Note: `nil` if the subreddit is private and the current user context does not have access
  public let userIsMuted: Bool?
  /// Whether the current user can set user flairs in the subreddit
  /// - Note: `nil` if the subreddit is private and the current user context does not have access
  public let userCanFlairInSr: Bool?
  public let displayName: String
  public let headerImg: URL?
  public let title: String
  /// Whether the subreddit allows image gallery posts
  /// - Note: `nil` if the subreddit is private and the current user context does not have access
  public let allowGalleries: Bool?
  public let iconSize: [Int]?
  /// The hex triplet color code of the subreddit's primary color
  /// - Note: `nil` if the subreddit is private and the current user context does not have access
  public let primaryColor: String?
  public let activeUserCount: Int?
  public let iconImg: URL?
  public let displayNamePrefixed: String
  public let accountsActive: Int?
  /// Whether this subreddit exposes its traffic statistics publicly
  /// - Note: `nil` if the subreddit is private and the current user context does not have access
  public let publicTraffic: Bool?
  /// This subreddit's subscriber count
  /// - Note: `nil` if the subreddit is private and the current user context does not have access
  public let subscribers: Int?
  public let userFlairRichtext: [String]
  public let videostreamLinksCount: Int?
  public let name: Fullname
  /// Whether this subreddit is quarantined
  /// - Note: `nil` if the subreddit is private and the current user context does not have access
  public let quarantine: Bool?
  /// Whether this subreddit suppresses advertisements
  /// - Note: `nil` if the subreddit is private and the current user context does not have access
  public let hideAds: Bool?
  public let emojisEnabled: Bool
  /// The advertiser category this subreddit falls into, if any
  /// - Note: `nil` if the subreddit is private and the current user context does not have access
  public let advertiserCategory: String?
  public let description: String?
  public let publicDescription: String
  /// The number of minutes to hide the score of a new comment
  /// - Note: `nil` if the subreddit is private and the current user context does not have access
  public let commentScoreHideMins: Int?
  /// Whether the current user has favorited the subreddit
  /// - Note: `nil` if the subreddit is private and the current user context does not have access
  public let userHasFavorited: Bool?
  public let userFlairTemplateId: UUID?
  public let communityIcon: URL?
  public let bannerBackgroundImage: URL?
  /// Whether the subreddit allows the use of the original content tag
  /// - Note: `nil` if the subreddit is private and the current user context does not have access
  public let originalContentTagEnabled: Bool?
  /// The text shown when creating a new submission for this subreddit
  /// - Note: `nil` if the subreddit is private and the current user context does not have access
  public let submitText: String?
  public let descriptionHtml: String?
  /// Whether the subreddit allows tagging posts as containing spoilers
  /// - Note: `nil` if the subreddit is private and the current user context does not have access
  public let spoilersEnabled: Bool?
  public let headerTitle: String?
  public let headerSize: [Int]?
  /// The subreddit's positioning of user flairs relative to the username
  /// - Note: Returns the empty string if user flair has not been configured
  /// - Note: `nil` if the subreddit is private and the current user context does not have access
  public let userFlairPosition: String?
  /// Whether the subreddit marks all submissions as original content
  /// - Note: `nil` if the subreddit is private and the current user context does not have access
  public let allOriginalContent: Bool?
  public let hasMenuWidget: Bool
  public let isEnrolledInNewModmail: Bool?
  /// The hex triplet color code of the subreddit's thematic color
  /// - Note: Returns the empty string if this is not configured
  /// - Note: `nil` if the subreddit is private and the current user context does not have access
  public let keyColor: String?
  public let canAssignUserFlair: Bool
  public let created: Date
  public let wls: Int?
  /// Whether the subreddit automatically shows expanded media previews on a submission's comments page
  /// - Note: `nil` if the subreddit is private and the current user context does not have access
  public let showMediaPreview: Bool?
  /// The types of submissions allowed on the subreddit
  /// - Note: `nil` if the subreddit is private and the current user context does not have access
  public let submissionType: SubmissionType?
  /// Whether the current user subscribes to the subreddit
  /// - Note: `nil` if the subreddit is private and the current user context does not have access
  public let userIsSubscriber: Bool?
  /// Whether the subreddit accepts new requests to be able to post in the subreddit.
  /// This is relevant for subreddits with a `subredditType` of `restricted`
  /// - Note: `nil` if the subreddit is private and the current user context does not have access
  public let disableContributorRequests: Bool?
  public let allowVideogifs: Bool
  public let userFlairType: String
  /// Whether the subreddit allows polls
  /// - Note: `nil` if the subreddit is private and the current user context does not have access
  public let allowPolls: Bool?
  /// Whether comments pages for posts in this subreddit automatically collapse deleted and removed comments
  /// - Note: `nil` if the subreddit is private and the current user context does not have access
  public let collapseDeletedComments: Bool?
  public let emojisCustomSize: [Int]?
  public let publicDescriptionHtml: String?
  public let allowVideos: Bool
  public let isCrosspostableSubreddit: Bool
  public let notificationLevel: NotificationLevel?
  public let canAssignLinkFlair: Bool
  /// Whether the number of active accounts on the subreddit has been altered by Reddit
  /// - Remark: This is done on subreddits a low number of current active users to prevent leaking users' activity information
  /// - Note: `nil` if the subreddit is private and the current user context does not have access
  public let accountsActiveIsFuzzed: Bool?
  /// The text presented when a new text post is being made
  /// - Note: `nil` if no text has been configured
  public let submitTextLabel: String?
  public let linkFlairPosition: String?
  /// Whether the current user has opted to display their user flair in this subreddit
  /// - Note: `nil` if any of the following are true
  /// * The current user has no flair
  /// * The current user has not indicated a display preference
  /// * The subreddit is private and the current user context does not have access
  public let userSrFlairEnabled: Bool?
  /// Whether the subreddit has enabled user flairs
  /// - Note: `nil` if the subreddit is private and the current user context does not have access
  public let userFlairEnabledInSr: Bool?
  /// Whether the subreddit allows users to be exposed to this subreddit after they have expressed interest via Reddit's onboarding process
  /// - Note: `nil` if the subreddit is private and the current user context does not have access
  public let allowDiscovery: Bool?
  /// Whether the current user allows this subreddit to show custom CSS
  /// - Note: `nil` if the subreddit is private and the current user context does not have access
  public let userSrThemeEnabled: Bool?
  /// Whether the subreddit allows post flairs
  /// - Note: `nil` if the subreddit is private and the current user context does not have access
  public let linkFlairEnabled: Bool?
  public let subredditType: SubredditType
  public let suggestedCommentSort: CommentsSort?
  public let bannerImg: URL?
  public let userFlairText: String?
  /// The hex triplet color code of the subreddit's banner background
  /// - Note: Returns the empty string if no value has been set
  /// - Note: `nil` if the subreddit is private and the current user context does not have access
  public let bannerBackgroundColor: String?
  /// Whether the subreddit shows media thumbnails
  /// - Note: `nil` if the subreddit is private and the current user context does not have access
  public let showMedia: Bool?
  public let id: ID36
  /// Whether the current user moderates the subreddit
  /// - Note: `nil` if the subreddit is private and the current user context does not have access
  public let userIsModerator: Bool?
  public let over18: Bool?
  public let submitLinkLabel: String?
  public let userFlairTextColor: String?
  /// Whether approved users have the ability to comment
  /// - Note: `nil` if the subreddit is private and the current user context does not have access
  public let restrictCommenting: Bool?
  public let userFlairCssClass: String?
  /// Whether the subreddit allows image posts
  /// - Note: `nil` if the subreddit is private and the current user context does not have access
  public let allowImages: Bool?
  /// The localization for the subreddit
  /// - Note: Returns the empty string if no locale is configured
  /// - Note: `nil` if the subreddit is private and the current user context does not have access
  public let lang: String?
  public let whitelistStatus: WhitelistStatus?
  public let url: URL
  public let createdUtc: Date
  public let bannerSize: [Int]?
  public let mobileBannerImage: URL?
  public let userIsContributor: Bool?

  public init(from decoder: Decoder) throws {
    let wrappedContainer = try? decoder.container(keyedBy: WrapperKeys.self)
    let nestedContainer = try? wrappedContainer?.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)

    let unwrappedContainer = try? decoder.container(keyedBy: CodingKeys.self)

    let container = nestedContainer != nil ? nestedContainer! : unwrappedContainer!

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
    restrictPosting = try container.decodeIfPresent(Bool.self, forKey: .restrictPosting)
    userIsBanned = try container.decodeIfPresent(Bool.self, forKey: .userIsBanned)
    freeFormReports = try container.decodeIfPresent(Bool.self, forKey: .freeFormReports)
    userIsMuted = try container.decodeIfPresent(Bool.self, forKey: .userIsMuted)
    displayName = try container.decode(String.self, forKey: .displayName)
    title = try container.decode(String.self, forKey: .title)
    allowGalleries = try container.decodeIfPresent(Bool.self, forKey: .allowGalleries)
    iconSize = try container.decodeIfPresent([Int].self, forKey: .iconSize)
    primaryColor = try container.decodeIfPresent(String.self, forKey: .primaryColor)
    activeUserCount = try container.decodeIfPresent(Int.self, forKey: .activeUserCount)
    displayNamePrefixed = try container.decode(String.self, forKey: .displayNamePrefixed)
    accountsActive = try container.decodeIfPresent(Int.self, forKey: .accountsActive)
    publicTraffic = try container.decodeIfPresent(Bool.self, forKey: .publicTraffic)
    subscribers = try container.decodeIfPresent(Int.self, forKey: .subscribers)
    userFlairRichtext = try container.decode([String].self, forKey: .userFlairRichtext)
    videostreamLinksCount = try container.decodeIfPresent(Int.self, forKey: .videostreamLinksCount)
    name = try container.decode(Fullname.self, forKey: .name)
    quarantine = try container.decodeIfPresent(Bool.self, forKey: .quarantine)
    hideAds = try container.decodeIfPresent(Bool.self, forKey: .hideAds)
    emojisEnabled = try container.decode(Bool.self, forKey: .emojisEnabled)
    advertiserCategory = try container.decodeIfPresent(String.self, forKey: .advertiserCategory)
    description = try container.decodeIfPresent(String.self, forKey: .description)
    publicDescription = try container.decode(String.self, forKey: .publicDescription)
    commentScoreHideMins = try container.decodeIfPresent(Int.self, forKey: .commentScoreHideMins)
    userHasFavorited = try container.decodeIfPresent(Bool.self, forKey: .userHasFavorited)
    userFlairTemplateId = try container.decodeIfPresent(UUID.self, forKey: .userFlairTemplateId)
    originalContentTagEnabled = try container.decodeIfPresent(Bool.self, forKey: .originalContentTagEnabled)
    submitText = try container.decodeIfPresent(String.self, forKey: .submitText)
    descriptionHtml = try container.decodeIfPresent(String.self, forKey: .descriptionHtml)
    spoilersEnabled = try container.decodeIfPresent(Bool.self, forKey: .spoilersEnabled)
    headerTitle = try container.decodeIfPresent(String.self, forKey: .headerTitle)
    headerSize = try container.decodeIfPresent([Int].self, forKey: .headerSize)
    userFlairPosition = try container.decodeIfPresent(String.self, forKey: .userFlairPosition)
    allOriginalContent = try container.decodeIfPresent(Bool.self, forKey: .allOriginalContent)
    hasMenuWidget = try container.decode(Bool.self, forKey: .hasMenuWidget)
    isEnrolledInNewModmail = try container.decodeIfPresent(Bool.self, forKey: .isEnrolledInNewModmail)
    keyColor = try container.decodeIfPresent(String.self, forKey: .keyColor)
    canAssignUserFlair = try container.decode(Bool.self, forKey: .canAssignUserFlair)
    created = try container.decode(Date.self, forKey: .created)
    wls = try container.decodeIfPresent(Int.self, forKey: .wls)
    showMediaPreview = try container.decodeIfPresent(Bool.self, forKey: .showMediaPreview)
    submissionType = try container.decodeIfPresent(SubmissionType.self, forKey: .submissionType)
    userIsSubscriber = try container.decodeIfPresent(Bool.self, forKey: .userIsSubscriber)
    disableContributorRequests = try container.decodeIfPresent(Bool.self, forKey: .disableContributorRequests)
    allowVideogifs = try container.decode(Bool.self, forKey: .allowVideogifs)
    userFlairType = try container.decode(String.self, forKey: .userFlairType)
    allowPolls = try container.decodeIfPresent(Bool.self, forKey: .allowPolls)
    collapseDeletedComments = try container.decodeIfPresent(Bool.self, forKey: .collapseDeletedComments)
    emojisCustomSize = try container.decodeIfPresent([Int].self, forKey: .emojisCustomSize)
    publicDescriptionHtml = try container.decodeIfPresent(String.self, forKey: .publicDescriptionHtml)
    allowVideos = try container.decode(Bool.self, forKey: .allowVideos)
    notificationLevel = try container.decodeIfPresent(NotificationLevel.self, forKey: .notificationLevel)
    canAssignLinkFlair = try container.decode(Bool.self, forKey: .canAssignLinkFlair)
    accountsActiveIsFuzzed = try container.decodeIfPresent(Bool.self, forKey: .accountsActiveIsFuzzed)
    submitTextLabel = try container.decodeIfPresent(String.self, forKey: .submitTextLabel)
    linkFlairPosition = try container.decodeIfPresent(String.self, forKey: .linkFlairPosition)
    userFlairEnabledInSr = try container.decodeIfPresent(Bool.self, forKey: .userFlairEnabledInSr)
    allowDiscovery = try container.decodeIfPresent(Bool.self, forKey: .allowDiscovery)
    userSrThemeEnabled = try container.decodeIfPresent(Bool.self, forKey: .userSrThemeEnabled)
    linkFlairEnabled = try container.decodeIfPresent(Bool.self, forKey: .linkFlairEnabled)
    subredditType = try container.decode(SubredditType.self, forKey: .subredditType)
    suggestedCommentSort = try container.decodeIfPresent(CommentsSort.self, forKey: .suggestedCommentSort)
    userFlairText = try container.decodeIfPresent(String.self, forKey: .userFlairText)
    bannerBackgroundColor = try container.decodeIfPresent(String.self, forKey: .bannerBackgroundColor)
    showMedia = try container.decodeIfPresent(Bool.self, forKey: .showMedia)
    id = try container.decode(ID36.self, forKey: .id)
    userIsModerator = try container.decodeIfPresent(Bool.self, forKey: .userIsModerator)
    over18 = try container.decodeIfPresent(Bool.self, forKey: .over18)
    submitLinkLabel = try container.decodeIfPresent(String.self, forKey: .submitLinkLabel)
    userFlairTextColor = try container.decodeIfPresent(String.self, forKey: .userFlairTextColor)
    restrictCommenting = try container.decodeIfPresent(Bool.self, forKey: .restrictCommenting)
    userFlairCssClass = try container.decodeIfPresent(String.self, forKey: .userFlairCssClass)
    allowImages = try container.decodeIfPresent(Bool.self, forKey: .allowImages)
    lang = try container.decodeIfPresent(String.self, forKey: .lang)
    whitelistStatus = try container.decodeIfPresent(WhitelistStatus.self, forKey: .whitelistStatus)
    url = try container.decode(URL.self, forKey: .url)
    createdUtc = try container.decode(Date.self, forKey: .createdUtc)
    bannerSize = try container.decodeIfPresent([Int].self, forKey: .bannerSize)
    userIsContributor = try container.decodeIfPresent(Bool.self, forKey: .userIsContributor)
  }

  private enum WrapperKeys: String, CodingKey {
    case kind
    case data
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
    case goldOnly = "gold_only"
    case goldRestricted = "gold_restricted"
    case archived
    case `public`
    case restricted
    case `private`
    case employeesOnly = "employees_only"
  }
}
