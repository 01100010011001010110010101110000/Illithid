//
// Subreddit.swift
// Copyright (c) 2019 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 12/24/19
//

import Cocoa
import Combine
import Foundation

import Alamofire

public enum SubredditSort {
  case popular
  case new
  case gold
  case `default`
}

public struct Subreddit: RedditObject {
  public static func == (lhs: Subreddit, rhs: Subreddit) -> Bool {
    lhs.name == rhs.name
  }

  public let id: String // swiftlint:disable:this identifier_name
  public let name: String
  public let publicDescription: String
  public let displayName: String
  public let wikiEnabled: Bool?
  public let headerImg: URL?
  public let over18: Bool
  public let createdUtc: Date

  /// The Reddit API sometimes returns the empty string for the `header_img` parameter, and also may return `nil`, so we handle the empty srtring, then
  /// decode the actual URL if it is present
  /// - Parameter decoder: A `Decoder` conforming object
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    name = try container.decode(String.self, forKey: .name)
    publicDescription = try container.decode(String.self, forKey: .publicDescription)
    displayName = try container.decode(String.self, forKey: .displayName)
    wikiEnabled = try container.decodeIfPresent(Bool.self, forKey: .wikiEnabled)
    over18 = try container.decode(Bool.self, forKey: .over18)
    createdUtc = try container.decode(Date.self, forKey: .createdUtc)

    if let emptyString = try? container.decodeIfPresent(String.self, forKey: .headerImg), emptyString.isEmpty {
      headerImg = nil
    } else {
      headerImg = try container.decodeIfPresent(URL.self, forKey: .headerImg)
    }
  }

  private enum CodingKeys: String, CodingKey {
    case id // swiftlint:disable:this identifier_name
    case name
    case publicDescription
    case displayName
    case wikiEnabled
    case headerImg
    case over18
    case createdUtc
  }
}
