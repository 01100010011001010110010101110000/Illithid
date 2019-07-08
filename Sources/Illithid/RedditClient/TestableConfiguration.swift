//
//  File.swift
//  
//
//  Created by Tyler Gregory on 7/6/19.
//

import Foundation

import OAuthSwift

struct TestableConfiguration: ClientConfiguration {
  // MARK: OAuth2 parameters
  lazy var oauthParameters: OAuthSwift.ConfigParameters = {
    return [
      "consumerKey": consumerKey,
      "consumerSecret": consumerSecret,
      "duration": duration.rawValue,
      "authorizeUrl": "\(RedditClientBroker.baseURL)/authorize.compact",
      "accessTokenUrl": "\(RedditClientBroker.baseURL)/access_token",
      "responseType": responseType.rawValue,
      "scope": scope
    ]
  }()

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

  internal let defaults = UserDefaults.standard
}
