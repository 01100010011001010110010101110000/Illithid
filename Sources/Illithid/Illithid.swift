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
import Cocoa
import Foundation

import Alamofire
import OAuthSwift
import Willow

// MARK: - Illithid

/// Handles Reddit API meta-operations
open class Illithid: ObservableObject {
  // MARK: Lifecycle

  private init() {
    decoder.dateDecodingStrategy = .secondsSince1970

    #if DEBUG
      logger = .debugLogger()
    #else
      logger = .releaseLogger(subsystem: "com.flayware.illithid")
    #endif

    redditEventTimeFormatter = ISO8601DateFormatter()
    redditEventTimeFormatter.formatOptions = [.withFullDate, .withTime, .withColonSeparatorInTime]

    accountManager = AccountManager(logger: logger)
    session = accountManager.makeSession(for: accountManager.currentAccount)
  }

  // MARK: Open

  open var logger: Logger

  // MARK: Public

  public static var shared: Illithid = .init()
  public static let authorizeEndpoint = URL(string: "https://www.reddit.com/api/v1/authorize.compact")!
  public static let tokenEndpoint = URL(string: "https://www.reddit.com/api/v1/access_token")!

  public let redditBrowserUrl = URL(string: "https://www.reddit.com/")!
  // TODO: Make this private
  public let accountManager: AccountManager

  public var baseURL: URL {
    accountManager.currentAccount != nil ? URL(string: baseURLs.authenticated.rawValue)! : URL(string: baseURLs.unauthenticated.rawValue)!
  }

  public func configure(configuration: ClientConfiguration) {
    accountManager.configuration = configuration
    session.cancelAllRequests()
    session = accountManager.makeSession(for: accountManager.currentAccount)
  }

  // MARK: Internal

  internal let decoder: JSONDecoder = .init()

  internal var redditEventTimeFormatter: ISO8601DateFormatter

  internal var session: Session

  // MARK: Private

  private enum baseURLs: String, Codable {
    case unauthenticated = "https://api.reddit.com/"
    case authenticated = "https://oauth.reddit.com/"
  }
}

internal extension Illithid {
  /// Reads a `Listing` from `url`
  /// - Parameters:
  ///   - url: The `Listing` returning endpoint from which to read a listing
  ///   - completion: The function to call upon fetching a `Listing`
  @discardableResult
  func readListing(url: Alamofire.URLConvertible, queryParameters: Parameters? = nil,
                   listingParameters: ListingParameters = .init(), redirectHandler: Redirector = .follow,
                   queue: DispatchQueue = .main, completion: @escaping (Result<Listing, AFError>) -> Void)
    -> DataRequest {
    let queryEncoding = URLEncoding(boolEncoding: .numeric)

    let _parameters = listingParameters.toParameters()
      .merging(queryParameters ?? [:], uniquingKeysWith: { $1 })

    return session.request(url, method: .get, parameters: _parameters, encoding: queryEncoding)
      .redirect(using: redirectHandler)
      .validate()
      .responseDecodable(of: Listing.self, queue: queue, decoder: decoder) { request in
        if case let .failure(error) = request.result {
          print(error)
        }
        completion(request.result)
      }
  }

  @discardableResult
  func readListing(request: Alamofire.URLRequestConvertible, redirectHandler: Redirector = .follow,
                   queue: DispatchQueue = .main, completion: @escaping (Result<Listing, AFError>) -> Void)
    -> DataRequest {
    session.request(request)
      .redirect(using: redirectHandler)
      .validate()
      .responseDecodable(of: Listing.self, queue: queue, decoder: decoder) { completion($0.result) }
  }

  /// Reads all `Listings` from `url`
  /// - Parameters:
  ///   - url: The `Listing` returning endpoint from which to read a listing
  ///   - queue: The `DispatchQueue` in which `completion` will run
  ///   - completion: The function to call upon fetching all `Listings`
  /// - Warning: If this method is called on a large endpoint, like the endpoint for fetching subreddits, this method may take a very long time to terminate or not terminate at all
  func readAllListings(url: Alamofire.URLConvertible, redirectHandler: Redirector = .follow,
                       queue: DispatchQueue = .main, completion: @escaping (Result<[Listing], AFError>) -> Void) {
    var results: [Listing] = []
    var parameters: Parameters = ["after": ""] {
      didSet {
        guard let after = parameters["after"] as? String, !after.isEmpty else {
          completion(.success(results))
          return
        }
        readListing(url: url, queryParameters: parameters, redirectHandler: redirectHandler, queue: queue) { result in
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
    readListing(url: url, redirectHandler: redirectHandler, queue: queue) { result in
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
