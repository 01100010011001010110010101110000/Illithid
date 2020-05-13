//
// Post.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 5/12/20
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
  public var fullname: Fullname {
    "\(Kind.post.rawValue)_\(id)"
  }

  public let name: String

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
