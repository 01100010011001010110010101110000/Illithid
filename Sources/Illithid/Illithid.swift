//
// Created by Tyler Gregory on 11/19/18.
// Copyright (c) 2018 flayware. All rights reserved.
//

import Cocoa
import Foundation

import Alamofire
import AlamofireImage
import KeychainAccess
import OAuthSwift
import Willow

/// Handles Reddit API meta-operations
public final class RedditClientBroker {
  typealias AccountTokenTuple = (account: RedditAccount, credential: OAuthSwiftCredential)

  /// Reddit API's base URL
  static let redditBaseUrl: URL = URL(string: "https://www.reddit.com/api/v1")!
  /// Reddit's OAuth2 protected API endpoint
  static let redditOAuthBaseUrl: URL = URL(string: "https://oauth.reddit.com/api/v1")!
  /// Application OAuth2 callback URL
  static let redirectUri: URL = URL(string: "illithid://oauth2/callback")!

  /// The version of Illithid
  static let VERSION = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.1"
  /// The author's Reddit username
  static let REDDIT_AUTHOR = "Tyler1-66" // swiftlint:disable:this identifier_name

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
  public let imageDownloader: ImageDownloader
  let logger: Logger

  private var clients = [String: AccountTokenTuple]()
  private var currentAccount: RedditAccount?

  public init(
    sharedLogger: Logger = Logger(
      logLevels: [.all],
      writers: [ConsoleWriter()],
      executionMethod: .asynchronous(
        queue: DispatchQueue(label: "log.queue", qos: .utility)
      )
    ),
    sharedImageDownloader: ImageDownloader = ImageDownloader(maximumActiveDownloads: 20)
  ) {
    logger = sharedLogger
    imageDownloader = sharedImageDownloader

    logger.debugMessage("Loading Reddit accounts...")

    let alamoConfiguration = URLSessionConfiguration.default

    let osVersion = ProcessInfo().operatingSystemVersion
    let userAgentComponents = [
      "macOS \(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)",
      "\(baseParameters["consumerKey"]!)",
      "\(RedditClientBroker.VERSION) (by \(RedditClientBroker.REDDIT_AUTHOR))"
    ]
    let headers = [
      "User-Agent": userAgentComponents.joined(separator: ":"),
      "Accept": "application/json",
      "Content-Type": "application/json"
    ]
    alamoConfiguration.httpAdditionalHeaders = headers
    session = SessionManager(configuration: alamoConfiguration)

    loadSavedAccounts {
      if let lastSelectedAccount = self.defaults.string(forKey: "SelectedAccount") {
        self.logger.debugMessage("Setting \(lastSelectedAccount) as current account")
        self.setCurrentAccount(name: lastSelectedAccount)
      }
    }
  }

  private func loadSavedAccounts(completion _: @escaping () -> Void) {
    let decoder = JSONDecoder()
    let savedAccounts = defaults.stringArray(forKey: "RedditUsernames") ?? []

    /// ToDo: Ensure there is no race condition in this loop
    for account in savedAccounts {
      let credential: OAuthSwiftCredential = try! decoder.decode(
        OAuthSwiftCredential.self,
        from: keychain.getData(account)!
      )
      logger.debugMessage("Found refresh token: \(credential.oauthRefreshToken) for \(account)")
      let oauth = OAuth2Swift(parameters: baseParameters)!
      oauth.accessTokenBasicAuthentification = true
      oauth.client = OAuthSwiftClient(credential: credential)
      session.adapter = oauth.requestAdapter
      session.retrier = oauth.requestAdapter

      logger.debugMessage("...Loading \(account)")
      session.request("https://oauth.reddit.com/api/v1/me", method: .get).validate().responseData { response in
        switch response.result {
        case let .success(data):
          self.logger.debugMessage("...Loaded \(account)")
          let accountObject = try! decoder.decode(RedditAccount.self, from: data)
          self.clients[account] = (account: accountObject, credential: oauth.client.credential)

        case let .failure(error):
          self.logger.errorMessage("Failed to retrieve account data: \(error)")
        }
      }
    }
  }

  public func setCurrentAccount(name username: String) {
    logger.debugMessage("Username to save: \(username)")
    if let accountDetails = self.clients[username] {
      currentAccount = accountDetails.account
      defaults.set(username, forKey: "SelectedAccount")
      let oauth = OAuth2Swift(parameters: baseParameters)!
      oauth.accessTokenBasicAuthentification = true
      oauth.client = OAuthSwiftClient(credential: accountDetails.credential)
      session.adapter = oauth.requestAdapter
      session.retrier = oauth.requestAdapter
    } else {
      logger.errorMessage("Failed to set current account to: \(username)")
    }
  }

  /**
   Fetches the account data for a new account when the OAuth2 conversation is complete
   and persists its data to the keychain and `UserDefaults`

   - Parameter oauth: The account's newly populated OAuth2Swift object

   - Precondition: The `authorize` method must have returned successfully on `oauth` prior to invocation

   */
  private func fetchNewAccount(oauth: OAuth2Swift, completion: @escaping () -> Void) {
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    oauth.client.get(
      "https://oauth.reddit.com/api/v1/me",
      success: { response in
        let account = try! decoder.decode(RedditAccount.self, from: response.data)

        self.clients[account.name] = (account: account, credential: oauth.client.credential)
        self.setCurrentAccount(name: account.name)
        var savedAccounts = self.defaults.stringArray(forKey: "RedditUsernames") ?? []
        savedAccounts.append(account.name)
        self.defaults.set(savedAccounts, forKey: "RedditUsernames")
        self.persistAccounts()

        do {
          try self.keychain.set(encoder.encode(oauth.client.credential), key: account.name)
        } catch {
          self.logger.errorMessage("Error persisting new account \(account.name) credentials - \(error)")
        }

        completion()
      },
      failure: { error in
        self.logger.errorMessage("User profile fetch failed: \(error)")
      }
    )
  }

  public func addAccount(window _: NSWindow, completion: @escaping () -> Void) {
    let oauth = OAuth2Swift(parameters: baseParameters)!
    oauth.accessTokenBasicAuthentification = true

    let state = ((0 ... 11).map { _ in Int.random(in: 0 ... 9) }).reduce("") { accumulator, next in
      accumulator + String(next)
    }

    oauth.authorize(
      withCallbackURL: RedditClientBroker.redirectUri,
      scope: baseParameters["scope"]!,
      state: state, parameters: baseParameters,
      success: { _, _, parameters in
        self.logger.debugMessage("Authorization successful")
        self.logger.debugMessage("Returned parameters: \(parameters)")
        self.logger.debugMessage("OAuth object parameters: \(oauth.parameters)")
        self.fetchNewAccount(oauth: oauth, completion: completion)
      },
      failure: { error in
        self.logger.errorMessage("Authorization failed: \(error)")
      }
    )
  }

  public func removeAccount(toRemove username: String) {
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
      logger.errorMessage("Error removing key for: \(username) - \(error)")
    }
  }

  private func listAccounts() -> [String: AccountTokenTuple] {
    return clients
  }

  private func persistAccounts() {
    let encoder = JSONEncoder()
    for (_, tuple) in clients {
      do {
        try keychain.set(encoder.encode(tuple.credential), key: tuple.account.name)
      } catch {
        logger.errorMessage("Error persisting \(tuple.account.name) - \(error)")
      }
    }
  }
}
