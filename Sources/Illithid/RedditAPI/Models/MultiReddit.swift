// Copyright (C) 2020 Tyler Gregory (@01100010011001010110010101110000)
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of  MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <http://www.gnu.org/licenses/>.

import Foundation

// MARK: - Multireddit

/// A user defined multireddit
public struct Multireddit: RedditObject {
  // MARK: Lifecycle

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

  // MARK: Public

  /// A `Multireddit`'s different possible visibility levels
  public enum Visibility: String, Codable {
    case `private`
    case `public`
    case hidden
  }

  /// Trivial struct for deserializing the list of member `Subreddits` returned from the `Multireddit` API
  public struct MultiSubreddit: Codable, Identifiable, Equatable {
    public let name: String

    public var id: String {
      name
    }
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

  public static func == (lhs: Multireddit, rhs: Multireddit) -> Bool {
    lhs.id == rhs.id &&
      lhs.descriptionMd == rhs.descriptionMd &&
      lhs.visibility == rhs.visibility &&
      lhs.subreddits == rhs.subreddits
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case canEdit = "can_edit"
    case displayName = "display_name"
    case name
    case descriptionHtml = "description_html"
    case subscriberCount = "num_subscribers"
    case copiedFrom = "copied_from"
    case iconUrl = "icon_url"
    case subreddits
    case createdUtc = "created_utc"
    case visibility
    case created
    case over18 = "over_18"
    case path
    case owner
//    case keyColor
    case isSubscriber = "is_subscriber"
    case ownerId = "owner_id"
    case descriptionMd = "description_md"
    case isFavorited = "is_favorited"
  }

  // MARK: Private

  private enum WrapperKeys: String, CodingKey {
    case kind
    case data
  }
}
