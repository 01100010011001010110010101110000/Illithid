//
// Created by Tyler Gregory on 11/19/18.
// Copyright (c) 2018 flayware. All rights reserved.
//

import Cocoa
import Foundation

import Alamofire
import AlamofireImage
import OAuthSwift
import Willow

/// Handles Reddit API meta-operations
open class RedditClientBroker {
  public static var shared: RedditClientBroker = .init(configuration: TestableConfiguration())

  private enum baseURLs: String, Codable {
    case unauthenticated = "https://api.reddit.com/"
    case authenticated = "https://oauth.reddit.com/"
  }

  public var baseURL: URL {
    accounts.currentAccount != nil ? URL(string: baseURLs.authenticated.rawValue)! : URL(string: baseURLs.unauthenticated.rawValue)!
  }

  public static let authorizeEndpoint: URL = URL(string: "https://www.reddit.com/api/v1/authorize.compact")!
  public static let tokenEndpoint: URL = URL(string: "https://www.reddit.com/api/v1/access_token")!

  open var imageDownloader: ImageDownloader

  open var logger: Logger

  // TODO: Make this private
  public let accounts: AccountManager

  public var configuration: ClientConfiguration

  internal let decoder: JSONDecoder = .init()

  internal let session: SessionManager

  private init(configuration: ClientConfiguration) {
    #if DEBUG
    self.logger = .debugLogger()
    #else
    self.logger = .releaseLogger(subsystem: "com.illithid.illithid")
    #endif
    self.imageDownloader = ImageDownloader(maximumActiveDownloads: 20)
    self.configuration = configuration

    self.session = Self.makeSessionManager(configuration: configuration)
    self.accounts = AccountManager(logger: logger, configuration: self.configuration, session: session)

    decoder.dateDecodingStrategy = .secondsSince1970
    decoder.keyDecodingStrategy = .convertFromSnakeCase
  }

  public func configure(configuration: ClientConfiguration) {
    self.configuration = configuration
  }

  private static func makeSessionManager(configuration: ClientConfiguration) -> SessionManager {
    let alamoConfiguration = URLSessionConfiguration.default
    let osVersion = ProcessInfo().operatingSystemVersion
    let userAgentComponents = [
      "macOS \(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)",
      "\(configuration.consumerKey)",
      "\(configuration.version) (by \(configuration.author))"
    ]
    let headers = SessionManager.defaultHTTPHeaders.merging([
      "User-Agent": userAgentComponents.joined(separator: ":"),
      "Accept": "application/json"
    ]) { _, new in new }
    alamoConfiguration.httpAdditionalHeaders = headers

    return SessionManager(configuration: alamoConfiguration)
  }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension RedditClientBroker: ObservableObject {}
