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
  }

  @Published public private(set) var accounts: OrderedSet<RedditAccount> = []
  @Published public private(set) var currentAccount: RedditAccount? = nil

  public private(set) var savedAccounts: [String] {
    get {
      defaults.stringArray(forKey: "RedditUsernames") ?? []
    }
    set(newAccounts) {
      defaults.set(newAccounts, forKey: "RedditUsernames")
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
        self.logger.debugMessage("Returned parameters: \(parameters)")
        self.logger.debugMessage("OAuth object parameters: \(oauth.parameters)")
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
  private func fetchNewAccount(oauth: OAuth2Swift, completion: @escaping () -> Void) {
    oauth.startAuthorizedRequest("https://oauth.reddit.com/api/v1/me", method: .GET, parameters: oauth.parameters) { result in
      switch result {
      case .success(let response):
        do {
          let account = try self.decoder.decode(RedditAccount.self, from: response.data)
          if self.accounts.append(account) {
            try? self.write(token: oauth.client.credential, for: account)
            self.savedAccounts.append(account.name)
            self.setCurrentAccount(account: account)
          }
        } catch let error {
          self.logger.errorMessage("ERROR decoding new account: \(error)")
        }
      case .failure(let error):
        self.logger.errorMessage("ERROR fetching account data: \(error)")
      }
    }
  }

  public func loadSavedAccounts(completion: @escaping () -> Void = {}) {
    let lastSelectedAccount = defaults.string(forKey: "SelectedAccount")

    let accountPublishers = savedAccounts.compactMap { accountName -> AnyPublisher<RedditAccount, Error>? in
      guard let credential = token(for: accountName) else { return nil }

      let oauth = OAuth2Swift(parameters: configuration.oauthParameters)!
      oauth.accessTokenBasicAuthentification = true
      oauth.client = OAuthSwiftClient(credential: credential)

      return oauth.requestPublisher(URL(string: "https://oauth.reddit.com/api/v1/me")!, method: .GET, parameters: oauth.parameters)
        .map { response in
          response.data
        }
        .decode(type: RedditAccount.self, decoder: decoder)
        .eraseToAnyPublisher()
    }

    cancellable = Publishers.MergeMany(accountPublishers)
      .map { account in
        self.logger.debugMessage("Appending \(account.name)")
        self.accounts.append(account)
        if lastSelectedAccount == account.name {
          self.setCurrentAccount(account: account)
        }
      }
      .collect()
      .sink(receiveCompletion: { error in
        self.logger.errorMessage("Error while loading accounts: \(error)")
      }) { _ in
        if self.currentAccount == nil, !self.accounts.isEmpty {
          self.setCurrentAccount(account: self.accounts.first!)
        }
        completion()
      }
  }

  public func setCurrentAccount(account: RedditAccount) {
    guard accounts.contains(account) else { return }
    currentAccount = account
    defaults.set(account.name, forKey: "SelectedAccount")

    let oauth = OAuth2Swift(parameters: configuration.oauthParameters)!
    oauth.accessTokenBasicAuthentification = true
    oauth.client = OAuthSwiftClient(credential: token(for: account)!)

    session.adapter = oauth.requestAdapter
    session.retrier = oauth.requestAdapter
  }

  // MARK: Account removal

  public func removeAccounts(indexSet: IndexSet) {
    for index in indexSet {
      removeAccount(toRemove: accounts[index])
    }
  }

  public func removeAll() {
    savedAccounts.forEach { username in
      try? keychain.remove(username)
    }
    savedAccounts.removeAll()
    accounts.removeAll()
  }

  public func removeAccount(toRemove account: RedditAccount) {
    // Remove account from in memory logged in accounts and from the savedAccounts entry in UserDefaults
    accounts.remove(account)
    savedAccounts.removeAll { $0 == account.name }

    // Remove credentials from the keychain
    do {
      try keychain.remove(account.name)
    } catch {
      logger.errorMessage("Error removing key for: \(account.name): \(error)")
    }
  }

  // MARK: OAuth token management

  private func token(for accountName: String) -> OAuthSwiftCredential? {
    do {
      guard let credentialData = try keychain.getData(accountName) else {
        logger.warnMessage("WARN No data in keychain for key \(accountName)")
        return nil
      }
      return try decoder.decode(OAuthSwiftCredential.self, from: credentialData)
    } catch let error {
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
    } catch let error {
      logger.errorMessage("ERROR writing \(account.name): \(error)")
    }
  }
}
