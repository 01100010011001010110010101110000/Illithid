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

import Alamofire

// MARK: - BaseNewPostParameters

public protocol BaseNewPostParameters {
  var targetSubredditDisplayName: String { get }
  var title: String { get }
  var isNsfw: Bool { get }
  var isSpoiler: Bool { get }
  var collectionId: UUID? { get }
  var eventStart: Date? { get }
  var eventEnd: Date? { get }
  var eventTimeZone: String? { get }
  var flairId: String? { get }
  var flairText: String? { get }
  var notifyOfReplies: Bool { get }
  var validateOnSubmit: Bool { get }

  func toParameters() -> Parameters
}

private extension BaseNewPostParameters {
  func toCommonParams() -> Parameters {
    [
      "api_type": "json",
      "sr": targetSubredditDisplayName,
      "title": title,
      "nsfw": isNsfw,
      "spoiler": isSpoiler,
      "collection_id": collectionId?.uuidString,
      "event_start": eventStart == nil ? nil : Illithid.shared.redditEventTimeFormatter.string(from: eventStart!),
      "event_end": eventStart == nil ? nil : Illithid.shared.redditEventTimeFormatter.string(from: eventEnd!),
      "event_tz": eventTimeZone,
      "flair_id": flairId,
      "flair_text": flairText,
      "sendreplies": notifyOfReplies,
      "validate_on_submit": validateOnSubmit,
    ].compactMapValues { $0 }
  }
}

// MARK: - SelfPostParameters

public struct SelfPostParameters: BaseNewPostParameters {
  // MARK: Lifecycle

  public init(targetSubredditDisplayName: String, title: String, isNsfw: Bool = false, isSpoiler: Bool = false,
              collectionId: UUID? = nil, eventStart: Date? = nil, eventEnd: Date? = nil, eventTimeZone: String? = nil,
              flairId: String? = nil, flairText: String? = nil, notifyOfReplies: Bool = true,
              validateOnSubmit: Bool = true, markdownBody: String) {
    self.targetSubredditDisplayName = targetSubredditDisplayName
    self.title = title
    self.isNsfw = isNsfw
    self.isSpoiler = isSpoiler
    self.collectionId = collectionId
    self.eventStart = eventStart
    self.eventEnd = eventEnd
    self.eventTimeZone = eventTimeZone
    self.flairId = flairId
    self.flairText = flairText
    self.notifyOfReplies = notifyOfReplies
    self.validateOnSubmit = validateOnSubmit
    self.markdownBody = markdownBody
  }

  // MARK: Public

  public let targetSubredditDisplayName: String
  public let title: String
  public let isNsfw: Bool
  public let isSpoiler: Bool
  public let collectionId: UUID?
  public let eventStart: Date?
  public let eventEnd: Date?
  public let eventTimeZone: String?
  public let flairId: String?
  public let flairText: String?
  public let notifyOfReplies: Bool
  public let validateOnSubmit: Bool

  public let kind: NewPostType = .`self`
  public let markdownBody: String

  public func toParameters() -> Parameters {
    toCommonParams().merging(
      [
        "kind": kind,
        "text": markdownBody,
      ]) { $1 }
  }
}

// MARK: - LinkPostParameters

public struct LinkPostParameters: BaseNewPostParameters {
  // MARK: Lifecycle

  public init(targetSubredditDisplayName: String, title: String, isNsfw: Bool = false, isSpoiler: Bool = false,
              collectionId: UUID? = nil, eventStart: Date? = nil, eventEnd: Date? = nil, eventTimeZone: String? = nil,
              flairId: String? = nil, flairText: String? = nil, notifyOfReplies: Bool = true,
              validateOnSubmit: Bool = true, resubmit: Bool, linkingTo: URL) {
    self.targetSubredditDisplayName = targetSubredditDisplayName
    self.title = title
    self.isNsfw = isNsfw
    self.isSpoiler = isSpoiler
    self.collectionId = collectionId
    self.eventStart = eventStart
    self.eventEnd = eventEnd
    self.eventTimeZone = eventTimeZone
    self.flairId = flairId
    self.flairText = flairText
    self.notifyOfReplies = notifyOfReplies
    self.validateOnSubmit = validateOnSubmit
    self.resubmit = resubmit
    self.linkingTo = linkingTo
  }

  // MARK: Public

  public let targetSubredditDisplayName: String
  public let title: String
  public let isNsfw: Bool
  public let isSpoiler: Bool
  public let collectionId: UUID?
  public let eventStart: Date?
  public let eventEnd: Date?
  public let eventTimeZone: String?
  public let flairId: String?
  public let flairText: String?
  public let notifyOfReplies: Bool
  public let validateOnSubmit: Bool

  public let kind: NewPostType = .link
  public let resubmit: Bool
  public let linkingTo: URL

  public func toParameters() -> Parameters {
    toCommonParams().merging(
      [
        "kind": kind,
        "resubmit": resubmit,
        "url": linkingTo,
      ]) { $1 }
  }
}

// MARK: - GalleryPostParameters

public struct GalleryPostParameters: BaseNewPostParameters {
  public let targetSubredditDisplayName: String
  public let title: String
  public let isNsfw: Bool
  public let isSpoiler: Bool
  public let collectionId: UUID?
  public let eventStart: Date?
  public let eventEnd: Date?
  public let eventTimeZone: String?
  public let flairId: String?
  public let flairText: String?
  public let notifyOfReplies: Bool
  public let validateOnSubmit: Bool

  public let galleryItems: [GalleryDataItem]

  public func toParameters() -> Parameters {
    toCommonParams().merging(
      [
        "items": galleryItems.map { $0.asDictionary() },
      ]) { $1 }
  }
}

