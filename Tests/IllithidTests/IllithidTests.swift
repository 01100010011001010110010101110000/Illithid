import XCTest
@testable import Illithid

final class IllithidTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Illithid().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
