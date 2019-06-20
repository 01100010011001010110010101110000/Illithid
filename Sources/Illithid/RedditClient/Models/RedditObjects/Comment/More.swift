//
//  File.swift
//  
//
//  Created by Tyler Gregory on 6/19/19.
//

import Foundation

struct More: RedditObject {
  let count: Int
  let name: String
  let id: ID36
  let parentID: String
  let depth: Int
  let children: [ID36]
  let kind = "more"

  enum CodingKeys: String, CodingKey {
    case count, name, id
    case parentID = "parent_id"
    case depth, children
  }
}
