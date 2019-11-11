//
//  File.swift
//
//
//  Created by Tyler Gregory on 6/12/19.
//

import AuthenticationServices
import Combine
import Foundation
import SwiftUI

import Alamofire
import KeychainAccess
import OAuthSwift
import Willow

/// `AccountManager` is the class responsible for Reddit account management, including adding, deleting, and switching accounts
public final class AccountManager: ObservableObject {
  var configuration: ClientConfiguration = TestableConfiguration()
  public let objectWillChange = ObservableObjectPublisher()

  private let logger: Logger
  private let defaults: UserDefaults = .standard

  private let keychain = Keychain(service: Bundle.main.bundleIdentifier!)
    .synchronizable(true)
    .comment("Reddit OAuth2 credential")

  private let decoder: JSONDecoder = .init()
  private let encoder: JSONEncoder = .init()

  init(logger: Logger) {
    self.logger = logger

    decoder.dateDecodingStrategy = .secondsSince1970
    decoder.keyDecodingStrategy = .convertFromSnakeCase

    accounts = .init(loadAccounts())
    currentAccount = loadSelectedAccount()
  }

  // MARK: Published attributes

  @Published public private(set) var accounts: OrderedSet<RedditAccount> = [] {
    willSet {
      objectWillChange.send()
    }
    didSet {
      let data = try! encoder.encode(accounts.contents)
      defaults.set(data, forKey: "RedditAccounts")
    }
  }

  @Published public private(set) var currentAccount: RedditAccount? = nil {
    willSet {
      objectWillChange.send()
    }
  }

  // MARK: Account login

  /// Used to login a new user to Reddit
  /// - Parameter anchor: The `NSWindow` or `UIWindow` to use as an anchor for presenting the authentication dialog
  /// - Parameter completion: The method to call when authentication has completed
  public func addAccount(anchor: ASWebAuthenticationPresentationContextProviding,
                         completion: @escaping (_ account: RedditAccount) -> Void = { _ in }) {
    let oauth = OAuth2Swift(parameters: configuration.oauthParameters)!
    oauth.accessTokenBasicAuthentification = true
    oauth.authorizeURLHandler = IllithidWebAuthURLHandler(callbackURLScheme: configuration.redirectURI.absoluteString,
                                                          anchor: anchor)

    // Generate random state value to protect from CSRF
    let state = ((0 ... 11).map { _ in Int.random(in: 0 ... 9) }).reduce("") { accumulator, next in
      accumulator + String(next)
    }
    oauth.authorize(
      withCallbackURL: configuration.redirectURI,
      scope: configuration.scope,
      state: state, parameters: configuration.oauthParameters
    ) { result in
      switch result {
      case .success:
        self.logger.debugMessage("Authorization successful")
        self.fetchNewAccount(oauth: oauth, completion: completion)
      case let .failure(error):
        self.logger.errorMessage("Authorization failed: \(error)")
      }
    }
  }

  /**
   Fetches the account data for a new account when the OAuth2 conversation is complete
   and persists its data to the keychain and `UserDefaults`

   - Parameter oauth: The account's newly populated OAuth2Swift object

   - Precondition: The `authorize` method must have returned successfully on `oauth` prior to invocation

   */
  private func fetchNewAccount(oauth: OAuth2Swift, completion: @escaping (_ account: RedditAccount) -> Void) {
    oauth.startAuthorizedRequest("https://oauth.reddit.com/api/v1/me", method: .GET, parameters: oauth.parameters) { result in
      switch result {
      case let .success(response):
        do {
          let account = try self.decoder.decode(RedditAccount.self, from: response.data)
          self.accounts.append(account)
          try self.write(token: oauth.client.credential, for: account)
          self.currentAccount = account
          completion(account)
        } catch {
          self.logger.errorMessage("ERROR decoding new account: \(error)")
        }
      case let .failure(error):
        self.logger.errorMessage("ERROR fetching account data: \(error)")
      }
    }
  }

  public func reauthenticate(account: RedditAccount, anchor: ASWebAuthenticationPresentationContextProviding) {
    let oauth = OAuth2Swift(parameters: configuration.oauthParameters)!
    oauth.accessTokenBasicAuthentification = true
    oauth.authorizeURLHandler = IllithidWebAuthURLHandler(callbackURLScheme: configuration.redirectURI.absoluteString,
                                                          anchor: anchor)

    // Generate random state value to protect from CSRF
    let state = ((0 ... 11).map { _ in Int.random(in: 0 ... 9) }).reduce("") { accumulator, next in
      accumulator + String(next)
    }
    oauth.authorize(
      withCallbackURL: configuration.redirectURI,
      scope: configuration.scope,
      state: state, parameters: configuration.oauthParameters
    ) { result in
      switch result {
      case .success:
        self.logger.debugMessage("Authorization successful")
        do {
          try self.write(token: oauth.client.credential, for: account)
        } catch {
          self.logger.errorMessage("ERROR reauthenticating \(account.name): \(error)")
        }
      case let .failure(error):
        self.logger.errorMessage("Authorization failed: \(error)")
      }
    }
  }

