//
// Illithid.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 12/24/19
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

  public let redditBrowserUrl: URL = URL(string: "https://www.reddit.com/")!
  public var baseURL: URL {
    accountManager.currentAccount != nil ? URL(string: baseURLs.authenticated.rawValue)! : URL(string: baseURLs.unauthenticated.rawValue)!
  }

  public static let authorizeEndpoint: URL = URL(string: "https://www.reddit.com/api/v1/authorize.compact")!
  public static let tokenEndpoint: URL = URL(string: "https://www.reddit.com/api/v1/access_token")!

  open var logger: Logger

  // TODO: Make this private
  public let accountManager: AccountManager

  internal let decoder: JSONDecoder = .init()

  internal var session: Session

  private init() {
    decoder.dateDecodingStrategy = .secondsSince1970
    decoder.keyDecodingStrategy = .convertFromSnakeCase

    #if DEBUG
      logger = .debugLogger()
    #else
      logger = .releaseLogger(subsystem: "com.flayware.illithid")
    #endif

    accountManager = AccountManager(logger: logger)
    session = accountManager.makeSession(for: accountManager.currentAccount)
  }

  public func configure(configuration: ClientConfiguration) {
    accountManager.configuration = configuration
    session.cancelAllRequests()
    session = accountManager.makeSession(for: accountManager.currentAccount)
  }
}

internal extension Illithid {
  /// Reads a `Listing` from `url`
  /// - Parameters:
  ///   - url: The `Listing` returning endpoint from which to read a listing
  ///   - completion: The function to call upon fetching a `Listing`
  @discardableResult
  func readListing(url: Alamofire.URLConvertible, parameters: Parameters = .init(),
                   queue: DispatchQueue = .main, completion: @escaping (Result<Listing, AFError>) -> Void) -> DataRequest {
    let queryEncoding = URLEncoding(boolEncoding: .numeric)

    return session.request(url, method: .get, parameters: parameters, encoding: queryEncoding).validate()
      .responseDecodable(of: Listing.self, queue: queue, decoder: decoder) { request in
        completion(request.result)
      }
  }

  /// Reads all `Listings` from `url`
  /// - Parameters:
  ///   - url: The `Listing` returning endpoint from which to read a listing
  ///   - completion: The function to call upon fetching all `Listings`
  /// - Warning: If this method is called on a large endpoint, like the endpoint for fetching all subreddits, this method may take a very long time to terminate or not terminate at all
  func readAllListings(url: Alamofire.URLConvertible, queue: DispatchQueue = .main, completion: @escaping (Result<[Listing], AFError>) -> Void) {
    let queryEncoding = URLEncoding(boolEncoding: .numeric)
    var results: [Listing] = []
    var parameters: Parameters = ["after": ""] {
      didSet {
        guard let after = parameters["after"] as? String, !after.isEmpty else {
          completion(.success(results))
          return
        }
        readListing(url: url, parameters: parameters, queue: queue) { result in
          switch result {
          case let .success(listing):
            results.append(listing)
            parameters["after"] = listing.after ?? ""
          case let .failure(error):
            self.logger.errorMessage("Error reading all listings for [\((try? url.asURL().absoluteString) ?? "Invalid URL")]: \(error)")
            completion(.failure(error))
            return
          }
        }
      }
    }
    readListing(url: url, queue: queue) { result in
      switch result {
      case let .success(listing):
        results.append(listing)
        parameters["after"] = listing.after ?? ""
      case let .failure(error):
        self.logger.errorMessage("Error reading all listings for [\((try? url.asURL().absoluteString) ?? "Invalid URL")]: \(error)")
        completion(.failure(error))
        return
      }
    }
  }
}
