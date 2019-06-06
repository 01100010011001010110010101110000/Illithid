//
//  Listable.swift
//  Illithid
//
//  Created by Tyler Gregory on 3/3/19.
//  Copyright © 2019 flayware. All rights reserved.
//

import Foundation

public struct Listing<RedditType: RedditObject>: Codable {
  
  public let kind: String
  public let metadata: ListData
  
  private enum CodingKeys: String, CodingKey {
    case kind
    case metadata = "data"
  }
  
  public struct ListData: Codable {
    public let modhash: String?
    public let dist: Int
    public let children: [ListChild]
    public let after: String?
    public let before: String?
  }
  
  public struct ListChild: Codable {
    public let kind: String
    public let object: RedditType
    
    private enum CodingKeys: String, CodingKey {
      case kind
      case object = "data"
    }
  }
}
