//
// Created by Tyler Gregory on 11/19/18.
// Copyright (c) 2018 flayware. All rights reserved.
//

#if os(OSX)
  var os = "macOS"
#elseif os(iOS)
  var os = "iOS"
#endif

import Cocoa
import Foundation

import Alamofire
import CleanroomLogger
import OAuth2
import SwiftyJSON

class OAuth2RetryHandler: RequestRetrier, RequestAdapter {
  let loader: OAuth2DataLoader

  init(oauth2: OAuth2) {
    loader = OAuth2DataLoader(oauth2: oauth2)
  }

  /// Intercept 401 and do an OAuth2 authorization.
  public func should(_: SessionManager, retry request: Request, with _: Error, completion: @escaping RequestRetryCompletion) {
    if let response = request.task?.response as? HTTPURLResponse, 401 == response.statusCode, let req = request.request {
      var dataRequest = OAuth2DataRequest(request: req, callback: { _ in })
      dataRequest.context = completion
      loader.enqueue(request: dataRequest)
      loader.attemptToAuthorize { authParams, _ in
        self.loader.dequeueAndApply() { req in
          if let comp = req.context as? RequestRetryCompletion {
            comp(nil != authParams, 0.0)
          }
        }
      }
    } else {
      completion(false, 0.0) // not a 401, not our problem
    }
  }

  /// Sign the request with the access token.
  public func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
    guard nil != loader.oauth2.accessToken else {
      return urlRequest
    }
    return try urlRequest.signed(with: loader.oauth2) // "try" added in 3.0.2
  }
}

class RedditClientBroker {
  static let clientId: String = "f7SCggcYGArzHg"
  static let redditBaseUrl: String = "https://www.reddit.com/api/v1"
  static let redirectUri: String = "illithid://oauth2/auth_callback"
  static let VERSION: String? = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
  static let REDDIT_AUTHOR: String = "Tyler1-66"

  private static var alamoConfiguration: URLSessionConfiguration = URLSessionConfiguration.default
  private static var oAuth2: OAuth2 = OAuth2(settings: [:])
  static var session: SessionManager = Alamofire.SessionManager()

  private init() {
    var headers = Alamofire.SessionManager.defaultHTTPHeaders
    let osVersion = ProcessInfo().operatingSystemVersion
    let platform = "\(os) \(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
    headers["User-Agent"] = "\(platform):\(RedditClientBroker.clientId):\(RedditClientBroker.VERSION ?? "0.0.1") (by \(RedditClientBroker.REDDIT_AUTHOR))"
    RedditClientBroker.alamoConfiguration.httpAdditionalHeaders = headers

    RedditClientBroker.session = Alamofire.SessionManager(configuration: RedditClientBroker.alamoConfiguration)
  }

  func configureOAuth2(window: NSWindow) {
    let duration: String = "permanent"
    let scope: String = "read mysubreddits"

    RedditClientBroker.oAuth2 = OAuth2CodeGrant(
      settings: [
        "client_id": RedditClientBroker.clientId,
        "client_secret": "",
        "authorize_uri": "\(RedditClientBroker.redditBaseUrl)/authorize.compact",
        "token_uri": "\(RedditClientBroker.redditBaseUrl)/access_token",
        "redirect_uris": ["illithid://oauth2/callback"],
        "scope": scope
      ] as OAuth2JSON
    )
    RedditClientBroker.oAuth2.authConfig.authorizeEmbedded = true
    RedditClientBroker.oAuth2.authConfig.authorizeContext = window
    RedditClientBroker.oAuth2.logger = OAuth2DebugLogger(.debug)

    let oAuthRetrier = OAuth2RetryHandler(oauth2: RedditClientBroker.oAuth2)
    RedditClientBroker.session.retrier = oAuthRetrier
    RedditClientBroker.session.adapter = oAuthRetrier

    if !RedditClientBroker.oAuth2.hasUnexpiredAccessToken() {
      RedditClientBroker.oAuth2.authorize(
        params: ["duration": duration], callback: { authParams, error in
          if authParams != nil {
            print("We are authorized")
          } else {
            print("Authorization failed: \(error!)")
          }
        }
      )
    }
  }

  func session() -> SessionManager {
    return RedditClientBroker.session
  }
}
