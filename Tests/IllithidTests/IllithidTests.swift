//
// IllithidTests.swift
// Copyright (c) 2019 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 12/24/19
//

@testable import Illithid
import XCTest

final class IllithidTests: XCTestCase {
  let illithid: Illithid = .shared

  func testCommentSingleton() {
    Comment.fetch(name: "t1_ernlwui", client: illithid) { result in
      switch result {
      case let .success(comment):
        XCTAssertEqual(comment.author, "paulfknwalsh")
      case let .failure(error):
        XCTFail(error.localizedDescription)
      }
    }
  }

  static var allTests = [
    ("testCommentSingleton", testCommentSingleton),
  ]
}
