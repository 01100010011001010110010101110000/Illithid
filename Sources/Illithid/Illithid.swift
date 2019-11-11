//
// Created by Tyler Gregory on 11/19/18.
// Copyright (c) 2018 flayware. All rights reserved.
//

import AuthenticationServices
import Cocoa
import Foundation

import Alamofire
import OAuthSwift
import Willow

/// Handles Reddit API meta-operations
open class Illithid: ObservableObject {
  public static var shared: Illithid = .init()

  private enum baseURLs: String, Codable {
    case unauthenticated = "https://api.reddit.com/"
    case authenticated = "https://oauth.reddit.com/"
  }

  public var baseURL: URL {
    accountManager.currentAccount != nil ? URL(string: baseURLs.authenticated.rawValue)! : URL(string: baseURLs.unauthenticated.rawValue)!
  }

  public static let authorizeEndpoint: URL = URL(string: "https://www.reddit.com/api/v1/authorize.compact")!
  public static let tokenEndpoint: URL = URL(string: "https://www.reddit.com/api/v1/access_token")!

  open var logger: Logger

  // TODO: Make this private
  public let accountManager: AccountManager

  internal let decoder: JSONDecoder = .init()

  internal var session: SessionManager

  private init() {
    #if DEBUG
      logger = .debugLogger()
    #else
      logger = .releaseLogger(subsystem: "com.illithid.illithid")
    #endif

    accountManager = AccountManager(logger: logger)
    session = accountManager.makeSession(for: accountManager.currentAccount)

    decoder.dateDecodingStrategy = .secondsSince1970
    decoder.keyDecodingStrategy = .convertFromSnakeCase
  }

  public func configure(configuration: ClientConfiguration) {
    accountManager.configuration = configuration
    session.session.invalidateAndCancel()
    session = accountManager.makeSession(for: accountManager.currentAccount)
  }
}
