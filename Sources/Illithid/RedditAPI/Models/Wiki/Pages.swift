//
// Pages.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 5/16/20
//

import Foundation

/// The contents of a `Subreddit` wiki
public struct WikiPages: Codable {
  private let kind: String
  private let data: [URL]

  /// The array of page links comprising the `Subreddit` wiki
  /// - NOTE: These links are not fully qualified; they are relative to the subreddit wiki path, i.e. `https://oauth.reddit.com/r/<subreddit>/wiki`
  public var pageLinks: [URL] { data }
}

/// The content of a particular page in a `Subreddit` wiki
public struct WikiPage: Codable {
  /// The content of the `WikiPage` in Markdown
  public let contentMd: String
  /// If `true`, the current user may revise this page
  public let mayRevise: Bool
  /// The reason for the revision of this page
  public let reason: String?
  /// This page's revision date
  public let revisionDate: Date
  /// The account that created this revision
  public let revisionBy: Account
  /// The UUID uniquely identifying this revision
  public let revisionId: UUID
  /// The content of the `WikiPage` in HTML
  public let contentHtml: String

  enum CodingKeys: String, CodingKey {
    case contentMd = "content_md"
    case mayRevise = "may_revise"
    case reason
    case revisionDate = "revision_date"
    case revisionBy = "revision_by"
    case revisionId = "revision_id"
    case contentHtml = "content_html"
  }

  /// Here to allow the page to be decoded whether it is the top-level object in the payload or not
  private enum WrapperKeys: String, CodingKey {
    case data
    case kind
  }

  public init(from decoder: Decoder) throws {
    let wrappedContainer = try? decoder.container(keyedBy: WrapperKeys.self)
    let nestedContainer = try? wrappedContainer?.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
    let unnestedContainer = try? decoder.container(keyedBy: CodingKeys.self)

    let container = nestedContainer != nil ? nestedContainer! : unnestedContainer!

    contentMd = try container.decode(String.self, forKey: .contentMd)
    mayRevise = try container.decode(Bool.self, forKey: .mayRevise)
    reason = try container.decodeIfPresent(String.self, forKey: .reason)
    revisionDate = try container.decode(Date.self, forKey: .revisionDate)
    revisionBy = try container.decode(Account.self, forKey: .revisionBy)
    revisionId = try container.decode(UUID.self, forKey: .revisionId)
    contentHtml = try container.decode(String.self, forKey: .contentHtml)
  }
}
