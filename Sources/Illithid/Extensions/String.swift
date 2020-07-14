//
// String.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 3/21/20
//

import Foundation

struct Stack<Element> {
  private var array: [Element] = []
  mutating func push(_ element: Element) {
    array.append(element)
  }

  mutating func pop() -> Element? {
    array.popLast()
  }

  func peek() -> Element? {
    array.last
  }

  func count() -> Int {
    array.count
  }

  func isEmpty() -> Bool {
    array.isEmpty
  }
}

extension String {
  func iFrameSrc() -> URL? {
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
    // TODO: Implement
    [:]
  }
}

extension String {
  func snakeCased() -> String? {
    let pattern = "([a-z0-9])([A-Z])"

    let regex = try? NSRegularExpression(pattern: pattern, options: [])
    let range = NSRange(location: 0, length: count)
    return regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2").lowercased()
  }
}
