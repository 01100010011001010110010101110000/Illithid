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
public final class RedditClientBroker {
  private enum baseURLs: String, Codable {
    case unauthenticated = "https://api.reddit.com/"
    case authenticated = "https://oauth.reddit.com/"
  }
  public var baseURL: URL {
    accounts.currentAccount != nil ? URL(string: baseURLs.authenticated.rawValue)! : URL(string: baseURLs.unauthenticated.rawValue)!
  }
  public static let authorizeEndpoint: URL = URL(string: "https://www.reddit.com/api/v1/authorize.compact")!
  public static let tokenEndpoint: URL = URL(string: "https://www.reddit.com/api/v1/access_token")!

  /// Reddit API's base URL
  static public let baseURL: URL = URL(string: "https://www.reddit.com/api/v1")!

  public typealias AccountTokenTuple = (account: RedditAccount, credential: OAuthSwiftCredential)

  let session: SessionManager
  public let imageDownloader: ImageDownloader

  let logger: Logger

  public let accounts: AccountManager

  public var configuration: ClientConfiguration

  public init(
    sharedLogger: Logger = Logger(
      logLevels: [.all],
      writers: [ConsoleWriter()],
      executionMethod: .asynchronous(
        queue: DispatchQueue(label: "log.queue", qos: .utility)
      )
    ),
    sharedImageDownloader: ImageDownloader = ImageDownloader(maximumActiveDownloads: 20),
    configuration: ClientConfiguration
  ) {
    logger = sharedLogger
    imageDownloader = sharedImageDownloader
    self.configuration = configuration

    session = Self.makeSessionManager(configuration)
    accounts = AccountManager(logger: logger, configuration: self.configuration, session: session)
  }

  static func makeSessionManager(_ configuration: ClientConfiguration) -> SessionManager {
    let alamoConfiguration = URLSessionConfiguration.default
    let osVersion = ProcessInfo().operatingSystemVersion
    let userAgentComponents = [
      "macOS \(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)",
      "\(configuration.consumerKey)",
      "\(configuration.version) (by \(configuration.author))"
    ]
    let headers = [
      "User-Agent": userAgentComponents.joined(separator: ":"),
      "Accept": "application/json",
      "Content-Type": "application/json"
    ]
    alamoConfiguration.httpAdditionalHeaders = headers

    return SessionManager(configuration: alamoConfiguration)
  }
}
