//
// MediaMetadata.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 7/16/20
//

import Foundation

/// The object describing an item in a gallery `Post`
public struct MediaMetadata: Codable {
  public enum MediaType: String, Codable {
    case image = "Image"
    case animatedImage = "AnimatedImage"
  }

  public enum Status: String, Codable {
    case valid
  }

  /// The source attributes of a gallery item
  public struct MediaSource: Codable {
    public let width: Int
    public let height: Int
    public let url: URL?
    /// The URL of the item's GIF if the gallery item is a `MediaType.animatedImage`
    public let gif: URL?
    /// The URL of the item's MP4 if the gallery item is a `MediaType.animatedImage`
    public let mp4: URL?

    private enum CodingKeys: String, CodingKey {
      case width = "x"
      case height = "y"
      case url = "u"
      case gif
      case mp4
    }
  }

  public let id: String
  public let status: Status
  public let type: MediaType
  public let mimeType: String
  public let previews: [MediaSource]
  public let source: MediaSource

  private enum CodingKeys: String, CodingKey {
    case id
    case status
    case type = "e"
    case mimeType = "m"
    case previews = "p"
    case source = "s"
  }
}
