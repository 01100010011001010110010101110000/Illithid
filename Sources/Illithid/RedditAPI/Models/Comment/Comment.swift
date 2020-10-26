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

import Combine
import Foundation

import Alamofire

// MARK: - CommentsSort

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

// MARK: - Comment

public struct Comment: RedditObject {
  // MARK: Lifecycle

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    if let emptyString = try? container.decode(String.self, forKey: .replies), emptyString.isEmpty {
      replies = nil
    } else {
      let listing = try container.decode(Listing.self, forKey: .replies)
      replies = listing.comments
      more = listing.more
    }

    totalAwardsReceived = try container.decode(Int.self, forKey: .totalAwardsReceived)
    approvedAtUtc = try container.decodeIfPresent(Date.self, forKey: .approvedAtUtc)
    ups = try container.decode(Int.self, forKey: .ups)
    modReasonBy = try container.decodeIfPresent(String.self, forKey: .modReasonBy)
    bannedBy = try container.decodeIfPresent(String.self, forKey: .bannedBy)
    authorFlairType = try container.decodeIfPresent(FlairType.self, forKey: .authorFlairType)
    removalReason = try container.decodeIfPresent(String.self, forKey: .removalReason)
    linkId = try container.decode(String.self, forKey: .linkId)
    authorFlairTemplateId = try container.decodeIfPresent(String.self, forKey: .authorFlairTemplateId)
    likes = try container.decodeIfPresent(Bool.self, forKey: .likes)
    noFollow = try container.decode(Bool.self, forKey: .noFollow)
    userReports = try container.decode([String].self, forKey: .userReports)
    saved = try container.decode(Bool.self, forKey: .saved)
    id = try container.decode(ID36.self, forKey: .id)
    bannedAtUtc = try container.decodeIfPresent(Date.self, forKey: .bannedAtUtc)
    modReasonTitle = try container.decodeIfPresent(String.self, forKey: .modReasonTitle)
    gilded = try container.decode(Int.self, forKey: .gilded)
    archived = try container.decode(Bool.self, forKey: .archived)
    reportReasons = try container.decodeIfPresent([String].self, forKey: .reportReasons)
    author = try container.decode(String.self, forKey: .author)
    canModPost = try container.decode(Bool.self, forKey: .canModPost)
    sendReplies = try container.decode(Bool.self, forKey: .sendReplies)
    parentId = try container.decode(String.self, forKey: .parentId)
    score = try container.decode(Int.self, forKey: .score)
    authorFullname = try container.decodeIfPresent(String.self, forKey: .authorFullname)
    approvedBy = try container.decodeIfPresent(String.self, forKey: .approvedBy)
    allAwardings = try container.decode([Award].self, forKey: .allAwardings)
    subredditId = try container.decode(String.self, forKey: .subredditId)
    body = try container.decode(String.self, forKey: .body)
    edited = try container.decode(Edited.self, forKey: .edited)
    authorFlairCssClass = try container.decodeIfPresent(String.self, forKey: .authorFlairCssClass)
    isSubmitter = try container.decode(Bool.self, forKey: .isSubmitter)
    downs = try container.decode(Int.self, forKey: .downs)
    authorFlairRichtext = try container.decodeIfPresent([FlairRichtext].self, forKey: .authorFlairRichtext)
    collapsedReason = try? container.decodeIfPresent(String.self, forKey: .collapsedReason)
    bodyHtml = try container.decode(String.self, forKey: .bodyHtml)
    stickied = try container.decode(Bool.self, forKey: .stickied)
    subredditType = try container.decode(Subreddit.SubredditType.self, forKey: .subredditType)
    canGild = try container.decode(Bool.self, forKey: .canGild)
//    let gildings = try? container.decode([Any = try? container.decode(Any]
    authorFlairTextColor = try container.decodeIfPresent(String.self, forKey: .authorFlairTextColor)
    scoreHidden = try container.decode(Bool.self, forKey: .scoreHidden)
    permalink = try container.decode(String.self, forKey: .permalink)
    numReports = try container.decodeIfPresent(Int.self, forKey: .numReports)
    locked = try container.decode(Bool.self, forKey: .locked)
    name = try container.decode(String.self, forKey: .name)
    created = try container.decode(Date.self, forKey: .created)
    subreddit = try container.decode(String.self, forKey: .subreddit)
    authorFlairText = try container.decodeIfPresent(String.self, forKey: .authorFlairText)
    collapsed = try container.decode(Bool.self, forKey: .collapsed)
    createdUtc = try container.decode(Date.self, forKey: .createdUtc)
    subredditNamePrefixed = try container.decode(String.self, forKey: .subredditNamePrefixed)
    controversiality = try container.decode(Int.self, forKey: .controversiality)
    depth = try container.decodeIfPresent(Int.self, forKey: .depth)
    authorFlairBackgroundColor = try container.decodeIfPresent(String.self, forKey: .authorFlairBackgroundColor)
    modReports = try container.decode([String].self, forKey: .modReports)
    modNote = try container.decodeIfPresent(String.self, forKey: .modNote)
    distinguished = try container.decodeIfPresent(String.self, forKey: .distinguished)

