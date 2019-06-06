//
//  String+parsing.swift
//  Illithid
//
//  Created by Tyler Gregory on 5/4/19.
//  Copyright © 2019 flayware. All rights reserved.
//

import Foundation

struct Stack<Element> {
  fileprivate var array: [Element] = []
  mutating func push(_ element: Element) {
    array.append(element)
  }
  mutating func pop() -> Element? {
    return array.popLast()
  }
  func peek() -> Element? {
    return array.last
  }
  func count() -> Int {
    return array.count
  }
  func isEmpty() -> Bool {
    return array.isEmpty
  }
}

extension String {
  func iFrameSrc () -> URL? {
    guard let range = self.range(of: "src") else { return nil }
    var urlString = ""
    var quotes = 0
    for char in self[range.upperBound...] {
      if char == "=" { continue }
      if char == "\"" { quotes += 1; continue }
      if quotes == 2 { break }
      urlString.append(char)
    }
    return URL(string: urlString)
  }
  
  func htmlToDict() -> [String: Any] {
    //TODO Implement
    return [:]
  }
}
