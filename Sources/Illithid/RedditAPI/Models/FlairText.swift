//
// FlairText.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 5/11/20
//

import Foundation

/// Whether the flair is plaintext or richtext
public enum FlairType: String, Codable {
  case text
  case richtext
}

/// A richtext chunk containing either plaintext, or an emoji and its URL
public struct FlairRichtext: Codable {
  public enum RichtextType: String, Codable {
    case text
    case emoji
  }

  public let emojiShortcode: String?
  public let emojiUrl: URL?
  public let type: RichtextType
  public let text: String?

  enum CodingKeys: String, CodingKey {
    case type = "e"
    case text = "t"
    case emojiShortcode = "a"
    case emojiUrl = "u"
  }
}
