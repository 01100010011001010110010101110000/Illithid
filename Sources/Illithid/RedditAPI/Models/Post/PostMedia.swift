//
//  PostMedia.swift
//  Illithid
//
//  Created by Tyler Gregory on 5/2/19.
//  Copyright © 2019 flayware. All rights reserved.
//

import Foundation

public struct PostMedia: Codable {
  public let type: String?
  public let oembed: EmbeddingParameters?
  public let reddit_video: RedditVideo?
  
  public struct RedditVideo: Codable {
    public let dash_url: URL
    public let duration: Int
    public let fallback_url: URL
    public let height: Int
    public let hls_url: URL
    public let is_gif: Bool
    public let scrubber_media_url: URL
    public let transcoding_status: TranscodeStatus
    public let width: Int
  }
  
  public enum TranscodeStatus: String, Codable {
    case completed
  }
  
  public struct EmbeddingParameters: Codable {
    public let provider_url: URL
    public let title: String?
    public let type: String
    public let html: String
    public let thumbnail_width: Int?
    public let thumbnail_height: Int?
    public let height: Int
    public let width: Int
    public let version: String
    public let author_name: String?
    public let provider_name: String
    public let author_url: URL?
  }
}
