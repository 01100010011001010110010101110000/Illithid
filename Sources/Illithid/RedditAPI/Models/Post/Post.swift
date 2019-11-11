//
//  Post.swift
//  Illithid
//
//  Created by Tyler Gregory on 4/30/19.
//  Copyright © 2019 flayware. All rights reserved.
//

import Combine
import Foundation

import Alamofire

public enum PostSort: String, Codable {
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
    // TODO: figure out if this is necessary, coding keys should handle this but it currently seems otherwise
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

  public let id: String
  public let name: String

  public let subreddit: String
  public let subredditId: String
  public let subredditNamePrefixed: String

  public let selftext: String
  public let selftextHtml: String?
  public let secureMedia: PostMedia?
  public let media: PostMedia?
  public let domain: String

  public let title: String
  public let authorFullname: String
  public let author: String
  public var authorPrefixed: String {
    "u/\(author)"
  }

  public let authorPatreonFlair: Bool
  public let authorFlairTextColor: String?
  public let authorFlairText: String?

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

  public let saved: Bool

  public let thumbnailHeight: Int?
  public let thumbnailWidth: Int?
  public let thumbnail: URL?

  public let preview: Preview?

  public let gilded: Int
  public let isOriginalContent: Bool
  public let isMeta: Bool
  public let isSelf: Bool
  public let edited: Edited
  public let ups: Int
  public let downs: Int
  public let score: Int
  public let clicked: Bool
  public let created: Date
  public let numComments: Int
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
  public let locked: Bool
  public let visited: Bool
  public let numReports: Int?
  public let removalReason: String?
  public let sendReplies: Bool
  public let contestMode: Bool
  public let createdUtc: Date
  public let isVideo: Bool

  public var previews: [ImagePreview.Image] {
    var previews: [ImagePreview.Image] = []
    guard thumbnail != nil, thumbnail?.scheme != nil else { return previews }
    previews.reserveCapacity((preview?.images.first?.resolutions.count ?? 0) + 2)
    previews.append(.init(url: thumbnail!, width: thumbnailWidth!, height: thumbnailHeight!))
    if let preview = self.preview?.images.first {
      previews.append(contentsOf: preview.resolutions)
      previews.append(preview.source)
    }
    return previews
  }
}
