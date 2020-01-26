//
// PostMedia.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 12/24/19
//

import Foundation

public struct PostMedia: Codable {
  public let type: String?
  public let oembed: EmbeddingParameters?
  public let redditVideo: RedditVideo?

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
  }

  public enum TranscodeStatus: String, Codable {
    case completed
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
  }
}
