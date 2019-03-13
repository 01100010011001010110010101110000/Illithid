//
//  Listable.swift
//  Illithid
//
//  Created by Tyler Gregory on 3/3/19.
//  Copyright © 2019 flayware. All rights reserved.
//

import Foundation

struct Listable<RedditType: RedditObject>: Codable {
  
  let kind: String
  let data: ListableData
  
  struct ListableData: Codable {
    let modhash: String?
    let dist: Int
    let children: [ListableChild]
    let after: String?
    let before: String?
  }
  
  struct ListableChild: Codable {
    let kind: String
    let data: RedditType
  }
}
