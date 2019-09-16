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
  private var cancellable: AnyCancellable!

  private let logger: Logger
  private var configuration: ClientConfiguration
  private let defaults: UserDefaults = .standard

  private let session: SessionManager

  private let keychain = Keychain(service: Bundle.main.bundleIdentifier!)
    .synchronizable(true)
    .comment("Reddit OAuth2 credential")

  private let decoder: JSONDecoder = .init()
  private let encoder: JSONEncoder = .init()

  init(logger: Logger, configuration: ClientConfiguration, session: SessionManager) {
    self.logger = logger
    self.configuration = configuration
    self.session = session

    decoder.dateDecodingStrategy = .secondsSince1970
    decoder.keyDecodingStrategy = .convertFromSnakeCase

    accounts = .init(loadAccounts())
    currentAccount = loadSelectedAccount()
  }

  // MARK: Published attributes

  @Published public private(set) var accounts: OrderedSet<RedditAccount> = [] {
    didSet {
      guard let data = try? encoder.encode(self.accounts.contents) else { return }
      defaults.set(data, forKey: "RedditAccounts")
    }
  }

  /*
   This is easier to use, but it may be a good idea to make `setCurrentAccount` public and make this setter private.
   If there are any errors here, they will be silently swallowed.
   */
  @Published public var currentAccount: RedditAccount? = nil {
    didSet {
      // If we are set to an account which doees not exist, keep the old value
      guard currentAccount != nil, oldValue != currentAccount else { return }
      guard accounts.contains(currentAccount!) else {
        currentAccount = oldValue
        return
      }
      // FIXME: Handle the case when `currentAccount` is set to nil, e.g. when deleting all accounts
      setCurrentAccount(account: currentAccount!)
    }
  }

  // MARK: Account login

  /// Used to login a new user to Reddit
  /// - Parameter anchor: The `NSWindow` or `UIWindow` to use as an anchor for presenting the authentication dialog
  /// - Parameter completion: The method to call when authentication has completed
  public func loginUser(anchor: ASWebAuthenticationPresentationContextProviding, completion: @escaping () -> Void) {
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
      case .success(let (_, _, parameters)):
        self.logger.debugMessage("Authorization successful")
        self.fetchNewAccount(oauth: oauth, completion: completion)
      case .failure(let error):
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
  private func fetchNewAccount(oauth: OAuth2Swift, completion: @escaping () -> Void) {
    oauth.startAuthorizedRequest("https://oauth.reddit.com/api/v1/me", method: .GET, parameters: oauth.parameters) { result in
      switch result {
      case .success(let response):
        do {
          let account = try self.decoder.decode(RedditAccount.self, from: response.data)
          if self.accounts.append(account) {
            try? self.write(token: oauth.client.credential, for: account)
            self.setCurrentAccount(account: account)
          }
        } catch {
          self.logger.errorMessage("ERROR decoding new account: \(error)")
        }
      case .failure(let error):
        self.logger.errorMessage("ERROR fetching account data: \(error)")
      }
    }
  }

  private func setCurrentAccount(account: RedditAccount) {
    defaults.set(account.name, forKey: "SelectedAccount")

    let oauth = OAuth2Swift(parameters: configuration.oauthParameters)!
    oauth.accessTokenBasicAuthentification = true
    oauth.client = OAuthSwiftClient(credential: token(for: account)!)

    session.adapter = oauth.requestAdapter
    session.retrier = oauth.requestAdapter
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
  }

  public func removeAccount(toRemove account: RedditAccount) {
    // Remove account from in memory logged in accounts and from the savedAccounts entry in UserDefaults
    accounts.remove(account)

    // Remove credentials from the keychain
    removeToken(for: account)
  }

  // MARK: OAuth token management

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
    return token(for: account.name)
  }

  private func write(token: OAuthSwiftCredential, for account: RedditAccount) throws {
    do {
      let encodedCredential = try encoder.encode(token)
      try keychain
        .label("www.reddit.com (\(account.name))")
        .set(encodedCredential, key: account.name)
    } catch {
      logger.errorMessage("ERROR writing \(account.name): \(error)")
    }
  }

  private func removeToken(for account: RedditAccount) {
    do {
      try keychain.remove(account.name)
    } catch {
      logger.errorMessage("ERROR Removing token for \(account.name): \(error)")
    }
  }
}
