//
// Created by Tyler Gregory on 11/19/18.
// Copyright (c) 2018 flayware. All rights reserved.
//

import Cocoa
import Foundation

import Alamofire
import CleanroomLogger
import KeychainAccess
import OAuthSwift
import OAuthSwiftAlamofire

/// Handles Reddit API meta-operations
final class RedditClientBroker {
  typealias accountTokenTuple = (account: RedditAccount, credential: OAuthSwiftCredential)

  static let broker: RedditClientBroker = RedditClientBroker()

  /// Reddit API's base URL
  static let redditBaseUrl: URL = URL(string: "https://www.reddit.com/api/v1")!
  /// Reddit's OAuth2 protected API endpoint
  static let redditOAuthBaseUrl: URL = URL(string: "https://oauth.reddit.com/api/v1")!
  /// Application OAuth2 callback URL
  static let redirectUri: URL = URL(string: "illithid://oauth2/callback")!

  /// The version of Illithid
  static let VERSION: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.1"
  /// The author's Reddit username
  static let REDDIT_AUTHOR: String = "Tyler1-66"

  // MARK: OAuth2 parameters

  static let clientId: String = "f7SCggcYGArzHg"
  static let duration: String = "permanent"
  static let scope: String = "identity mysubreddits read vote wikiread"

  private static let keychain = Keychain(server: RedditClientBroker.redditBaseUrl, protocolType: .https)
    .synchronizable(true)
  static let defaults = UserDefaults.standard
  let session: SessionManager

  private static var clients = [String: accountTokenTuple]()
  private var currentAccount: RedditAccount?

  private init() {
    Log.debug?.message("Loading Reddit accounts...")

    let alamoConfiguration = URLSessionConfiguration.default
    let osVersion = ProcessInfo().operatingSystemVersion
    let platform = "macOS \(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
    let headers = [
      "User-Agent": "\(platform):\(RedditClientBroker.clientId):\(RedditClientBroker.VERSION) (by \(RedditClientBroker.REDDIT_AUTHOR))",
      "Accept": "application/json",
      "Content-Type": "application/json"
    ]
    alamoConfiguration.httpAdditionalHeaders = headers
    session = SessionManager(configuration: alamoConfiguration)

    loadSavedAccounts {
      if let lastSelectedAccount = RedditClientBroker.defaults.string(forKey: "SelectedAccount") {
        Log.debug?.message("Setting \(lastSelectedAccount) as current account")
        RedditClientBroker.broker.setCurrentAccount(name: lastSelectedAccount)
      }
    }
  }

  func loadSavedAccounts(completion _: @escaping () -> Void) {
    let decoder = JSONDecoder()
    let savedAccounts = RedditClientBroker.defaults.stringArray(forKey: "RedditUsernames") ?? []

    /// ToDo: Ensure there is no race condition in this loop
    for account in savedAccounts {
      Log.debug?.message("...Loading \(account)")
      let credential: OAuthSwiftCredential = try! decoder.decode(OAuthSwiftCredential.self, from: RedditClientBroker.keychain.getData(account)!)
      Log.debug?.message("Found refresh token: \(credential.oauthRefreshToken) for \(account)")
      let oauth = OAuth2Swift(
        consumerKey: RedditClientBroker.clientId,
        consumerSecret: "",
        authorizeUrl: "\(RedditClientBroker.redditBaseUrl)/authorize.compact",
        accessTokenUrl: "\(RedditClientBroker.redditBaseUrl)/access_token",
        responseType: "code"
      )
      oauth.accessTokenBasicAuthentification = true
      oauth.client = OAuthSwiftClient(credential: credential)
      session.adapter = OAuthSwiftRequestAdapter(oauth)
      session.retrier = OAuthSwiftRequestAdapter(oauth) as? RequestRetrier

      Log.debug?.message("...Fetching \(account) data")
      session.request("https://oauth.reddit.com/api/v1/me", method: .get).validate().responseData { response in
        switch response.result {
        case .success:
          if let data = response.data {
            Log.debug?.message("...Loaded \(account):\n\(String(decoding: data, as: UTF8.self))")
            let accountObject = try! decoder.decode(RedditAccount.self, from: data)
            RedditClientBroker.clients[account] = (account: accountObject, credential: oauth.client.credential)
          } else {
            Log.error?.message("Retrieved nothing for account: \(account)")
          }

        case let .failure(error):
          Log.error?.message("Failed to retrieve account data: \(error)")
        }
      }
    }
  }