  public func setAccount(_ account: RedditAccount?) {
    if let toSet = account {
      // If we are set to an account which doees not exist, do nothing
      guard toSet != currentAccount, accounts.contains(toSet) else { return }
      currentAccount = account

      let data = try! encoder.encode(currentAccount)
      defaults.set(data, forKey: "SelectedAccount")

      Illithid.shared.session.session.invalidateAndCancel()
      Illithid.shared.session = makeSession(for: currentAccount)
    } else {
      defaults.removeObject(forKey: "SelectedAccount")
      Illithid.shared.session.session.invalidateAndCancel()
      Illithid.shared.session = makeSession()
    }
  }

  internal func makeSession(for account: RedditAccount? = nil) -> SessionManager {
    let alamoConfiguration = URLSessionConfiguration.default
    let osVersion = ProcessInfo().operatingSystemVersion
    let userAgentComponents = [
      "macOS \(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)",
      "\(configuration.consumerKey)",
      "\(configuration.version) (by \(configuration.author))",
    ]
    let headers = SessionManager.defaultHTTPHeaders.merging([
      "User-Agent": userAgentComponents.joined(separator: ":"),
      "Accept": "application/json",
    ]) { _, new in new }
    alamoConfiguration.httpAdditionalHeaders = headers
    let session = SessionManager(configuration: alamoConfiguration)

    guard let redditAccount = account else { return session }
    // FIXME: This should return an error to the caller instead of silently returning the anonymous session
    guard let credential = token(for: redditAccount) else { return session }
    let oauth = OAuth2Swift(parameters: configuration.oauthParameters)!
    oauth.accessTokenBasicAuthentification = true
    oauth.client = OAuthSwiftClient(credential: credential)

    session.adapter = oauth.requestAdapter
    session.retrier = oauth.requestAdapter
    return session
  }

  // MARK: Saved Account Loading

  private func loadSelectedAccount() -> RedditAccount? {
    if let selectedAccountData = defaults.data(forKey: "SelectedAccount") {
      guard let account = try? decoder.decode(RedditAccount.self, from: selectedAccountData) else { return nil }
      return account
    } else {
      return nil
    }
  }

  private func loadAccounts() -> [RedditAccount] {
    guard let accountData = defaults.data(forKey: "RedditAccounts") else { return [] }
    guard let accounts = try? decoder.decode([RedditAccount].self, from: accountData) else { return [] }
    return accounts
  }

  // MARK: Account removal

  public func removeAccounts(indexSet: IndexSet) {
    for index in indexSet {
      removeAccount(toRemove: accounts[index])
    }
  }

  public func removeAll() {
    do {
      try keychain.removeAll()
    } catch {
      logger.errorMessage("ERROR Removing all keys: \(error)")
    }
    accounts.removeAll()
    setAccount(nil)
  }

  public func removeAccount(toRemove account: RedditAccount) {
    // Remove account from in memory logged in accounts and from the savedAccounts entry in UserDefaults
    accounts.remove(account)
    if account == currentAccount { setAccount(nil) }

    // Remove credentials from the keychain
    removeToken(for: account)
  }

  // MARK: OAuth token management

  public func isAuthenticated(_ account: RedditAccount) -> Bool {
    token(for: account) != nil
  }

  private func token(for accountName: String) -> OAuthSwiftCredential? {
    do {
      guard let credentialData = try keychain.getData(accountName) else {
        logger.warnMessage("WARN No data in keychain for key \(accountName)")
        return nil
      }
      return try decoder.decode(OAuthSwiftCredential.self, from: credentialData)
    } catch {
      logger.errorMessage("ERROR fetching credential for \(accountName): \(error)")
      return nil
    }
  }

  private func token(for account: RedditAccount) -> OAuthSwiftCredential? {
    token(for: account.name)
  }

  private func write(token: OAuthSwiftCredential, for account: RedditAccount) throws {
    do {
      let encodedCredential = try encoder.encode(token)
      objectWillChange.send()
      try keychain
        .label("www.reddit.com (\(account.name))")
        .set(encodedCredential, key: account.name)
    } catch {
      logger.errorMessage("ERROR writing \(account.name): \(error)")
    }
  }

  private func removeToken(for account: RedditAccount) {
    do {
      objectWillChange.send()
      try keychain.remove(account.name)
    } catch {
      logger.errorMessage("ERROR Removing token for \(account.name): \(error)")
    }
  }
}
