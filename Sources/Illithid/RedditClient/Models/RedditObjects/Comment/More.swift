//
//  File.swift
//
//
//  Created by Tyler Gregory on 6/19/19.
//

import Foundation

public struct More: RedditObject {
  public let count: Int
  public let name: String
  public let id: ID36
  public let parentID: String
  public let depth: Int
  public let children: [ID36]
  
  public let type = "more"

  enum CodingKeys: String, CodingKey {
    case count, name, id, depth, children
    case parentID = "parent_id"
  }
}
