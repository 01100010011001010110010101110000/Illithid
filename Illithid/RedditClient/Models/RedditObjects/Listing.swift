//
//  Listable.swift
//  Illithid
//
//  Created by Tyler Gregory on 3/3/19.
//  Copyright © 2019 flayware. All rights reserved.
//

import Foundation

struct Listing<RedditType: RedditObject>: Codable {
  
  let kind: String
  let metadata: ListData
  
  enum CodingKeys: String, CodingKey {
    case kind
    case metadata = "data"
  }
  
  struct ListData: Codable {
    let modhash: String?
    let dist: Int
    let children: [ListChild]
    let after: String?
    let before: String?
  }
  
  struct ListChild: Codable {
    let kind: String
    let object: RedditType
    
    enum CodingKeys: String, CodingKey {
      case kind
      case object = "data"
    }
  }
}
