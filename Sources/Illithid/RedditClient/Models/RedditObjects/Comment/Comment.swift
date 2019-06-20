//
//  File.swift
//  
//
//  Created by Tyler Gregory on 6/19/19.
//

import Foundation

public struct Comment: RedditObject {
  let totalAwardsReceived: Int
  let approvedAtUTC: Date
  let ups: Int
  let modReasonBy, bannedBy: String?
  let authorFlairType: String
  let removalReason: String?
  let linkID: String
  let authorFlairTemplateID: String?
  let likes: String?
  let noFollow: Bool
  let replies: Replies
  let userReports: [String]
  let saved: Bool
  let id: ID36
  let bannedAtUTC: Date?
  let modReasonTitle: String?
  let gilded: Int
  let archived: Bool
  let reportReasons: String?
  let author: String
  let canModPost, sendReplies: Bool
  // This is actually a fullname
  let parentID: String
  let score: Int
  let authorFullname: String
  let approvedBy: String?
  let allAwardings: [Award]
  // This is actually a fullname
  let subredditID: String
  let body: String
  let edited: Bool
  let authorFlairCSSClass: String?
  let isSubmitter: Bool
  let downs: Int
  let authorFlairRichtext: [String]
  let authorPatreonFlair: Bool
  let collapsedReason: String?
  let bodyHTML: String
  let stickied: Bool
  let subredditType: String
  let canGild: Bool
  let gildings: [Any: Any]
  let authorFlairTextColor: String?
  let scoreHidden: Bool
  let permalink: String
  let numReports: Int?
  let locked: Bool
  let name: String
  let created: Date
  let subreddit: String
  let authorFlairText: String?
  let collapsed: Bool
  let createdUTC: Date
  let subredditNamePrefixed: String
  let controversiality: Int
  let depth: Int
  let authorFlairBackgroundColor: String?
  let modReports: [String]
  let modNote: String?
  let distinguished: String?

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
    case gildings
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
  }
}
