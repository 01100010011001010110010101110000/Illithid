//
//  File.swift
//
//
//  Created by Tyler Gregory on 6/12/19.
//

import Combine
import Foundation
import SwiftUI

import Alamofire
import KeychainAccess
import OAuthSwift
import Willow

public final class AccountManager: BindableObject {
  public let didChange = PassthroughSubject<AccountManager, Never>()

  let logger: Logger
  var configuration: ClientConfiguration
  let session: SessionManager

  private let keychain = Keychain(server: RedditClientBroker.redditBaseUrl,
                                  protocolType: .https).synchronizable(true)

  init(logger: Logger, configuration: ClientConfiguration, session: SessionManager) {
    self.logger = logger
    self.configuration = configuration
    self.session = session
  }

  var credentials: [String: OAuthSwiftCredential] = [:]
  public var accounts: [RedditAccount] = [] {
    didSet {
      didChange.send(self)
    }
  }

  public var currentAccount: RedditAccount? {
    didSet {
      didChange.send(self)
    }
  }

  public func addAccount(completion: @escaping () -> Void) {
    let oauth = OAuth2Swift(parameters: configuration.oauthParameters)!
    oauth.accessTokenBasicAuthentification = true

    let state = ((0 ... 11).map { _ in Int.random(in: 0 ... 9) }).reduce("") { accumulator, next in
      accumulator + String(next)
    }
    oauth.authorize(
      withCallbackURL: configuration.redirectURI,
      scope: configuration.scope,
      state: state, parameters: configuration.oauthParameters,
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

  /**
   Fetches the account data for a new account when the OAuth2 conversation is complete
   and persists its data to the keychain and `UserDefaults`

   - Parameter oauth: The account's newly populated OAuth2Swift object

   - Precondition: The `authorize` method must have returned successfully on `oauth` prior to invocation

   */
  private func fetchNewAccount(oauth: OAuth2Swift, completion: @escaping () -> Void) {
    let decoder = JSONDecoder()
    session.adapter = oauth.requestAdapter
    session.retrier = oauth.requestAdapter
    session.request("https://oauth.reddit.com/api/v1/me", method: .get).validate().responseData { response in
      switch response.result {
      case let .success(data):
        let account = try! decoder.decode(RedditAccount.self, from: data)

        self.accounts.append(account)
        self.credentials[account.name] = oauth.client.credential
        self.setCurrentAccount(account: account)
        var savedAccounts = self.configuration.defaults.stringArray(forKey: "RedditUsernames") ?? []
        savedAccounts.append(account.name)
        self.configuration.defaults.set(savedAccounts, forKey: "RedditUsernames")
        self.persistAccounts()

        completion()
      case let .failure(error):
        self.logger.errorMessage("User profile fetch failed: \(error)")
      }
    }
  }

  func persistAccounts() {
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
    let decoder = JSONDecoder()
    let savedAccounts = configuration.defaults.stringArray(forKey: "RedditUsernames") ?? []
    let lastSelectedAccount = configuration.defaults.string(forKey: "SelectedAccount")

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

      return oauth.client.requestPublisher(URL(string: "https://oauth.reddit.com/api/v1/me")!)
        .map { $0.data }
        .decode(type: RedditAccount.self, decoder: decoder)
        .eraseToAnyPublisher()
    }

    Publishers.MergeMany(accountPublishers)
      .map { account in
        self.accounts.append(account)
        if lastSelectedAccount != nil, lastSelectedAccount == account.name {
          self.setCurrentAccount(account: account)
        }
      }
      .collect()
      .sink { _ in
        if self.currentAccount == nil, !self.accounts.isEmpty {
          self.setCurrentAccount(account: self.accounts.first!)
        }
        completion()
      }

//    for (idx, account) in savedAccounts.enumerated() {
//      let credential: OAuthSwiftCredential = try! decoder.decode(
//        OAuthSwiftCredential.self,
//        from: keychain.getData(account)!
//      )
//      logger.debugMessage("Found refresh token: \(credential.oauthRefreshToken) for \(account)")
//      let oauth = OAuth2Swift(parameters: configuration.oauthParameters)!
//      oauth.accessTokenBasicAuthentification = true
//      oauth.client = OAuthSwiftClient(credential: credential)
//      session.adapter = oauth.requestAdapter
//      session.retrier = oauth.requestAdapter
//
//      logger.debugMessage("...Loading \(account)")
//
//      session.request("https://oauth.reddit.com/api/v1/me", method: .get).validate().responseData { response in
//        switch response.result {
//        case let .success(data):
//          self.logger.debugMessage("...Loaded \(account)")
//          let accountObject = try! decoder.decode(RedditAccount.self, from: data)
//          self.accounts.append(accountObject)
//          self.credentials[accountObject.name] = oauth.client.credential
//
//          if let lastSelectedAccount = self.configuration.defaults.string(forKey: "SelectedAccount"),
//            accountObject.name == lastSelectedAccount {
//            self.logger.debugMessage("Setting \(lastSelectedAccount) as current account")
//            self.setCurrentAccount(account: accountObject)
//          }
//        case let .failure(error):
//          self.logger.errorMessage("Failed to retrieve account data: \(error)")
//        }
//      }
//    }
  }

  public func removeAccount(indexSet: IndexSet) {
    for index in indexSet {
      removeAccount(toRemove: accounts[index])
    }
  }

  public func removeAccount(toRemove account: RedditAccount) {
    /// Remove account from in memory accounts dictionary
    accounts.removeAll { $0.name == account.name }
    credentials.removeValue(forKey: account.name)

    /// Remove username from saved account names
    let accounts = configuration.defaults.stringArray(forKey: "RedditUsernames") ?? []
    let filteredAccounts = accounts.filter { account.name != $0 }
    configuration.defaults.set(filteredAccounts, forKey: "RedditUsernames")

    /// Remove user credentials from the keychain
    do {
      try keychain.remove(account.name)
    } catch {
      logger.errorMessage("Error removing key for: \(account.name) - \(error)")
    }
  }

  public func setCurrentAccount(account: RedditAccount) {
    currentAccount = account
    configuration.defaults.set(account.name, forKey: "SelectedAccount")
    let oauth = OAuth2Swift(parameters: configuration.oauthParameters)!
    oauth.accessTokenBasicAuthentification = true
    oauth.client = OAuthSwiftClient(credential: credentials[account.name]!)
    session.adapter = oauth.requestAdapter
    session.retrier = oauth.requestAdapter
  }
}