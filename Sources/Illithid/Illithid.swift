//
// Created by Tyler Gregory on 11/19/18.
// Copyright (c) 2018 flayware. All rights reserved.
//

import AuthenticationServices
import Cocoa
import Foundation

import Alamofire
import AlamofireImage
import OAuthSwift
import Willow

/// Handles Reddit API meta-operations
open class RedditClientBroker: ObservableObject {
  public static var shared: RedditClientBroker = .init(configuration: TestableConfiguration())

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

  public private(set) var configuration: ClientConfiguration 

  internal let decoder: JSONDecoder = .init()

  internal var session: SessionManager

  private init(configuration: ClientConfiguration) {
    #if DEBUG
    self.logger = .debugLogger()
    #else
    self.logger = .releaseLogger(subsystem: "com.illithid.illithid")
    #endif
    self.configuration = configuration

    self.accountManager = AccountManager(logger: logger,
                                         configuration: self.configuration)
    self.session = accountManager.makeSession(for: accountManager.currentAccount)

    decoder.dateDecodingStrategy = .secondsSince1970
    decoder.keyDecodingStrategy = .convertFromSnakeCase
  }

  public func configure(configuration: ClientConfiguration) {
    self.configuration = configuration
    accountManager.configuration = configuration
    session.session.invalidateAndCancel()
    session = accountManager.makeSession(for: accountManager.currentAccount)
  }
}
