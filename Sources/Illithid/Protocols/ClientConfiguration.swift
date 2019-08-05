//
//  File.swift
//  
//
//  Created by Tyler Gregory on 6/13/19.
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

  var defaults: UserDefaults { get }

  var oauthParameters: OAuthSwift.ConfigParameters { mutating get }
}
