//
// Post.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 6/26/20
//

import Combine
import Foundation

import Alamofire

public enum VoteDirection: Int, Codable {
  case down = -1
  case clear = 0
  case up = 1
}

public enum PostSort: String, Codable, CaseIterable, Identifiable, Hashable {
  public var id: String {
    rawValue
  }

  case hot
  case best
  case new
  case random // This is in the API docs but seems to return a 404
  case rising
  case top
  case controversial
}

public enum PostHint: String, Codable {
  case link
  case `self`
  case image
  case richVideo
  case hostedVideo

  private enum CodingKeys: String, CodingKey {
    case link
    case `self`
    case image
    case richVideo = "rich:video"
    case hostedVideo = "hosted:video"
  }

  public init(from decoder: Decoder) throws {
    let value = try decoder.singleValueContainer().decode(String.self)
    switch value {
    case "rich:video":
      self = .richVideo
    case "hosted:video":
      self = .hostedVideo
    default:
      // Attempt to use string value
      if let postType = PostHint(rawValue: value) {
        self = postType
      } else {
        let context = EncodingError.Context(codingPath: decoder.codingPath,
                                            debugDescription: "Unknown hint type: \(value)")
        throw EncodingError.invalidValue(value, context)
      }
    }
  }
}

public struct Post: RedditObject {
  public static func == (lhs: Post, rhs: Post) -> Bool {
    lhs.name == rhs.name
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(name)
  }

  public let id: ID36
  public let name: Fullname

  public let subreddit: String
  /// The `Fullname` of the subreddit to which this post was submitted
  public let subredditId: Fullname
  public let subredditNamePrefixed: String

  public let selftext: String
  public let selftextHtml: String?
  public let secureMedia: PostMedia?
  public let media: PostMedia?
  public let domain: String

  public let title: String
  public let authorFullname: String?
  public let author: String
  public var authorPrefixed: String {
    "u/\(author)"
  }

  public let authorFlairTextColor: String?
  public let authorFlairText: String?
  public let authorFlairType: FlairType?
  public let authorFlairRichtext: [FlairRichtext]?
  public let linkFlairText: String?
  public let linkFlairType: FlairType?
  public let linkFlairRichtext: [FlairRichtext]?
  public let linkFlairTextColor: String?

  /// The string value returned by the Reddit API for the URL attribute
  private let url: String
  /// The computed `URL`, derived from `self.url`
  public var contentUrl: URL {
    if let unwrapped = URL(string: url) {
      return unwrapped
    } else {
      // This is ugly, but I will keep it for the time being under the assumption that non-encoded URLs are the only
      // pathological case for this property
      return URL(string: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
    }
  }

  public var postUrl: URL {
    URL(string: permalink, relativeTo: Illithid.shared.redditBrowserUrl)!
  }

  public var saved: Bool

  public let thumbnailHeight: Int?
  public let thumbnailWidth: Int?
  public let thumbnail: URL?

  public let preview: Preview?

  public let over18: Bool
  public let gilded: Int
  public let isOriginalContent: Bool
  public let isMeta: Bool
  public let isSelf: Bool
  public let edited: Edited
  public let ups: Int
  public let downs: Int
  public var likes: Bool?
  public let score: Int
  public let subredditSubscribers: Int
  public let clicked: Bool
  public let created: Date
  public let numComments: Int
  public let upvoteRatio: Float?
  public let crosspostParent: Fullname?
  public let crosspostParentList: [Post]?
  public let numCrossposts: Int
  public let permalink: String
  public let contentCategories: [String]?
  /// The suggested sort method for the Post's comments
  public let suggestedSort: CommentsSort?
  public let postHint: PostHint?
  public let archived: Bool
  public let noFollow: Bool
  public let isCrosspostable: Bool
  public let pinned: Bool
  public let allAwardings: [Award]
  public let mediaOnly: Bool
  public let canGild: Bool
  public let spoiler: Bool
  public let stickied: Bool
  public let locked: Bool
  /// Whether the user has visited the submission already; requires a Reddit premium subscription
  public let visited: Bool
  public let numReports: Int?
  public let removalReason: String?
  public let sendReplies: Bool
  public let distinguished: String?
  public var isAdminPost: Bool {
    distinguished?.contains("admin") ?? false
  }

  public let contestMode: Bool
  public let createdUtc: Date
  public let isVideo: Bool

  private enum CodingKeys: String, CodingKey {
    case id
    case name
    case subreddit
    case subredditId = "subreddit_id"
    case subredditNamePrefixed = "subreddit_name_prefixed"
    case selftext
    case selftextHtml = "selftext_html"
    case secureMedia = "secure_media"
    case media
    case domain
    case title
    case authorFullname = "author_fullname"
    case author
    case authorFlairTextColor = "author_flair_text_color"
    case authorFlairText = "author_flair_text"
    case authorFlairType = "author_flair_type"
    case authorFlairRichtext = "author_flair_richtext"
    case linkFlairText = "link_flair_text"
    case linkFlairType = "link_flair_type"
    case linkFlairRichtext = "link_flair_richtext"
    case linkFlairTextColor = "link_flair_text_color"
    case url
    case saved
    case thumbnailHeight = "thumbnail_height"
    case thumbnailWidth = "thumbnail_width"
    case thumbnail
    case preview
    case over18 = "over_18"
    case gilded
    case isOriginalContent = "is_original_content"
    case isMeta = "is_meta"
    case isSelf = "is_self"
    case edited
    case ups
    case downs
    case likes
    case score
    case subredditSubscribers = "subreddit_subscribers"
    case clicked
    case created
    case numComments = "num_comments"
    case upvoteRatio = "upvote_ratio"
    case crosspostParent = "crosspost_parent"
    case crosspostParentList = "crosspost_paent_list"
    case numCrossposts = "num_crossposts"
    case permalink
    case contentCategories = "content_categories"
    case suggestedSort = "suggested_sort"
    case postHint = "post_hint"
    case archived
    case noFollow = "no_follow"
    case isCrosspostable = "is_crosspostable"
    case pinned
    case allAwardings = "all_awardings"
    case mediaOnly = "media_only"
    case canGild = "can_gild"
    case spoiler
    case stickied
    case locked
    case visited
    case numReports = "num_reports"
    case removalReason = "removal_reason"
    case sendReplies = "send_replies"
    case distinguished
    case contestMode = "contest_mods"
    case createdUtc = "created_utc"
    case isVideo = "is_video"
  }
}

public extension Post {
  var imagePreviews: [Preview.Source] {
    var previews: [Preview.Source] = []
    previews.reserveCapacity((preview?.images.first?.resolutions.count ?? 0) + 2)
    // Add thumbnail URL as a fallback
    if thumbnail != nil, thumbnail?.scheme != nil {
      previews.append(Preview.Source(url: thumbnail!, width: thumbnailWidth!, height: thumbnailHeight!))
    }
    // Add regular preview images
    if let preview = self.preview?.images.first {
      previews.append(contentsOf: preview.resolutions)
      previews.append(preview.source)
    }
    return previews
  }

  var gifPreviews: [Preview.Source] {
    if let previews = preview?.images.first?.variants?.gif {
      var results: [Preview.Source] = []
      results.append(contentsOf: previews.resolutions)
      results.append(previews.source)
      return results
    } else {
      return []
    }
  }

  var mp4Previews: [Preview.Source] {
    if let previews = preview?.images.first?.variants?.mp4 {
      var results: [Preview.Source] = []
      results.append(contentsOf: previews.resolutions)
      results.append(previews.source)
      return results
    } else {
      return []
    }
  }
}
