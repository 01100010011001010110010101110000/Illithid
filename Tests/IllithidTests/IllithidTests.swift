@testable import Illithid
import XCTest

final class IllithidTests: XCTestCase {
  let illithid = RedditClientBroker(configuration: TestableConfiguration())

  func testCommentSingleton() {
    Comment.fetch(name: "t1_ernlwui", client: illithid) { comment in
      XCTAssertEqual(comment.author, "paulfknwalsh")
    }
  }

  static var allTests = [
    ("testCommentSingleton", testCommentSingleton),
  ]
}
