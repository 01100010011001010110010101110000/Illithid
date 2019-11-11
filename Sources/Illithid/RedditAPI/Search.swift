//
//  File.swift
//
//
//  Created by Tyler Gregory on 8/6/19.
//

import Foundation

import Alamofire

public enum SearchType: String {
  case subreddit = "sr"
  case post = "link"
  case user
}

public enum SearchSort: String, Codable {
  case relevance
  case hot
  case top
  case new
  case comments
}

public extension Illithid {
  /// Queries the Reddit search API and returns matching subreddits, users, or posts
  /// - Parameter query: The search term
  /// - Parameter subreddit: If supplied, will restrict the search results to a specific subreddit
  /// - Parameter after: The `fullname` after which to return results. Used to page through search results
  /// - Parameter before: The `fullname` before which to return results. Used to page through search results
  /// - Parameter limit: The maximum number of results to return
  /// - Parameter showAll: If set to `.all` the search will ignore reddit wide filters set on a user profile
  /// - Parameter sort: The sort method to use when returning results
  /// - Parameter topInterval: The interval to use for `top` ordering
  /// - Parameter resultTypes: The Reddit types to search for
  /// - Parameter completion: The callback to be executed when the search returns
  /// - Note: The Reddit search API is weird and seems to return results depending on which `resultTypes` combination is chosen. It also seems to ignore the `limit` argument.
  func search(for query: String, subreddit: String? = nil, after: Fullname? = nil, before: Fullname? = nil,
              limit: UInt = 25, showAll: ShowAllPreference = .filtered, sort: SearchSort = .relevance,
              topInterval: TopInterval? = nil, resultTypes: Set<SearchType> = [.subreddit, .post, .user], completion: @escaping (Result<[Listing]>) -> Void) {
    let queryEncoding = URLEncoding(boolEncoding: .numeric)
    var parameters: Parameters = [
      "q": query,
      "raw_json": true,
    ]

    // If a subreddit is supplied, restrict results to that subreddit
    let endpoint = subreddit != nil ? URL(string: "/r/\(subreddit!)/search", relativeTo: baseURL)! :
      URL(string: "/search", relativeTo: baseURL)!

    // MARK: Build parameters dictionary

    if before == nil, let afterAnchor = after { parameters["after"] = afterAnchor }
    if let beforeAnchor = before, after == nil { parameters["before"] = beforeAnchor }
    if limit != 25 { parameters["limit"] = limit }
    if subreddit != nil { parameters["restrict_sr"] = true }
    if showAll == .all { parameters["show"] = showAll }
    if sort != .relevance { parameters["sort"] = sort }
    if sort == .top, let interval = topInterval { parameters["t"] = interval }
    if !resultTypes.isEmpty { parameters["type"] = resultTypes.map { $0.rawValue }.joined(separator: ",") }

    // MARK: Submit request

    session.request(endpoint, method: .get, parameters: parameters, encoding: queryEncoding).validate().responseData { response in
      switch response.result {
      case let .success(data):
        do {
          // The search API combines the user and subreddits results into a single listing
          // Therefore, we have a single listing when either we are searching for one term or both subreddits and users, and an array otherwise
          if resultTypes.count == 1 || resultTypes == [.subreddit, .user] {
            let listing = try self.decoder.decode(Listing.self, from: data)
            completion(.success([listing]))
          } else {
            let listings = try self.decoder.decode([Listing].self, from: data)
            completion(.success(listings))
          }
        } catch let error as DecodingError {
          self.decoder.writeDecodingContext(decoding: data, error: error)
          completion(.failure(error))
        } catch {
          completion(.failure(error))
        }
      case let .failure(error):
        completion(.failure(error))
      }
    }
  }
}
