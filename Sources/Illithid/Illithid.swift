//
// Created by Tyler Gregory on 11/19/18.
// Copyright (c) 2018 flayware. All rights reserved.
//

import AuthenticationServices
import Cocoa
import Foundation

import Alamofire
import OAuthSwift
import Willow

/// Handles Reddit API meta-operations
open class Illithid: ObservableObject {
  public static var shared: Illithid = .init()

  private enum baseURLs: String, Codable {
    case unauthenticated = "https://api.reddit.com/"
    case authenticated = "https://oauth.reddit.com/"
  }

  public var baseURL: URL {
    accountManager.currentAccount != nil ? URL(string: baseURLs.authenticated.rawValue)! : URL(string: baseURLs.unauthenticated.rawValue)!
  }

  public static let authorizeEndpoint: URL = URL(string: "https://www.reddit.com/api/v1/authorize.compact")!
  public static let tokenEndpoint: URL = URL(string: "https://www.reddit.com/api/v1/access_token")!

  open var logger: Logger

  // TODO: Make this private
  public let accountManager: AccountManager

  internal let decoder: JSONDecoder = .init()

  internal var session: SessionManager

  private init() {
    #if DEBUG
      logger = .debugLogger()
    #else
      logger = .releaseLogger(subsystem: "com.illithid.illithid")
    #endif

    accountManager = AccountManager(logger: logger)
    session = accountManager.makeSession(for: accountManager.currentAccount)

    decoder.dateDecodingStrategy = .secondsSince1970
    decoder.keyDecodingStrategy = .convertFromSnakeCase
  }

  public func configure(configuration: ClientConfiguration) {
    accountManager.configuration = configuration
    session.session.invalidateAndCancel()
    session = accountManager.makeSession(for: accountManager.currentAccount)
  }
}

internal extension Illithid {
  /// Reads a `Listing` from `url`
  /// - Parameters:
  ///   - url: The `Listing` returning endpoint from which to read a listing
  ///   - completion: The function to call upon fetching a `Listing`
  func readListing(url: URL, _ completion: @escaping (Listing) -> Void) {
    let queryEncoding = URLEncoding(boolEncoding: .numeric)
    session.request(url, method: .get, parameters: ListingParameters().toParameters(), encoding: queryEncoding).validate().responseData { request in
      switch request.result {
      case let .success(data):
        let list = try! self.decoder.decode(Listing.self, from: data)
        completion(list)
      case let .failure(error):
        return
      }
    }
  }

  /// Reads all `Listings` from `url`
  /// - Parameters:
  ///   - url: The `Listing` returning endpoint from which to read a listing
  ///   - completion: The function to call upon fetching all `Listings`
  /// - Warning: If this method is called on a large endpoint, like the endpoint for fetching all subreddits, this method may take a very long time to terminate or not terminate at all
  func readAllListings(url: URL, completion: @escaping ([Listing]) -> Void) {
    let queryEncoding = URLEncoding(boolEncoding: .numeric)
    var results: [Listing] = []
    var after: Fullname? = "" {
      didSet {
        if after == nil {
          completion(results)
        } else {
          session.request(url, method: .get, parameters: ListingParameters(after: after!).toParameters(), encoding: queryEncoding).validate().responseData { request in
            switch request.result {
            case let .success(data):
              let list = try! self.decoder.decode(Listing.self, from: data)
              results.append(list)
              after = list.after
            case let .failure(error):
              return
            }
          }
        }
      }
    }
    session.request(url, method: .get, parameters: ListingParameters(after: after!).toParameters(), encoding: queryEncoding).validate().responseData { request in
      switch request.result {
      case let .success(data):
        let list = try! self.decoder.decode(Listing.self, from: data)
        results.append(list)
        after = list.after
      case let .failure(error):
        return
      }
    }
  }
}