  func setCurrentAccount(name username: String) {
    Log.debug?.message("Username to save: \(username)")
    if let accountDetails = RedditClientBroker.clients[username] {
      currentAccount = accountDetails.account
      RedditClientBroker.defaults.set(username, forKey: "SelectedAccount")
      let oauth = OAuth2Swift(
        consumerKey: RedditClientBroker.clientId,
        consumerSecret: "",
        authorizeUrl: "\(RedditClientBroker.redditBaseUrl)/authorize.compact",
        accessTokenUrl: "\(RedditClientBroker.redditBaseUrl)/access_token",
        responseType: "code"
      )
      oauth.accessTokenBasicAuthentification = true
      oauth.client = OAuthSwiftClient(credential: (accountDetails.credential))
      session.adapter = OAuthSwiftRequestAdapter(oauth)
      session.retrier = OAuthSwiftRequestAdapter(oauth) as? RequestRetrier
    } else {
      Log.error?.message("Failed to set current account to: \(username)")
    }
  }

  /**
   Fetches the account data for a new account when the OAuth2 conversation is complete
   and persists its data to the keychain and `UserDefaults`

   - Parameter oauth: The account's newly populated OAuth2Swift object

   - Precondition: The `authorize` method must have returned successfully on `oauth` prior to invocation

   - ToDo: Persist the client credential to keychain (it conforms to Codable)
   */
  func fetchNewAccount(oauth: OAuth2Swift, completion: @escaping () -> Void) {
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    oauth.client.get(
      "https://oauth.reddit.com/api/v1/me",
      success: { response in
        let account = try! decoder.decode(RedditAccount.self, from: response.data)

        RedditClientBroker.clients[account.name] = (account: account, credential: oauth.client.credential)
        RedditClientBroker.broker.setCurrentAccount(name: account.name)
        var savedAccounts = RedditClientBroker.defaults.stringArray(forKey: "RedditUsernames") ?? []
        savedAccounts.append(account.name)
        RedditClientBroker.defaults.set(savedAccounts, forKey: "RedditUsernames")

        try! RedditClientBroker.keychain.set(try! encoder.encode(oauth.client.credential), key: account.name)

        completion()
      },
      failure: { error in
        Log.error?.message("User profile fetch failed: \(error)")
      }
    )
  }

  func addAccount(window _: NSWindow, completion: @escaping () -> Void) {
    let oauth = OAuth2Swift(
      consumerKey: RedditClientBroker.clientId,
      consumerSecret: "",
      authorizeUrl: "\(RedditClientBroker.redditBaseUrl)/authorize.compact",
      accessTokenUrl: "\(RedditClientBroker.redditBaseUrl)/access_token",
      responseType: "code"
    )
    oauth.accessTokenBasicAuthentification = true

    let state = ((0 ... 11).map { _ in Int.random(in: (0 ... 9)) }).reduce("") {
      (accumulator: String, next: Int) -> String in
      return accumulator + String(next)
    }
    var defaultOAuthParams = oauth.parameters
    defaultOAuthParams["duration"] = "permanent"

    oauth.authorize(
      withCallbackURL: RedditClientBroker.redirectUri,
      scope: RedditClientBroker.scope,
      state: state, parameters: defaultOAuthParams,
      success: { _, _, parameters in
        Log.debug?.message("Authorization successful")
        Log.debug?.message("Returned parameters: \(parameters)")
        Log.debug?.message("OAuth object parameters: \(oauth.parameters)")
        self.fetchNewAccount(oauth: oauth, completion: completion)
      },
      failure: { error in
        Log.error?.message("Authorization failed: \(error)")
      }
    )
  }

  func removeAccount(toRemove username: String) {
    /// Remove username from saved account names
    let accounts = RedditClientBroker.defaults.stringArray(forKey: "RedditUsernames") ?? []
    let filteredAccounts = accounts.filter { username != $0 }
    RedditClientBroker.defaults.set(filteredAccounts, forKey: "RedditUsernames")

    /// Remove user credentials from the keychain
    /// ToDo: Implement error handling
    try? RedditClientBroker.keychain.remove(username)
  }
}
