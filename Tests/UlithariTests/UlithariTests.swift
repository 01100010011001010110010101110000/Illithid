//
// UlithariTests.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 4/27/20
//

@testable import Ulithari
import XCTest

final class UlithariTests: XCTestCase {
  func testImgurLinkType() {
    let ulithari: Ulithari = .shared

    let imageLink = URL(string: "https://i.imgur.com/sMj76cL.jpg")!
    let albumLink = URL(string: "https://imgur.com/a/7osn4XS")!
    let galleryLink = URL(string: "https://imgur.com/gallery/q2cO84x")!

    XCTAssertTrue(ulithari.imgurLinkType(imageLink)! == Ulithari.ImgurLinkType.image(id: "sMj76cL"))
    XCTAssertTrue(ulithari.imgurLinkType(albumLink)! == Ulithari.ImgurLinkType.album(id: "7osn4XS"))
    XCTAssertTrue(ulithari.imgurLinkType(galleryLink)! == Ulithari.ImgurLinkType.gallery(id: "q2cO84x"))
  }

  static var allTests = [
    ("Imgur Link Type Parser", testImgurLinkType)
  ]
}
