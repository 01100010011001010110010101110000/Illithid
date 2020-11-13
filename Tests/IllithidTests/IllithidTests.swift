// Copyright (C) 2020 Tyler Gregory (@01100010011001010110010101110000)
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of  MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <http://www.gnu.org/licenses/>.

@testable import Illithid
import XCTest

final class IllithidTests: XCTestCase {
  static var allTests = [
    ("testCommentSingleton", testCommentSingleton),
    ("testAccountSingleton", testAccountSingleton),
  ]

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
}
