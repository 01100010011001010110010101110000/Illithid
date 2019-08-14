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
  public let parentId: String
  public let depth: Int
  public let children: [ID36]
}
