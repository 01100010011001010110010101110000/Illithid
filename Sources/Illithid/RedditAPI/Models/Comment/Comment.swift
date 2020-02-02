//
// Comment.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 12/24/19
//

import Combine
import Foundation

import Alamofire

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
  public let approvedAtUtc: Date?
  public let ups: Int
  public let modReasonBy: String?
  public let bannedBy: String?
  public let authorFlairType: String?
  public let removalReason: String?
  /// The `Fullname` of this comment's post
  public let linkId: Fullname
  public let authorFlairTemplateId: String?
  public let likes: Bool?
  public let noFollow: Bool
  public let replies: Listing?
  public let userReports: [String]
  public let saved: Bool
  public let id: ID36
  public var fullname: Fullname {
    "\(Kind.comment.rawValue)_\(id)"
  }
  public let bannedAtUtc: Date?
  public let modReasonTitle: String?
  public let gilded: Int
  public let archived: Bool
  public let reportReasons: String?
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
  public let authorFlairRichtext: [[String: String]]?
  public let collapsedReason: String?
  public let bodyHtml: String
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
  public let createdUtc: Date
  public let subredditNamePrefixed: String
  public let controversiality: Int
  /// Depth is present unless fetching a comment from `/api/info` or `/search`
  public let depth: Int?
  public let authorFlairBackgroundColor: String?
  public let modReports: [String]
  public let modNote: String?
  public let distinguished: String?

  public let previousVisits: [Date]?
  public let contentCategories: [String]?

  enum CodingKeys: String, CodingKey {
    case totalAwardsReceived
    case approvedAtUtc
    case ups
    case modReasonBy
    case bannedBy
    case authorFlairType
    case removalReason
    case linkId
    case authorFlairTemplateId
    case likes
    case noFollow
    case replies
    case userReports
    case saved
    case id
    case bannedAtUtc
    case modReasonTitle
    case gilded
    case archived
    case reportReasons
    case author
    case canModPost
    case sendReplies
    case parentId
    case score
    case authorFullname
    case approvedBy
    case allAwardings
    case subredditId
    case body
    case edited
    case authorFlairCssClass
    case isSubmitter
    case downs
    case authorFlairRichtext
    case collapsedReason
    case bodyHtml
    case stickied
    case subredditType
    case canGild
//    case gildings
    case authorFlairTextColor
    case scoreHidden
    case permalink
    case numReports
    case locked
    case name
    case created
    case subreddit
    case authorFlairText
    case collapsed
    case createdUtc
    case subredditNamePrefixed
    case controversiality
    case depth
    case authorFlairBackgroundColor
    case modReports
    case modNote
    case distinguished
    case previousVisits
    case contentCategories
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    if let emptyString = try? container.decode(String.self, forKey: .replies), emptyString.isEmpty {
      replies = nil
    } else {
      replies = try container.decode(Listing.self, forKey: .replies)
    }

    totalAwardsReceived = try container.decode(Int.self, forKey: .totalAwardsReceived)
    approvedAtUtc = try container.decodeIfPresent(Date.self, forKey: .approvedAtUtc)
    ups = try container.decode(Int.self, forKey: .ups)
    modReasonBy = try container.decodeIfPresent(String.self, forKey: .modReasonBy)
    bannedBy = try container.decodeIfPresent(String.self, forKey: .bannedBy)
    authorFlairType = try container.decodeIfPresent(String.self, forKey: .authorFlairType)
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
    reportReasons = try container.decodeIfPresent(String.self, forKey: .reportReasons)
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
    authorFlairRichtext = try container.decodeIfPresent([[String: String]].self, forKey: .authorFlairRichtext)
    collapsedReason = try? container.decodeIfPresent(String.self, forKey: .collapsedReason)
    bodyHtml = try container.decode(String.self, forKey: .bodyHtml)
    stickied = try container.decode(Bool.self, forKey: .stickied)
    subredditType = try container.decode(String.self, forKey: .subredditType)
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
    modNote = try container.decode(String?.self, forKey: .modNote)
    distinguished = try container.decode(String?.self, forKey: .distinguished)

    previousVisits = try container.decodeIfPresent([Date].self, forKey: .previousVisits)
    contentCategories = try container.decodeIfPresent([String].self, forKey: .contentCategories)
  }
}