// MARK: - ImagePostParameters

public struct ImagePostParameters: BaseNewPostParameters {
  // MARK: Lifecycle

  public init(targetSubredditDisplayName: String, title: String, isNsfw: Bool = false, isSpoiler: Bool = false,
              collectionId: UUID? = nil, eventStart: Date? = nil, eventEnd: Date? = nil, eventTimeZone: String? = nil,
              flairId: String? = nil, flairText: String? = nil, notifyOfReplies: Bool = true,
              validateOnSubmit: Bool = true, imageAssetUrl: URL) {
    self.targetSubredditDisplayName = targetSubredditDisplayName
    self.title = title
    self.isNsfw = isNsfw
    self.isSpoiler = isSpoiler
    self.collectionId = collectionId
    self.eventStart = eventStart
    self.eventEnd = eventEnd
    self.eventTimeZone = eventTimeZone
    self.flairId = flairId
    self.flairText = flairText
    self.notifyOfReplies = notifyOfReplies
    self.validateOnSubmit = validateOnSubmit
    self.imageAssetUrl = imageAssetUrl
  }

  // MARK: Public

  public let targetSubredditDisplayName: String
  public let title: String
  public let isNsfw: Bool
  public let isSpoiler: Bool
  public let collectionId: UUID?
  public let eventStart: Date?
  public let eventEnd: Date?
  public let eventTimeZone: String?
  public let flairId: String?
  public let flairText: String?
  public let notifyOfReplies: Bool
  public let validateOnSubmit: Bool

  public let kind: NewPostType = .image
  public let imageAssetUrl: URL

  public func toParameters() -> Parameters {
    toCommonParams().merging(
      [
        "kind": kind,
        "url": imageAssetUrl,
      ]) { $1 }
  }
}

// MARK: - VideoPostParameters

public struct VideoPostParameters: BaseNewPostParameters {
  // MARK: Lifecycle

  public init(targetSubredditDisplayName: String, title: String, isNsfw: Bool = false, isSpoiler: Bool = false,
              collectionId: UUID? = nil, eventStart: Date? = nil, eventEnd: Date? = nil, eventTimeZone: String? = nil,
              flairId: String? = nil, flairText: String? = nil, notifyOfReplies: Bool = true,
              validateOnSubmit: Bool = true, videoAssetUrl: URL, videoPosterAssetUrl: URL) {
    self.targetSubredditDisplayName = targetSubredditDisplayName
    self.title = title
    self.isNsfw = isNsfw
    self.isSpoiler = isSpoiler
    self.collectionId = collectionId
    self.eventStart = eventStart
    self.eventEnd = eventEnd
    self.eventTimeZone = eventTimeZone
    self.flairId = flairId
    self.flairText = flairText
    self.notifyOfReplies = notifyOfReplies
    self.validateOnSubmit = validateOnSubmit
    self.videoAssetUrl = videoAssetUrl
    self.videoPosterAssetUrl = videoPosterAssetUrl
  }

  // MARK: Public

  public let targetSubredditDisplayName: String
  public let title: String
  public let isNsfw: Bool
  public let isSpoiler: Bool
  public let collectionId: UUID?
  public let eventStart: Date?
  public let eventEnd: Date?
  public let eventTimeZone: String?
  public let flairId: String?
  public let flairText: String?
  public let notifyOfReplies: Bool
  public let validateOnSubmit: Bool

  public let kind: NewPostType = .video
  public let videoAssetUrl: URL
  public let videoPosterAssetUrl: URL

  public func toParameters() -> Parameters {
    toCommonParams().merging(
      [
        "kind": kind,
        "url": videoAssetUrl,
        "video_poster_url": videoPosterAssetUrl,
      ]) { $1 }
  }
}

// MARK: - VideoGifPostParameters

public struct VideoGifPostParameters: BaseNewPostParameters {
  // MARK: Lifecycle

  public init(targetSubredditDisplayName: String, title: String, isNsfw: Bool = false, isSpoiler: Bool = false,
              collectionId: UUID? = nil, eventStart: Date? = nil, eventEnd: Date? = nil, eventTimeZone: String? = nil,
              flairId: String? = nil, flairText: String? = nil, notifyOfReplies: Bool = true,
              validateOnSubmit: Bool = true, videoAssetUrl: URL, videoPosterAssetUrl: URL) {
    self.targetSubredditDisplayName = targetSubredditDisplayName
    self.title = title
    self.isNsfw = isNsfw
    self.isSpoiler = isSpoiler
    self.collectionId = collectionId
    self.eventStart = eventStart
    self.eventEnd = eventEnd
    self.eventTimeZone = eventTimeZone
    self.flairId = flairId
    self.flairText = flairText
    self.notifyOfReplies = notifyOfReplies
    self.validateOnSubmit = validateOnSubmit
    self.videoAssetUrl = videoAssetUrl
    self.videoPosterAssetUrl = videoPosterAssetUrl
  }

  // MARK: Public

  public let targetSubredditDisplayName: String
  public let title: String
  public let isNsfw: Bool
  public let isSpoiler: Bool
  public let collectionId: UUID?
  public let eventStart: Date?
  public let eventEnd: Date?
  public let eventTimeZone: String?
  public let flairId: String?
  public let flairText: String?
  public let notifyOfReplies: Bool
  public let validateOnSubmit: Bool

  public let kind: NewPostType = .videogif
  public let videoAssetUrl: URL
  public let videoPosterAssetUrl: URL

  public func toParameters() -> Parameters {
    toCommonParams().merging(
      [
        "kind": kind,
        "url": videoAssetUrl,
        "video_poster_url": videoPosterAssetUrl,
      ]) { $1 }
  }
}
