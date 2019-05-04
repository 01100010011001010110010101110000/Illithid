//
//  Post.swift
//  Illithid
//
//  Created by Tyler Gregory on 4/30/19.
//  Copyright © 2019 flayware. All rights reserved.
//

import Foundation

enum PostSort: String, Codable {
  case hot
  case qa
  case new
  case random
  case rising
  case top
  case controversial
}

struct Post: RedditObject {
  static func == (lhs: Post, rhs: Post) -> Bool {
    return lhs.name == rhs.name
  }
  
  let id: String
  let name: String
  let type = "t3"
  
  let subreddit: String
  let subreddit_id: String
  let subreddit_name_prefixed: String
  
  let selftext: String
  let secure_media: MediaEmbed?
  let media: MediaEmbed?
  let domain: String
  
  let title: String
  let author_fullname: String
  let author: String
  let author_patreon_flair: Bool
  let author_flair_text_color: String?
  let author_flair_text: String?
  let url: URL
  
  let saved: Bool
  
  let thumbnail_height: Int?
  let thumbnail_width: Int?
  
  let gilded: Int
  let is_original_content: Bool
  let is_meta: Bool
  let is_self: Bool
//  let edited: Date
  let ups: Int
  let downs: Int
  let clicked: Bool
  let created: Date
  let num_comments: Int
  let num_crossposts: Int
  let permalink: String
  let content_categories: [String]?
  let suggested_sort: PostSort?
  let post_hint: String?
  let archived: Bool
  let no_follow: Bool
  let is_crosspostable: Bool
  let pinned: Bool
  let all_awardings: [Award]
  let media_only: Bool
  let can_gild: Bool
  let spoiler: Bool
  let locked: Bool
  let visited: Bool
  let num_reports: Int?
  let removal_reason: String?
  let send_replies: Bool
  let contest_mode: Bool
  let created_utc: Date
  let is_video: Bool
}
