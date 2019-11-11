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
