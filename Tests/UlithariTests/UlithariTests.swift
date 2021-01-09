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

@testable import Ulithari
import XCTest

final class UlithariTests: XCTestCase {
  static var allTests = [
    ("Imgur Link Type Parser", testImgurLinkType),
  ]

  func testImgurLinkType() {
    let ulithari: Ulithari = .shared

    let imageLink = URL(string: "https://i.imgur.com/sMj76cL.jpg")!
    let albumLink = URL(string: "https://imgur.com/a/7osn4XS")!
    let galleryLink = URL(string: "https://imgur.com/gallery/q2cO84x")!

    XCTAssertTrue(ulithari.imgurLinkType(imageLink)! == Ulithari.ImgurLinkType.image(id: "sMj76cL"))
    XCTAssertTrue(ulithari.imgurLinkType(albumLink)! == Ulithari.ImgurLinkType.album(id: "7osn4XS"))
    XCTAssertTrue(ulithari.imgurLinkType(galleryLink)! == Ulithari.ImgurLinkType.gallery(id: "q2cO84x"))
  }

  func testRedGfy() {
    let ulithari: Ulithari = .shared

    let id: String = "scratchyfinishedairedaleterrier"
    var item: RedGfyItem? = nil

    let expectation = self.expectation(description: "Fetch Gfy")

    _ = ulithari.fetchRedGif(id: id) { result in
      switch result {
      case let .success(fetched):
        item = fetched
      case let .failure(error):
        print(error.localizedDescription)
      }
      expectation.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
    XCTAssertTrue(item != nil && item!.gfyId == "scratchyfinishedairedaleterrier")
  }
}
