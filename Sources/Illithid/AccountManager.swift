// Copyright (C) 2020 Tyler Gregory (@01100010011001010110010101110000)
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of  MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <http://www.gnu.org/licenses/>.

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
  // MARK: Lifecycle

  init(logger: Logger) {
    self.logger = logger

    decoder.dateDecodingStrategy = .secondsSince1970

    accounts = .init(loadAccounts())
    currentAccount = loadSelectedAccount()
  }

  // MARK: Public

  public let objectWillChange = ObservableObjectPublisher()

  // MARK: Published attributes

  @Published public private(set) var accounts: OrderedSet<Account> = [] {
    willSet {
      objectWillChange.send()
    }
    didSet {
      let data = try! encoder.encode(accounts.contents)
      defaults.set(data, forKey: "RedditAccounts")
    }
  }

  @Published public private(set) var currentAccount: Account? = nil {
    willSet {
      objectWillChange.send()
    }
  }

  // MARK: Account login

  /// Used to login a new user to Reddit
  /// - Parameter anchor: The `NSWindow` or `UIWindow` to use as an anchor for presenting the authentication dialog
  /// - Parameter completion: The method to call when authentication has completed
  public func addAccount(anchor: ASWebAuthenticationPresentationContextProviding,
                         completion: @escaping (_ account: Account) -> Void = { _ in }) {
    let oauth = OAuth2Swift(parameters: configuration.oauthParameters)!
    oauth.accessTokenBasicAuthentification = true
    oauth.authorizeURLHandler = IllithidWebAuthURLHandler(callbackURLScheme: configuration.redirectURI.scheme!,
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
        self.fetchNewAccount(oauth: oauth) { account in
          self.setAccount(account)
          completion(account)
        }
      case let .failure(error):
        self.logger.errorMessage("Authorization failed: \(error)")
      }
    }
  }

  public func reauthenticate(account: Account, anchor: ASWebAuthenticationPresentationContextProviding) {
    let oauth = OAuth2Swift(parameters: configuration.oauthParameters)!
    oauth.accessTokenBasicAuthentification = true
    oauth.authorizeURLHandler = IllithidWebAuthURLHandler(callbackURLScheme: configuration.redirectURI.scheme!,
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

  public func setAccount(_ account: Account?) {
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

  public func removeAccount(toRemove account: Account) {
    // Remove account from in memory logged in accounts and from the savedAccounts entry in UserDefaults
    accounts.remove(account)
    if account == currentAccount { setAccount(nil) }

    // Remove credentials from the keychain
    removeToken(for: account)
  }

  // MARK: OAuth token management

  public func isAuthenticated(_ account: Account) -> Bool {
    token(for: account) != nil
  }

  // MARK: Internal

  var configuration: ClientConfiguration = TestableConfiguration()

  internal func makeSession(for account: Account? = nil) -> Session {
    let alamoConfiguration = URLSessionConfiguration.default

    // TODO: Make this some function of the system's available disk and memory
    alamoConfiguration.urlCache = URLCache(memoryCapacity: 10_485_760, diskCapacity: 209_715_200)

    // Construct Reddit's required UA string
    let osVersion = ProcessInfo().operatingSystemVersion
    let userAgentComponents = [
      "macOS \(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)",
      "\(configuration.consumerKey)",
      "\(configuration.version) (by \(configuration.author))",
    ]
    let headers: HTTPHeaders = [
      .userAgent(userAgentComponents.joined(separator: ":")),
      .accept("application.json"),
    ]
    alamoConfiguration.httpAdditionalHeaders = headers.dictionary

    // FIXME: This should return an error to the caller instead of silently returning the anonymous session
    guard let redditAccount = account, let credential = token(for: redditAccount) else { return Session(configuration: alamoConfiguration) }
    let oauth = OAuth2Swift(parameters: configuration.oauthParameters)!
    oauth.accessTokenBasicAuthentification = true
    oauth.client = OAuthSwiftClient(credential: credential)

    let cacher: ResponseCacher = .cache
    let session = Session(configuration: alamoConfiguration,
                          rootQueue: DispatchQueue(label: "com.flayware.illithid.AFRootQueue"),
                          serializationQueue: DispatchQueue(label: "com.flayware.illithid.AFSerializationQueue"),
                          interceptor: IllithidRedditRequestInterceptor(oauth),
                          cachedResponseHandler: cacher,
                          eventMonitors: [FireLogger(logger: logger)])

    return session
  }

  // MARK: Private

  private let logger: Logger
  private let defaults: UserDefaults = .standard

  private let keychain = Keychain(service: Bundle.main.bundleIdentifier!)
    .synchronizable(true)
    .comment("Reddit OAuth2 credential")

  private let decoder: JSONDecoder = .init()
  private let encoder: JSONEncoder = .init()

  /**
   Fetches the account data for a new account when the OAuth2 conversation is complete
   and persists its data to the keychain and `UserDefaults`

   - Parameter oauth: The account's newly populated OAuth2Swift object

   - Precondition: The `authorize` method must have returned successfully on `oauth` prior to invocation

   */
  private func fetchNewAccount(oauth: OAuth2Swift, completion: @escaping (_ account: Account) -> Void) {
    oauth.startAuthorizedRequest("https://oauth.reddit.com/api/v1/me", method: .GET, parameters: oauth.parameters) { result in
      switch result {
      case let .success(response):
        do {
          let account = try self.decoder.decode(Account.self, from: response.data)
          self.accounts.append(account)
          try self.write(token: oauth.client.credential, for: account)
          completion(account)
        } catch {
          self.logger.errorMessage("ERROR decoding new account: \(error)")
        }
      case let .failure(error):
        self.logger.errorMessage("ERROR fetching account data: \(error)")
      }
    }
  }

  // MARK: Saved Account Loading

  private func loadSelectedAccount() -> Account? {
    if let selectedAccountData = defaults.data(forKey: "SelectedAccount") {
      do {
        return try decoder.decode(Account.self, from: selectedAccountData)
      } catch {
        logger.errorMessage("Error decoding stored account: \(error)")
        return nil
      }
    } else {
      return nil
    }
  }

  private func loadAccounts() -> [Account] {
    guard let accountData = defaults.data(forKey: "RedditAccounts") else { return [] }
    do {
      let accounts = try decoder.decode([Account].self, from: accountData)
      return accounts
    } catch {
      logger.errorMessage("Unable to decode saved accounts: \(error)")
      return []
    }
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

  private func token(for account: Account) -> OAuthSwiftCredential? {
    token(for: account.name)
  }

  private func write(token: OAuthSwiftCredential, for account: Account) throws {
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

  private func removeToken(for account: Account) {
    do {
      objectWillChange.send()
      try keychain.remove(account.name)
    } catch {
      logger.errorMessage("ERROR Removing token for \(account.name): \(error)")
    }
  }
}
