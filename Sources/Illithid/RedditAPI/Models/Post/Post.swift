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
  case qa
  case new
  case random
  case rising
  case top
  case controversial
  case confidence
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
    return lhs.name == rhs.name
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.name)
  }

  public let id: String
  public let name: String
  public let type = "t3"

  public let subreddit: String
  public let subreddit_id: String
  public let subreddit_name_prefixed: String

  public let selftext: String
  public let selftext_html: String?
  public let secure_media: PostMedia?
  public let media: PostMedia?
  public let domain: String

  public let title: String
  public let author_fullname: String
  public let author: String
  public var authorPrefixed: String {
    return "u/\(self.author)"
  }

  public let author_patreon_flair: Bool
  public let author_flair_text_color: String?
  public let author_flair_text: String?
  public let url: URL

  public let saved: Bool

  public let thumbnail_height: Int?
  public let thumbnail_width: Int?
  public let thumbnail: URL?

  public let preview: Preview?

  public let gilded: Int
  public let is_original_content: Bool
  public let is_meta: Bool
  public let is_self: Bool
  public let edited: Edited
  public let ups: Int
  public let downs: Int
  public let score: Int
  public let clicked: Bool
  public let created: Date
  public let num_comments: Int
  public let num_crossposts: Int
  public let permalink: String
  public let content_categories: [String]?
  public let suggested_sort: PostSort?
  public let post_hint: PostHint?
  public let archived: Bool
  public let no_follow: Bool
  public let is_crosspostable: Bool
  public let pinned: Bool
  public let all_awardings: [Award]
  public let media_only: Bool
  public let can_gild: Bool
  public let spoiler: Bool
  public let locked: Bool
  public let visited: Bool
  public let num_reports: Int?
  public let removal_reason: String?
  public let send_replies: Bool
  public let contest_mode: Bool
  public let created_utc: Date
  public let is_video: Bool

  public var previews: [ImagePreview.Image] {
    var previews: [ImagePreview.Image] = []
    guard self.thumbnail != nil, self.thumbnail?.scheme != nil else { return previews }
    previews.reserveCapacity((self.preview?.images.first?.resolutions.count ?? 0) + 2)
    previews.append(.init(url: self.thumbnail!, width: self.thumbnail_width!, height: self.thumbnail_height!))
    if let preview = self.preview?.images.first {
      previews.append(contentsOf: preview.resolutions)
      previews.append(preview.source)
    }
    return previews
  }
}

