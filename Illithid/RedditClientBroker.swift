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

  let baseParameters: [String: String] = [
    "consumerKey": "f7SCggcYGArzHg",
    "consumerSecret": "",
    "duration": "permanent",
    "authorizeUrl": "\(RedditClientBroker.redditBaseUrl)/authorize.compact",
    "accessTokenUrl": "\(RedditClientBroker.redditBaseUrl)/access_token",
    "responseType": "code",
    "scope": "identity mysubreddits read vote wikiread"
  ]

  private let keychain = Keychain(server: RedditClientBroker.redditBaseUrl, protocolType: .https).synchronizable(true)
  private let defaults = UserDefaults.standard
  let session: SessionManager

  private var clients = [String: accountTokenTuple]()
  private var currentAccount: RedditAccount?

  private init() {
    Log.debug?.message("Loading Reddit accounts...")

    let alamoConfiguration = URLSessionConfiguration.default
    let osVersion = ProcessInfo().operatingSystemVersion
    let platform = "macOS \(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
    let headers = [
      "User-Agent": "\(platform):\(self.baseParameters["consumerKey"]!):\(RedditClientBroker.VERSION) (by \(RedditClientBroker.REDDIT_AUTHOR))",
      "Accept": "application/json",
      "Content-Type": "application/json"
    ]
    alamoConfiguration.httpAdditionalHeaders = headers
    session = SessionManager(configuration: alamoConfiguration)

    loadSavedAccounts {
      if let lastSelectedAccount = self.defaults.string(forKey: "SelectedAccount") {
        Log.debug?.message("Setting \(lastSelectedAccount) as current account")
        RedditClientBroker.broker.setCurrentAccount(name: lastSelectedAccount)
      }
    }
  }

  func loadSavedAccounts(completion _: @escaping () -> Void) {
    let decoder = JSONDecoder()
    let savedAccounts = defaults.stringArray(forKey: "RedditUsernames") ?? []

    /// ToDo: Ensure there is no race condition in this loop
    for account in savedAccounts {
      let credential: OAuthSwiftCredential = try! decoder.decode(OAuthSwiftCredential.self, from: keychain.getData(account)!)
      Log.debug?.message("Found refresh token: \(credential.oauthRefreshToken) for \(account)")
      let oauth = OAuth2Swift(parameters: baseParameters)!
      oauth.accessTokenBasicAuthentification = true
      oauth.client = OAuthSwiftClient(credential: credential)
      session.adapter = oauth.requestAdapter
      session.retrier = oauth.requestAdapter

      Log.debug?.message("...Loading \(account)")
      session.request("https://oauth.reddit.com/api/v1/me", method: .get).validate().responseData { response in
        switch response.result {
        case let .success(data):
          Log.debug?.message("...Loaded \(account)")
          let accountObject = try! decoder.decode(RedditAccount.self, from: data)
          self.clients[account] = (account: accountObject, credential: oauth.client.credential)

        case let .failure(error):
          Log.error?.message("Failed to retrieve account data: \(error)")
        }
      }
    }
  }

  func setCurrentAccount(name username: String) {
    Log.debug?.message("Username to save: \(username)")
    if let accountDetails = self.clients[username] {
      currentAccount = accountDetails.account
      defaults.set(username, forKey: "SelectedAccount")
      let oauth = OAuth2Swift(parameters: baseParameters)!
      oauth.accessTokenBasicAuthentification = true
      oauth.client = OAuthSwiftClient(credential: (accountDetails.credential))
      session.adapter = oauth.requestAdapter
      session.retrier = oauth.requestAdapter
    } else {
      Log.error?.message("Failed to set current account to: \(username)")
    }
  }

  /**
   Fetches the account data for a new account when the OAuth2 conversation is complete
   and persists its data to the keychain and `UserDefaults`

   - Parameter oauth: The account's newly populated OAuth2Swift object

   - Precondition: The `authorize` method must have returned successfully on `oauth` prior to invocation

   */
  func fetchNewAccount(oauth: OAuth2Swift, completion: @escaping () -> Void) {
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    oauth.client.get(
      "https://oauth.reddit.com/api/v1/me",
      success: { response in
        let account = try! decoder.decode(RedditAccount.self, from: response.data)

        self.clients[account.name] = (account: account, credential: oauth.client.credential)
        RedditClientBroker.broker.setCurrentAccount(name: account.name)
        var savedAccounts = self.defaults.stringArray(forKey: "RedditUsernames") ?? []
        savedAccounts.append(account.name)
        self.defaults.set(savedAccounts, forKey: "RedditUsernames")

        do {
          try self.keychain.set(encoder.encode(oauth.client.credential), key: account.name)
        } catch {
          Log.error?.message("Error persisting new account \(account.name) credentials - \(error)")
        }

        completion()
      },
      failure: { error in
        Log.error?.message("User profile fetch failed: \(error)")
      }
    )
  }

  func addAccount(window _: NSWindow, completion: @escaping () -> Void) {
    let oauth = OAuth2Swift(parameters: baseParameters)!
    oauth.accessTokenBasicAuthentification = true

    let state = ((0 ... 11).map { _ in Int.random(in: (0 ... 9)) }).reduce("") {
      (accumulator: String, next: Int) -> String in
      accumulator + String(next)
    }

    oauth.authorize(
      withCallbackURL: RedditClientBroker.redirectUri,
      scope: baseParameters["scope"]!,
      state: state, parameters: baseParameters,
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
    /// Remove account from in memory accounts dictionary
    clients.removeValue(forKey: username)
    
    /// Remove username from saved account names
    let accounts = defaults.stringArray(forKey: "RedditUsernames") ?? []
    let filteredAccounts = accounts.filter { username != $0 }
    defaults.set(filteredAccounts, forKey: "RedditUsernames")

    /// Remove user credentials from the keychain
    do {
      try keychain.remove(username)
    } catch {
      Log.error?.message("Error removing key for: \(username) - \(error)")
    }
  }

  func listAccounts() -> [String: accountTokenTuple] {
    return clients
  }

  func persistAccounts() {
    let encoder = JSONEncoder()
    for (_, tuple) in clients {
      do {
        try keychain.set(encoder.encode(tuple.credential), key: tuple.account.name)
      } catch {
        Log.error?.message("Error persisting \(tuple.account.name) - \(error)")
      }
    }
  }
}
