//
//  MultiReddit.swift
//
//  Created by Tyler Gregory on 11/20/19.
//

import Foundation

// MARK: - MultiReddit

/// A user defined multireddit
public struct MultiReddit: Codable {
  /// A `MultiReddit`'s different possible visibility levels
  public enum Visibility: String, Codable {
    case `private`
  }

  /// Whether the current user can edit the `MultiReddit`'s member subreddits
  let canEdit: Bool
  let displayName: String
  let name: String
  /// `descriptionMd` rendered as HTML
  let descriptionHTML: String
  let subscriberCount: Int
  /// The URL path to the `MultiReddit` from which this `MultiReddit` was copied
  let copiedFrom: String?
  let iconURL: URL
  let subreddits: [MultiSubreddit]
  /// When the `MultiReddit` was created in UTC
  let createdUTC: Date
  /// Whether the `MultiReddit` is public
  let visibility: Visibility
  /// When the `MultiReddit` was created
  let created: Date
  let over18: Bool
  /// The URL path to the `MultiReddit`
  let path: String
  /// The `name` of the `RedditAccount` that owns the `MultiReddit`
  let owner: String
  /// This has been null on every `MultiReddit` I've seen, waiting to see what it is
//  let keyColor: String
  /// Whether the current user subscribes to the `MultiReddit`
  let isSubscriber: Bool
  /// The `Fullname` of the `RedditAccount` that owns the `MultiReddit`
  let ownerID: String
  /// The `MultiReddit`'s description in MarkDown
  let descriptionMd: String
  /// Whether the current user has favorited the `MultiReddit`
  let isFavorited: Bool

  enum CodingKeys: String, CodingKey {
    case canEdit
    case displayName
    case name
    case descriptionHTML
    case subscriberCount = "numSubscribers"
    case copiedFrom
    case iconURL
    case subreddits
    case createdUTC
    case visibility, created
    case over18
    case path, owner
//    case keyColor
    case isSubscriber
    case ownerID
    case descriptionMd
    case isFavorited
  }

  /// Trivial class for deserializing the list of member `Subreddits` returned from the `MultiReddit` API
  struct MultiSubreddit: Codable {
    let name: String
  }
}
