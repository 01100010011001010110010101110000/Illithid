@testable import Illithid
import XCTest

final class IllithidTests: XCTestCase {
  let illithid = Illithid(configuration: TestableConfiguration())

  func testCommentSingleton() {
    Comment.fetch(name: "t1_ernlwui", client: illithid) { result in
      switch result {
      case .success(let comment):
        XCTAssertEqual(comment.author, "paulfknwalsh")
      case .failure(let error):
        XCTFail(error.localizedDescription)
      }
    }
  }

  static var allTests = [
    ("testCommentSingleton", testCommentSingleton),
  ]
}
