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

import Combine
import Foundation

#if canImport(SwiftUI)
  import SwiftUI
#endif

import Alamofire

// MARK: - VoteDirection

public enum VoteDirection: Int, Codable {
  case down = -1
  case clear = 0
  case up = 1
}

// MARK: - PostSort

public enum PostSort: String, Codable, CaseIterable, Identifiable, Hashable {
  case hot
  case best
  case new
  case random // This is in the API docs but seems to return a 404
  case rising
  case top
  case controversial

  // MARK: Public

  public var id: String {
    rawValue
  }
}

// MARK: - PostHint

public enum PostHint: String, Codable {
  case link
  case `self`
  case image
  case richVideo
  case hostedVideo

  // MARK: Lifecycle

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

  // MARK: Private

  private enum CodingKeys: String, CodingKey {
    case link
    case `self`
    case image
    case richVideo = "rich:video"
    case hostedVideo = "hosted:video"
  }
}

// MARK: - Post

public struct Post: RedditObject {
  // MARK: Lifecycle

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    ups = try container.decode(Int.self, forKey: .ups)
    authorFlairType = try container.decodeIfPresent(FlairType.self, forKey: .authorFlairType)
    removalReason = try container.decodeIfPresent(String.self, forKey: .removalReason)
    likes = try container.decodeIfPresent(Bool.self, forKey: .likes)
    noFollow = try container.decode(Bool.self, forKey: .noFollow)
    saved = try container.decode(Bool.self, forKey: .saved)
    id = try container.decode(ID36.self, forKey: .id)
    url = try container.decode(String.self, forKey: .url)
    gilded = try container.decode(Int.self, forKey: .gilded)
    archived = try container.decode(Bool.self, forKey: .archived)
    author = try container.decode(String.self, forKey: .author)
    sendReplies = try container.decode(Bool.self, forKey: .sendReplies)
    score = try container.decode(Int.self, forKey: .score)
    authorFullname = try container.decodeIfPresent(String.self, forKey: .authorFullname)
    allAwardings = try container.decode([Award].self, forKey: .allAwardings)
    subredditId = try container.decode(String.self, forKey: .subredditId)
    edited = try container.decode(Edited.self, forKey: .edited)
    downs = try container.decode(Int.self, forKey: .downs)
    authorFlairRichtext = try container.decodeIfPresent([FlairRichtext].self, forKey: .authorFlairRichtext)
    authorFlairTextColor = try container.decodeIfPresent(FlairTextColor.self, forKey: .authorFlairTextColor)
    stickied = try container.decode(Bool.self, forKey: .stickied)
    canGild = try container.decode(Bool.self, forKey: .canGild)
//    let gildings = try? container.decode([Any = try? container.decode(Any]
    permalink = try container.decode(String.self, forKey: .permalink)
    numReports = try container.decodeIfPresent(Int.self, forKey: .numReports)
    locked = try container.decode(Bool.self, forKey: .locked)
    name = try container.decode(String.self, forKey: .name)
    created = try container.decode(Date.self, forKey: .created)
    subreddit = try container.decode(String.self, forKey: .subreddit)
    authorFlairText = try container.decodeIfPresent(String.self, forKey: .authorFlairText)
    createdUtc = try container.decode(Date.self, forKey: .createdUtc)
    subredditNamePrefixed = try container.decode(String.self, forKey: .subredditNamePrefixed)
    authorFlairBackgroundColor = try container.decodeIfPresent(String.self, forKey: .authorFlairBackgroundColor)
    distinguished = try container.decodeIfPresent(String.self, forKey: .distinguished)
    contentCategories = try container.decodeIfPresent([String].self, forKey: .contentCategories)

    selftext = try container.decode(String.self, forKey: .selftext)
    selftextHtml = try container.decodeIfPresent(String.self, forKey: .selftextHtml)
    attributedSelfText = NSMutableAttributedString(html: Data((selftextHtml ?? "").utf8), options: [
      .documentType: NSAttributedString.DocumentType.html,
      .characterEncoding: NSNumber(value: String.Encoding.utf8.rawValue),
    ], documentAttributes: nil) ?? NSAttributedString()

    media = try container.decodeIfPresent(PostMedia.self, forKey: .media)
    secureMedia = try container.decodeIfPresent(PostMedia.self, forKey: .secureMedia)
    domain = try container.decode(String.self, forKey: .domain)
    title = try container.decode(String.self, forKey: .title)
    linkFlairText = try container.decodeIfPresent(String.self, forKey: .linkFlairText)
    linkFlairType = try container.decodeIfPresent(FlairType.self, forKey: .linkFlairType)
    linkFlairRichtext = try container.decodeIfPresent([FlairRichtext].self, forKey: .linkFlairRichtext)
    linkFlairTextColor = try container.decodeIfPresent(FlairTextColor.self, forKey: .linkFlairTextColor)
    linkFlairBackgroundColor = try container.decode(String.self, forKey: .linkFlairBackgroundColor)

