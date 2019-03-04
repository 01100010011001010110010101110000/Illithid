//
//  Listable.swift
//  Illithid
//
//  Created by Tyler Gregory on 3/3/19.
//  Copyright © 2019 flayware. All rights reserved.
//

import Foundation

struct Listable<RedditType: RedditObject>: Codable {
  
  struct ListableData: Codable {
    let modhash: String
    let dist: Int
    let children: [RedditType]
    let after: String
    let before: String
  }
  
  let kind: String
  let data: ListableData
}
