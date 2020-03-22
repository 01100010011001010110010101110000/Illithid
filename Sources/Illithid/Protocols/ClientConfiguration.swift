//
// ClientConfiguration.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 3/21/20
//

import Foundation

import OAuthSwift

public enum OAuthResponseType: String {
  case code
  case token
}

public enum Duration: String {
  case temporary
  case permanent
}

public protocol ClientConfiguration {
  var consumerKey: String { get }
  var consumerSecret: String { get }
  var redirectURI: URL { get }
  var scope: String { get }
  var responseType: OAuthResponseType { get }
  var duration: Duration { get }
  var author: String { get }
  var version: String { get }
}

extension ClientConfiguration {
  var oauthParameters: OAuthSwift.ConfigParameters {
    [
      "consumerKey": consumerKey,
      "consumerSecret": consumerSecret,
      "duration": duration.rawValue,
      "authorizeUrl": Illithid.authorizeEndpoint.absoluteString,
      "accessTokenUrl": Illithid.tokenEndpoint.absoluteString,
      "responseType": responseType.rawValue,
      "scope": scope
    ]
  }
}
