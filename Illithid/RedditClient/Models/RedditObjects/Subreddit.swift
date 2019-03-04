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
  var id: String  //swiftlint:disable:this identifier_name
  var name: String
  var type: String
}
