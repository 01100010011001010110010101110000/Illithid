//
//  File.swift
//  
//
//  Created by Tyler Gregory on 6/20/19.
//

import Foundation

struct CommentsReply: Codable {

  let post: Listing<Post>
  let comments: Listing<Comment>

  init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()

    post = try container.decode(Listing<Post>.self)
    comments = try container.decode(Listing<Comment>.self)
  }
}