    previousVisits = try container.decodeIfPresent([Date].self, forKey: .previousVisits)
    contentCategories = try container.decodeIfPresent([String].self, forKey: .contentCategories)
  }

  // MARK: Public

  public var type = "t1"

  public let totalAwardsReceived: Int
  public let approvedAtUtc: Date?
  public let ups: Int
  public let modReasonBy: String?
  public let bannedBy: String?
  public let authorFlairType: FlairType?
  public let removalReason: String?
  /// The `Fullname` of this comment's post
  public let linkId: Fullname
  public let authorFlairTemplateId: String?
  public var likes: Bool?
  public let noFollow: Bool

  public var replies: [Comment]?
  public var more: More?
  public let userReports: [String]
  public var saved: Bool
  public let id: ID36
  public let bannedAtUtc: Date?
  public let modReasonTitle: String?
  public let gilded: Int
  public let archived: Bool
  public let reportReasons: [String]?
  public let author: String
  public let canModPost: Bool
  public let sendReplies: Bool
  /// The `Fullname` of this comment's parent comment
  public let parentId: Fullname
  public let score: Int
  /// The `Fullname` of the comment's author. This is nil when the comment has been deleted
  public let authorFullname: Fullname?
  public let approvedBy: String?
  public let allAwardings: [Award]
  /// The `Fullname` of this comment's subreddit
  public let subredditId: Fullname
  public let body: String
  public let edited: Edited
  public let authorFlairCssClass: String?
  public let isSubmitter: Bool
  public let downs: Int
  public let authorFlairRichtext: [FlairRichtext]?
  public let collapsedReason: String?
  public let bodyHtml: String
  public let stickied: Bool
  public let subredditType: Subreddit.SubredditType
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
  public let createdUtc: Date
  public let subredditNamePrefixed: String
  public let controversiality: Int
  /// Depth is present unless fetching a comment from `/api/info` or `/search`
  public internal(set) var depth: Int?
  public let authorFlairBackgroundColor: String?
  public let modReports: [String]
  public let modNote: String?
  public let distinguished: String?
  public let previousVisits: [Date]?
  public let contentCategories: [String]?

  public var fullname: Fullname {
    "\(Kind.comment.rawValue)_\(id)"
  }

  public var isAdminComment: Bool {
    distinguished?.contains("admin") ?? false
  }

  /// Whether the author has deleted their account
  public var authorIsDeleted: Bool {
    // Removed comments also show [deleted] for the author, so disambiguate
    author == "[deleted]" && !isRemoved
  }

  /// Whether the comment has been deleted by its author
  public var isDeleted: Bool {
    body == "[deleted]"
  }

  /// Whether the comment has been removed by a moderator
  public var isRemoved: Bool {
    body == "[removed]"
  }

  public static func == (lhs: Comment, rhs: Comment) -> Bool {
    lhs.id == rhs.id
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case totalAwardsReceived = "total_awards_received"
    case approvedAtUtc = "approved_at_utc"
    case ups
    case modReasonBy = "mod_reason_by"
    case bannedBy = "banned_by"
    case authorFlairType = "author_flair_type"
    case removalReason = "removal_reason"
    case linkId = "link_id"
    case authorFlairTemplateId = "author_flair_template_id"
    case likes
    case noFollow = "no_follow"
    case replies
    case userReports = "user_reports"
    case saved
    case id
    case bannedAtUtc = "banned_at_utc"
    case modReasonTitle = "mod_reason_title"
    case gilded
    case archived
    case reportReasons = "report_reasons"
    case author
    case canModPost = "can_mod_post"
    case sendReplies = "send_replies"
    case parentId = "parent_id"
    case score
    case authorFullname = "author_fullname"
    case approvedBy = "approved_by"
    case allAwardings = "all_awardings"
    case subredditId = "subreddit_id"
    case body
    case edited
    case authorFlairCssClass = "author_flair_css_class"
    case isSubmitter = "is_submitter"
    case downs
    case authorFlairRichtext = "author_flair_richtext"
    case collapsedReason = "collapsed_reason"
    case bodyHtml = "body_html"
    case stickied
    case subredditType = "subreddit_type"
    case canGild = "can_gild"
//    case gildings
    case authorFlairTextColor = "author_flair_text_color"
    case scoreHidden = "score_hidden"
    case permalink
    case numReports = "num_reports"
    case locked
    case name
    case created
    case subreddit
    case authorFlairText = "author_flair_text"
    case collapsed
    case createdUtc = "created_utc"
    case subredditNamePrefixed = "subreddit_name_prefixed"
    case controversiality
    case depth
    case authorFlairBackgroundColor = "author_flait_background_color"
    case modReports = "mod_reports"
    case modNote = "mod_note"
    case distinguished
    case previousVisits = "previous_visits"
    case contentCategories = "content_categories"
  }
}
