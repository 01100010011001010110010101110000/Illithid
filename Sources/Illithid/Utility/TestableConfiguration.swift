//
// TestableConfiguration.swift
// Copyright (c) 2019 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 12/24/19
//

import Foundation

import OAuthSwift

struct TestableConfiguration: ClientConfiguration {
  /// Application OAuth2 callback URL
  let redirectURI = URL(string: "illithid://oauth2/callback")!
  /// The version of Illithid
  let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.1"
  /// The author's Reddit username
  let author = "Tyler1-66" // swiftlint:disable:this identifier_name

  let consumerKey = "TEST"

  let consumerSecret = ""

  let scope = "TEST"

  let responseType: OAuthResponseType = .code

  let duration: Duration = .permanent
}
