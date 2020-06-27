//
// PostMedia.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 3/21/20
//

import Foundation

public struct PostMedia: Codable {
  public let type: String?
  public let oembed: EmbeddingParameters?
  public let redditVideo: RedditVideo?

  private enum CodingKeys: String, CodingKey {
    case type
    case oembed
    case redditVideo = "reddit_video"
  }

  public struct RedditVideo: Codable {
    public let dashUrl: URL
    public let duration: Int
    public let fallbackUrl: URL
    public let height: Int
    public let hlsUrl: URL
    public let isGif: Bool
    public let scrubberMediaUrl: URL
    public let transcodingStatus: TranscodeStatus
    public let width: Int

    public enum TranscodeStatus: String, Codable {
      case completed
    }

    private enum CodingKeys: String, CodingKey {
      case dashUrl = "dash_url"
      case duration
      case fallbackUrl = "fallback_url"
      case height
      case hlsUrl = "hls_url"
      case isGif = "is_gif"
      case scrubberMediaUrl = "scrubber_media_url"
      case transcodingStatus = "transcoding_status"
      case width
    }
  }

  public struct EmbeddingParameters: Codable {
    public let providerUrl: URL
    public let title: String?
    public let type: String
    public let html: String
    public let thumbnailWidth: Int?
    public let thumbnailHeight: Int?
    public let height: Int?
    public let width: Int
    public let version: String
    public let authorName: String?
    public let providerName: String
    public let authorUrl: URL?

    private enum CodingKeys: String, CodingKey {
      case providerUrl = "provider_url"
      case title
      case type
      case html
      case thumbnailWidth = "thumbnail_width"
      case thumbnailHeight = "thumbnail_height"
      case height
      case width
      case version
      case authorName = "author_name"
      case providerName = "provider_name"
      case authorUrl = "author_url"
    }
  }
}
