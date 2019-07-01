//
//  File.swift
//
//
//  Created by Tyler Gregory on 6/19/19.
//

import Foundation

public enum CommentsSort: String, Codable {
  case confidence
  case top
  case new
  case controversial
  case old
  case random
  case qa
  case live
}

public struct Comment: RedditObject {
  public var type = "t1"

  public static func == (lhs: Comment, rhs: Comment) -> Bool {
    lhs.id == rhs.id
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  public let totalAwardsReceived: Int
  public let approvedAtUTC: Date?
  public let ups: Int
  public let modReasonBy: String?
  public let bannedBy: String?
  public let authorFlairType: String
  public let removalReason: String?
  // This is actually a fullname
  public let linkID: String
  public let authorFlairTemplateID: String?
  public let likes: String?
  public let noFollow: Bool
  public let replies: Replies?
  public let userReports: [String]
  public let saved: Bool
  public let id: ID36
  public let bannedAtUTC: Date?
  public let modReasonTitle: String?
  public let gilded: Int
  public let archived: Bool
  public let reportReasons: String?
  public let author: String
  public let canModPost, sendReplies: Bool
  // This is actually a fullname
  public let parentID: String
  public let score: Int
  public let authorFullname: String
  public let approvedBy: String?
  public let allAwardings: [Award]
  // This is actually a fullname
  public let subredditID: String
  public let body: String
  public let edited: Edited
  public let authorFlairCSSClass: String?
  public let isSubmitter: Bool
  public let downs: Int
  public let authorFlairRichtext: [String]
  public let authorPatreonFlair: Bool
  public let collapsedReason: String?
  public let bodyHTML: String
  public let stickied: Bool
  public let subredditType: String
  public let canGild: Bool
//  public let gildings: [Any: Any]
  public let authorFlairTextColor: String?
  public let scoreHidden: Bool
  public let permalink: String
  public let numReports: Int?
  public let locked: Bool
  public let name: String
  public let created: Date
  public let subreddit: String
  public let authorFlairText: String?
  public let collapsed: Bool
  public let createdUTC: Date
  public let subredditNamePrefixed: String
  public let controversiality: Int
  public let depth: Int
  public let authorFlairBackgroundColor: String?
  public let modReports: [String]
  public let modNote: String?
  public let distinguished: String?

  public let previousVisits: [Date]?
  public let contentCategories: [String]?

  enum CodingKeys: String, CodingKey {
    case totalAwardsReceived = "total_awards_received"
    case approvedAtUTC = "approved_at_utc"
    case ups
    case modReasonBy = "mod_reason_by"
    case bannedBy = "banned_by"
    case authorFlairType = "author_flair_type"
    case removalReason = "removal_reason"
    case linkID = "link_id"
    case authorFlairTemplateID = "author_flair_template_id"
    case likes
    case noFollow = "no_follow"
    case replies
    case userReports = "user_reports"
    case saved, id
    case bannedAtUTC = "banned_at_utc"
    case modReasonTitle = "mod_reason_title"
    case gilded, archived
    case reportReasons = "report_reasons"
    case author
    case canModPost = "can_mod_post"
    case sendReplies = "send_replies"
    case parentID = "parent_id"
    case score
    case authorFullname = "author_fullname"
    case approvedBy = "approved_by"
    case allAwardings = "all_awardings"
    case subredditID = "subreddit_id"
    case body, edited
    case authorFlairCSSClass = "author_flair_css_class"
    case isSubmitter = "is_submitter"
    case downs
    case authorFlairRichtext = "author_flair_richtext"
    case authorPatreonFlair = "author_patreon_flair"
    case collapsedReason = "collapsed_reason"
    case bodyHTML = "body_html"
    case stickied
    case subredditType = "subreddit_type"
    case canGild = "can_gild"
//    case gildings
    case authorFlairTextColor = "author_flair_text_color"
    case scoreHidden = "score_hidden"
    case permalink
    case numReports = "num_reports"
    case locked, name, created, subreddit
    case authorFlairText = "author_flair_text"
    case collapsed
    case createdUTC = "created_utc"
    case subredditNamePrefixed = "subreddit_name_prefixed"
    case controversiality, depth
    case authorFlairBackgroundColor = "author_flair_background_color"
    case modReports = "mod_reports"
    case modNote = "mod_note"
    case distinguished
    case previousVisits = "previous_visits"
    case contentCategories = "content_categories"
  }
}

public struct Replies: Codable {
  public let collapsed: Listing<More>?
  public let expanded: Listing<Comment>?

  public init(from decoder: Decoder) throws {
    var container = try decoder.singleValueContainer()
    collapsed = try? container.decode(Listing<More>.self)
    expanded = try? container.decode(Listing<Comment>.self)
    if collapsed == nil, expanded == nil {
      container.decodeNil()
    }
  }
}
