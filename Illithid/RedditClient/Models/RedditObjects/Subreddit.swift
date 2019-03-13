//
// Created by Tyler Gregory on 11/19/18.
// Copyright (c) 2018 flayware. All rights reserved.
//

import Foundation

enum SubredditSort {
  case popular
  case new
  case gold
  case `default`
}

class Subreddit: RedditObject {
  let id: String  //swiftlint:disable:this identifier_name
  let name: String
  let type: String = "t5"
  let publicDescription: String
  let displayName: String
  let wikiEnabled: Bool?
  let headerImage: URL?
  let over18: Bool
  let createdUTC: Date
  
  enum CodingKeys: String, CodingKey {
    case id //swiftlint:disable:this identifier_name
    case name
    case publicDescription = "public_description"
    case displayName = "display_name"
    case wikiEnabled = "wiki_enabled"
    case headerImage = "header_img"
    case over18
    case createdUTC = "created_utc"
  }
}
