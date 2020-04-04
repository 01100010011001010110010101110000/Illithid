//
// Subreddit.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 3/21/20
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

  public let id: ID36
  public let name: Fullname
  public let publicDescription: String
  public let publicDescriptionHtml: String?
  public let displayName: String
  public let wikiEnabled: Bool?
  public let headerImg: URL?
  public let over18: Bool?
  public let createdUtc: Date
  public let description: String?
  public let descriptionHtml: String?
  public let userIsSubscriber: Bool?

  /// The Reddit API sometimes returns the empty string for the `header_img` parameter, and also may return `nil`, so we handle the empty srtring, then
  /// decode the actual URL if it is present
  /// - Parameter decoder: A `Decoder` conforming object
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    name = try container.decode(String.self, forKey: .name)
    publicDescription = try container.decode(String.self, forKey: .publicDescription)
    publicDescriptionHtml = try container.decodeIfPresent(String.self, forKey: .publicDescriptionHtml)
    displayName = try container.decode(String.self, forKey: .displayName)
    wikiEnabled = try container.decodeIfPresent(Bool.self, forKey: .wikiEnabled)
    over18 = try container.decodeIfPresent(Bool.self, forKey: .over18)
    createdUtc = try container.decode(Date.self, forKey: .createdUtc)
    description = try container.decodeIfPresent(String.self, forKey: .description)
    descriptionHtml = try container.decodeIfPresent(String.self, forKey: .descriptionHtml)
    userIsSubscriber = try container.decodeIfPresent(Bool.self, forKey: .userIsSubscriber)

    if let emptyString = try? container.decodeIfPresent(String.self, forKey: .headerImg), emptyString.isEmpty {
      headerImg = nil
    } else {
      headerImg = try container.decodeIfPresent(URL.self, forKey: .headerImg)
    }
  }

  private enum CodingKeys: String, CodingKey {
    case id
    case name
    case publicDescription
    case publicDescriptionHtml
    case displayName
    case wikiEnabled
    case headerImg
    case over18
    case createdUtc
    case description
    case descriptionHtml
    case userIsSubscriber
  }
}
