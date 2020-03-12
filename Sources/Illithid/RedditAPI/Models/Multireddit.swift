//
// Multireddit.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 12/24/19
//

import Foundation

// MARK: - Multireddit

/// A user defined multireddit
public struct Multireddit: RedditObject {
  public static func == (lhs: Multireddit, rhs: Multireddit) -> Bool {
    lhs.id == rhs.id &&
      lhs.descriptionMd == rhs.descriptionMd &&
      lhs.visibility == rhs.visibility &&
      lhs.subreddits == rhs.subreddits 
  }

  /// A `Multireddit`'s different possible visibility levels
  public enum Visibility: String, Codable {
    case `private`
    case `public`
    case hidden
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  public let id: String

  /// Whether the current user can edit the `MultiReddit`'s member subreddits
  public let canEdit: Bool
  public let displayName: String
  public let name: String
  /// `descriptionMd` rendered as HTML
  public let descriptionHtml: String
  public let subscriberCount: Int
  /// The URL path to the `MultiReddit` from which this `MultiReddit` was copied
  public let copiedFrom: URL?
  public let iconUrl: URL
  public let subreddits: [MultiSubreddit]
  /// When the `MultiReddit` was created in UTC
  public let createdUtc: Date
  /// Whether the `MultiReddit` is public
  public let visibility: Visibility
  /// When the `MultiReddit` was created
  public let created: Date
  public let over18: Bool?
  /// The URL path to the `MultiReddit`
  public let path: URL
  /// The `name` of the `RedditAccount` that owns the `MultiReddit`
  public let owner: String
  /// This has been null on every `MultiReddit` I've seen, waiting to see what it is
//  let keyColor: String
  /// Whether the current user subscribes to the `MultiReddit`
  public let isSubscriber: Bool
  /// The `Fullname` of the `RedditAccount` that owns the `MultiReddit`
  public let ownerId: Fullname
  /// The `MultiReddit`'s description in MarkDown
  public let descriptionMd: String
  /// Whether the current user has favorited the `MultiReddit`
  public let isFavorited: Bool

  enum CodingKeys: String, CodingKey {
    case canEdit
    case displayName
    case name
    case descriptionHtml
    case subscriberCount = "numSubscribers"
    case copiedFrom
    case iconUrl
    case subreddits
    case createdUtc
    case visibility, created
    case over18
    case path, owner
//    case keyColor
    case isSubscriber
    case ownerId
    case descriptionMd
    case isFavorited
  }

  private enum WrapperKeys: String, CodingKey {
    case kind
    case data
  }

  public init(from decoder: Decoder) throws {
    let wrappedContainer = try? decoder.container(keyedBy: WrapperKeys.self).nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
    let workingContainer = wrappedContainer != nil ? wrappedContainer! : try decoder.container(keyedBy: CodingKeys.self)

    canEdit = try workingContainer.decode(Bool.self, forKey: .canEdit)
    displayName = try workingContainer.decode(String.self, forKey: .displayName)
    name = try workingContainer.decode(String.self, forKey: .name)
    descriptionHtml = try workingContainer.decode(String.self, forKey: .descriptionHtml)
    subscriberCount = try workingContainer.decode(Int.self, forKey: .subscriberCount)
    copiedFrom = try workingContainer.decodeIfPresent(URL.self, forKey: .copiedFrom)
    iconUrl = try workingContainer.decode(URL.self, forKey: .iconUrl)
    subreddits = try workingContainer.decode([MultiSubreddit].self, forKey: .subreddits)
    createdUtc = try workingContainer.decode(Date.self, forKey: .createdUtc)
    visibility = try workingContainer.decode(Visibility.self, forKey: .visibility)
    created = try workingContainer.decode(Date.self, forKey: .created)
    over18 = try workingContainer.decodeIfPresent(Bool.self, forKey: .over18)
    path = try workingContainer.decode(URL.self, forKey: .path)
    owner = try workingContainer.decode(String.self, forKey: .owner)
    isSubscriber = try workingContainer.decode(Bool.self, forKey: .isSubscriber)
    ownerId = try workingContainer.decode(Fullname.self, forKey: .ownerId)
    descriptionMd = try workingContainer.decode(String.self, forKey: .descriptionMd)
    isFavorited = try workingContainer.decode(Bool.self, forKey: .isFavorited)
    id = path.absoluteString
  }

  /// Trivial class for deserializing the list of member `Subreddits` returned from the `Multireddit` API
  public struct MultiSubreddit: Codable, Identifiable, Equatable {
    public var id: String {
      name
    }

    public let name: String
  }
} 