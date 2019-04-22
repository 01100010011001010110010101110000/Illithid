//
//  StringInterpolation+Listable.swift
//  Illithid
//
//  Created by Tyler Gregory on 4/17/19.
//  Copyright © 2019 flayware. All rights reserved.
//

import Foundation

extension String.StringInterpolation {
  mutating func appendInterpolation(_ value: Listable<Subreddit>) {
    appendInterpolation("""
      dist: \(value.metadata.dist)
      before: \(value.metadata.before ?? "")
      after: \(value.metadata.after ?? "")
      subreddits count: \(value.metadata.children.count)
      subreddits: \(value.metadata.children.map { $0.object.displayName })
    """)
  }
}
