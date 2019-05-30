//
//  PostMedia.swift
//  Illithid
//
//  Created by Tyler Gregory on 5/2/19.
//  Copyright © 2019 flayware. All rights reserved.
//

import Foundation

struct PostMedia: Codable {
  let type: String?
  let oembed: EmbeddingParameters?
  let reddit_video: RedditVideo?
  
  struct RedditVideo: Codable {
    let dash_url: URL
    let duration: Int
    let fallback_url: URL
    let height: Int
    let hls_url: URL
    let is_gif: Bool
    let scrubber_media_url: URL
    let transcoding_status: TranscodeStatus
    let width: Int
  }
  
  enum TranscodeStatus: String, Codable {
    case completed
  }
  
  struct EmbeddingParameters: Codable {
    let provider_url: URL
    let title: String?
    let type: String
    let html: String
    let thumbnail_width: Int?
    let thumbnail_height: Int?
    let height: Int
    let width: Int
    let version: String
    let author_name: String?
    let provider_name: String
    let author_url: URL?
  }
}
