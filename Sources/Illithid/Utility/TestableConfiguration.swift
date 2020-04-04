//
// TestableConfiguration.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 3/21/20
//

import Foundation

import OAuthSwift

struct TestableConfiguration: ClientConfiguration {
  /// Application OAuth2 callback URL
  let redirectURI = URL(string: "illithid://oauth2/callback")!
  /// The version of Illithid
  let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.1"
  /// The author's Reddit username
  let author = "Tyler1-66"

  let consumerKey = "TEST"

  let consumerSecret = ""

  let scope = "TEST"

  let responseType: OAuthResponseType = .code

  let duration: Duration = .permanent
}
