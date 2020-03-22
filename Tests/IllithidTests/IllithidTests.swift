//
// IllithidTests.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 3/21/20
//

@testable import Illithid
import XCTest

final class IllithidTests: XCTestCase {
  func testCommentSingleton() {
    Comment.fetch(name: "t1_ernlwui") { result in
      switch result {
      case let .success(comment):
        XCTAssertEqual(comment.author, "paulfknwalsh")
      case let .failure(error):
        XCTFail(error.localizedDescription)
      }
    }
  }

  func testAccountSingleton() {
    Account.fetch(username: "Tyler1-66") { result in
      switch result {
      case let .success(account):
        XCTAssertEqual(account.name, "Tyler1-66")
      case let .failure(error):
        XCTFail(error.localizedDescription)
      }
    }
  }

  static var allTests = [
    ("testCommentSingleton", testCommentSingleton),
    ("testAccountSingleton", testAccountSingleton)
  ]
}
