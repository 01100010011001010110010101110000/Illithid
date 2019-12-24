//
// Preview.swift
// Copyright (c) 2019 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 12/24/19
//

import Foundation

// MARK: - Preview

public struct Preview: Codable {
  public let images: [ImagePreview]
  public let redditVideoPreview: RedditVideoPreview?
  public let enabled: Bool

  // MARK: - ImagePreview

  public struct ImagePreview: Codable, Identifiable {
    public let source: Source
    public let resolutions: [Source]
    public let variants: Variants?
    public let id: String
  }

  // MARK: - RedditVideoPreview

  public struct RedditVideoPreview: Codable {
    public let fallbackUrl: URL
    public let height, width: Int
    public let scrubberMediaUrl: URL
    public let dashUrl: URL
    public let duration: Int
    public let hlsUrl: URL
    public let isGif: Bool
    public let transcodingStatus: String
  }

  // MARK: - VariantsClass

  public struct Variants: Codable {
    public let obfuscated: PreviewVariant?
    public let gif: PreviewVariant?
    public let mp4: PreviewVariant?
    public let nsfw: PreviewVariant?
  }

  // MARK: - GIF

  public struct PreviewVariant: Codable {
    public let source: Source
    public let resolutions: [Source]
  }

  // MARK: - Source

  public struct Source: Codable {
    public let url: URL
    public let width, height: Int
  }
}
