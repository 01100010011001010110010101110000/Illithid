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

  private var credentials: [String: OAuthSwiftCredential] = [:]
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
            self.credentials[account.name] = oauth.client.credential
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

  public func persistAccounts() {
    accounts.forEach { account in
      do {
        try keychain
          .label("www.reddit.com (\(account.name))")
          .set(encoder.encode(credentials[account.name]!), key: account.name)
      } catch {
        logger.errorMessage("ERROR persisting \(account.name) - \(error)")
      }
    }
  }

  public func loadSavedAccounts(completion: @escaping () -> Void = {}) {
    let lastSelectedAccount = defaults.string(forKey: "SelectedAccount")

    let accountPublishers = savedAccounts.compactMap { accountName -> AnyPublisher<RedditAccount, Error>? in
      do {
        guard let credentialData = try keychain.getData(accountName) else {
          logger.warnMessage("WARN No data in keychain for key \(accountName)")
          return nil
        }
        let credential = try decoder.decode(OAuthSwiftCredential.self, from: credentialData)
        credentials[accountName] = credential

        let oauth = OAuth2Swift(parameters: configuration.oauthParameters)!
        oauth.accessTokenBasicAuthentification = true
        oauth.client = OAuthSwiftClient(credential: credential)

        return oauth.requestPublisher(URL(string: "https://oauth.reddit.com/api/v1/me")!, method: .GET, parameters: oauth.parameters)
          .map { response in
            response.data
          }
          .decode(type: RedditAccount.self, decoder: decoder)
          .eraseToAnyPublisher()
      } catch let error as DecodingError {
        logger.errorMessage("ERROR decoding OAuth2 credential: \(error)")
        return nil
      } catch {
        logger.errorMessage("ERROR fetching OAuth2 credential from Keychain: \(error)")
        return nil
      }
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
    credentials.removeAll()
    accounts.removeAll()
  }

  public func removeAccount(toRemove account: RedditAccount) {
    /// Remove account from in memory accounts dictionary
    accounts.remove(account)
    credentials.removeValue(forKey: account.name)

    /// Remove username from saved account names
    savedAccounts.removeAll { $0 == account.name }

    /// Remove user credentials from the keychain
    do {
      try keychain.remove(account.name)
    } catch {
      logger.errorMessage("Error removing key for: \(account.name) - \(error)")
    }
  }

  public func setCurrentAccount(account: RedditAccount) {
    currentAccount = account
    defaults.set(account.name, forKey: "SelectedAccount")
    let oauth = OAuth2Swift(parameters: configuration.oauthParameters)!
    oauth.accessTokenBasicAuthentification = true
    oauth.client = OAuthSwiftClient(credential: credentials[account.name]!)
    session.adapter = oauth.requestAdapter
    session.retrier = oauth.requestAdapter
  }
}