    thumbnailHeight = try container.decodeIfPresent(Int.self, forKey: .thumbnailHeight)
    thumbnailWidth = try container.decodeIfPresent(Int.self, forKey: .thumbnailWidth)
    thumbnail = try container.decodeIfPresent(URL.self, forKey: .thumbnail)
    preview = try container.decodeIfPresent(Preview.self, forKey: .preview)

    over18 = try container.decode(Bool.self, forKey: .over18)
    isOriginalContent = try container.decode(Bool.self, forKey: .isOriginalContent)
    isMeta = try container.decode(Bool.self, forKey: .isMeta)
    isSelf = try container.decode(Bool.self, forKey: .isSelf)
    isGallery = try container.decodeIfPresent(Bool.self, forKey: .isGallery)
    galleryData = try container.decodeIfPresent(GalleryData.self, forKey: .galleryData)
    mediaMetadata = try container.decodeIfPresent([String: MediaMetadata].self, forKey: .mediaMetadata)

    subredditSubscribers = try container.decode(Int.self, forKey: .subredditSubscribers)
    clicked = try container.decode(Bool.self, forKey: .clicked)
    numComments = try container.decode(Int.self, forKey: .numComments)
    upvoteRatio = try container.decodeIfPresent(Float.self, forKey: .upvoteRatio)
    crosspostParent = try container.decodeIfPresent(Fullname.self, forKey: .crosspostParent)
    crosspostParentList = try container.decodeIfPresent([Post].self, forKey: .crosspostParentList)
    isCrosspostable = try container.decode(Bool.self, forKey: .isCrosspostable)
    numCrossposts = try container.decode(Int.self, forKey: .numCrossposts)

    suggestedSort = try container.decodeIfPresent(CommentsSort.self, forKey: .suggestedSort)
    postHint = try container.decodeIfPresent(PostHint.self, forKey: .postHint)
    mediaOnly = try container.decode(Bool.self, forKey: .mediaOnly)
    spoiler = try container.decode(Bool.self, forKey: .spoiler)
    visited = try container.decode(Bool.self, forKey: .visited)
    contestMode = try container.decode(Bool.self, forKey: .contestMode)
    isVideo = try container.decode(Bool.self, forKey: .isVideo)
    pinned = try container.decode(Bool.self, forKey: .pinned)
  }

  // MARK: Public

  public let id: ID36
  public let name: Fullname

  public let subreddit: String
  /// The `Fullname` of the subreddit to which this post was submitted
  public let subredditId: Fullname
  public let subredditNamePrefixed: String

  public let selftext: String
  public let selftextHtml: String?
  public let attributedSelfText: NSAttributedString
  public let secureMedia: PostMedia?
  public let media: PostMedia?
  public let domain: String

  public let title: String
  public let authorFullname: String?
  public let author: String
  public let authorFlairTextColor: FlairTextColor?
  public let authorFlairText: String?
  public let authorFlairType: FlairType?
  public let authorFlairRichtext: [FlairRichtext]?
  public let authorFlairBackgroundColor: String?
  public let linkFlairText: String?
  public let linkFlairType: FlairType?
  public let linkFlairRichtext: [FlairRichtext]?
  public let linkFlairTextColor: FlairTextColor?
  public let linkFlairBackgroundColor: String

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
  /// Whether the post is a gallery post
  /// - Note: If the post is **not** a gallery post, this is `nil`
  public let isGallery: Bool?
  public let galleryData: GalleryData?
  public let mediaMetadata: [String: MediaMetadata]?
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
  public let contestMode: Bool
  public let createdUtc: Date
  public let isVideo: Bool

  public var authorPrefixed: String {
    "u/\(author)"
  }

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

  public var isAdminPost: Bool {
    distinguished?.contains("admin") ?? false
  }

  public var authorIsDeleted: Bool {
    author == "[deleted]"
  }

  public static func == (lhs: Post, rhs: Post) -> Bool {
    lhs.name == rhs.name
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(name)
  }

  // MARK: Private

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
    case authorFlairBackgroundColor = "author_flair_background_color"
    case linkFlairText = "link_flair_text"
    case linkFlairType = "link_flair_type"
    case linkFlairRichtext = "link_flair_richtext"
    case linkFlairTextColor = "link_flair_text_color"
    case linkFlairBackgroundColor = "link_flair_background_color"
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
    case isGallery = "is_gallery"
    case mediaMetadata = "media_metadata"
    case galleryData = "gallery_data"
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
    case contestMode = "contest_mode"
    case createdUtc = "created_utc"
    case isVideo = "is_video"
  }

  /// The string value returned by the Reddit API for the URL attribute
  private let url: String
}

public extension Post {
  enum FlairTextColor: String, Codable {
    case light
    case dark
    /// This case is for when the API response is `""` instead of `null`
    case empty = ""
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

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Post {
  var linkFlairBackgroundSwiftUiColor: Color? {
    guard !linkFlairBackgroundColor.isEmpty else { return nil }
    return Color(hex: linkFlairBackgroundColor)
  }

  var authorFlairBackgroundSwiftUiColor: Color? {
    guard let color = authorFlairBackgroundColor, !color.isEmpty else { return nil }
    return Color(hex: color)
  }
}
