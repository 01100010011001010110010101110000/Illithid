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

  private let keychain = Keychain(server: "www.reddit.com",
                                  protocolType: .https).synchronizable(true)

  private let decoder: JSONDecoder = .init()

  init(logger: Logger, configuration: ClientConfiguration, session: SessionManager) {
    self.logger = logger
    self.configuration = configuration
    self.session = session

    decoder.dateDecodingStrategy = .secondsSince1970
    decoder.keyDecodingStrategy = .convertFromSnakeCase
  }

  var credentials: [String: OAuthSwiftCredential] = [:]
  @Published public private(set) var accounts: OrderedSet<RedditAccount> = []

  @Published public private(set) var currentAccount: RedditAccount? = nil

  public func addAccount(anchor: ASWebAuthenticationPresentationContextProviding, completion: @escaping () -> Void) {
    let oauth = OAuth2Swift(parameters: configuration.oauthParameters)!
    oauth.accessTokenBasicAuthentification = true
    oauth.authorizeURLHandler = IllithidWebAuthURLHandler(callbackURLScheme: "illithid://oauth2/callback", anchor: anchor)

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
        self.logger.errorMessage { "Authorization failed: \(error)" }
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
    session.adapter = oauth.requestAdapter
    session.retrier = oauth.requestAdapter
    session.request("https://oauth.reddit.com/api/v1/me", method: .get).validate().responseData { response in
      switch response.result {
      case let .success(data):
        let account = try! self.decoder.decode(RedditAccount.self, from: data)

        // Only add the credentials and persist the username of new accounts
        let didInsert = self.accounts.append(account)
        if didInsert {
          self.credentials[account.name] = oauth.client.credential
          self.setCurrentAccount(account: account)
          var savedAccounts = self.defaults.stringArray(forKey: "RedditUsernames") ?? []
          savedAccounts.append(account.name)
          self.defaults.set(savedAccounts, forKey: "RedditUsernames")
          self.persistAccounts()
        }

        completion()
      case let .failure(error):
        self.logger.errorMessage("User profile fetch failed: \(error)")
      }
    }
  }

  public func persistAccounts() {
    let encoder = JSONEncoder()
    accounts.forEach { account in
      do {
        try keychain.set(encoder.encode(credentials[account.name]!), key: account.name)
      } catch {
        logger.errorMessage("Error persisting \(account.name) - \(error)")
      }
    }
  }

  public func loadSavedAccounts(completion: @escaping () -> Void = {}) {
    let savedAccounts = defaults.stringArray(forKey: "RedditUsernames") ?? []
    let lastSelectedAccount = defaults.string(forKey: "SelectedAccount")

    let accountPublishers = savedAccounts.map { account -> AnyPublisher<RedditAccount, Error> in
      let credential: OAuthSwiftCredential = try! decoder.decode(
        OAuthSwiftCredential.self,
        from: keychain.getData(account)!
      )
      credentials[account] = credential
      logger.debugMessage("Found refresh token: \(credential.oauthRefreshToken) for \(account)")
      let oauth = OAuth2Swift(parameters: configuration.oauthParameters)!
      oauth.accessTokenBasicAuthentification = true
      oauth.client = OAuthSwiftClient(credential: credential)

      // Allow initial reddit requests to succeed if a prior account exists
      if lastSelectedAccount != nil, lastSelectedAccount == account {
        session.adapter = oauth.requestAdapter
        session.retrier = oauth.requestAdapter
      }

      return oauth.requestPublisher(URL(string: "https://oauth.reddit.com/api/v1/me")!, method: .GET, parameters: oauth.parameters)
        .map { response in
          response.data
        }
        .decode(type: RedditAccount.self, decoder: decoder)
        .eraseToAnyPublisher()
    }

    cancellable = Publishers.MergeMany(accountPublishers)
      .map { account in
        self.logger.debugMessage { "Appending \(account.name)" }
        self.accounts.append(account)
        if lastSelectedAccount != nil, lastSelectedAccount == account.name {
          self.setCurrentAccount(account: account)
        }
      }
      .collect()
      .sink(receiveCompletion: { error in
        self.logger.errorMessage { "Error while loading accounts: \(error)" }
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
    let usernames = defaults.stringArray(forKey: "RedditUsernames") ?? []
    usernames.forEach { username in
      credentials.removeValue(forKey: username)
    }
    defaults.set([], forKey: "RedditUsernames")
    accounts.removeAll()
  }

  public func removeAccount(toRemove account: RedditAccount) {
    /// Remove account from in memory accounts dictionary
    accounts.remove(account)
    credentials.removeValue(forKey: account.name)

    /// Remove username from saved account names
    let accounts = defaults.stringArray(forKey: "RedditUsernames") ?? []
    let filteredAccounts = accounts.filter { account.name != $0 }
    defaults.set(filteredAccounts, forKey: "RedditUsernames")

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
