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

#if canImport(Combine)
  import Combine
#endif
import Foundation

import Alamofire

// MARK: - SearchType

public enum SearchType: String, CaseIterable {
  case subreddit = "sr"
  case post = "link"
  case user
}

// MARK: - SearchSort

public enum SearchSort: String, Codable, CaseIterable, Identifiable, Hashable {
  public var id: Self.RawValue {
    rawValue
  }
  
  case relevance
  case hot
  case top
  case new
  case comments
}

// MARK: - SearchRouter

private enum SearchRouter: URLConvertible, URLRequestConvertible, MirrorableEnum {
  case search(subreddit: Subreddit?)
  case completeSubredditName(query: String, exact: Bool, over_18: Bool, include_unadvertisable: Bool)
  case completeSubreddit(query: String, limit: Int, exact: Bool, include_over_18: Bool, include_profiles: Bool)
  case searchSubreddit(query: String, exact: Bool, over_18: Bool, include_unadvertisable: Bool)

  // MARK: Internal

  var method: HTTPMethod {
    switch self {
    case .completeSubredditName, .searchSubreddit:
      return .post
    default:
      return .get
    }
  }

  var path: String {
    switch self {
    case let .search(subreddit):
      if let subreddit = subreddit {
        return "/r/\(subreddit.displayName)/search"
      } else {
        return "/search"
      }
    case .completeSubredditName:
      return "/api/search_reddit_names"
    case .completeSubreddit:
      return "/api/subreddit_autocomplete_v2"
    case .searchSubreddit:
      return "/api/search_subreddits"
    }
  }

  var parameters: Parameters {
    switch self {
    default:
      return mirror.parameters
    }
  }

  func asURL() throws -> URL {
    URL(string: path, relativeTo: Illithid.shared.baseURL)!
  }

  func asURLRequest() throws -> URLRequest {
    let request = try URLRequest(url: self, method: method)
    switch self {
    case .completeSubredditName:
      return try URLEncoding.httpBody.encode(request, with: parameters)
    default:
      return try URLEncoding.queryString.encode(request, with: parameters)
    }
  }
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
  @discardableResult
  func search(for query: String, subreddit: String? = nil, after: Fullname? = nil, before: Fullname? = nil,
              limit: UInt = 25, show: ShowAllPreference = .filtered, sort: SearchSort = .relevance,
              topInterval: TopInterval? = nil, resultTypes: Set<SearchType> = [.subreddit, .post, .user], queue: DispatchQueue = .main,
              completion: @escaping (Result<[Listing], Error>) -> Void)
    -> DataRequest {
    let queryEncoding = URLEncoding(boolEncoding: .numeric)
    var parameters: Parameters = ["q": query]

    // If a subreddit is supplied, restrict results to that subreddit
    let endpoint = subreddit != nil ? URL(string: "/r/\(subreddit!)/search", relativeTo: baseURL)! :
      URL(string: "/search", relativeTo: baseURL)!

    // MARK: Build parameters dictionary

    if let afterAnchor = after { parameters["after"] = afterAnchor }
    if let beforeAnchor = before { parameters["before"] = beforeAnchor }
    parameters["limit"] = limit
    parameters["restrict_sr"] = subreddit != nil
    parameters["show"] = show
    parameters["sort"] = sort
    if let interval = topInterval { parameters["t"] = interval }
    parameters["type"] = resultTypes.map { $0.rawValue }.joined(separator: ",")

    // MARK: Submit request

    return session.request(endpoint, method: .get, parameters: parameters, encoding: queryEncoding)
      .validate()
      .responseData(queue: queue) { response in
        switch response.result {
        case let .success(data):
          do {
            let listing = try self.decoder.decode(Listing.self, from: data)
            completion(.success([listing]))
          } catch {
            do {
              let listings = try self.decoder.decode([Listing].self, from: data)
              completion(.success(listings))
            } catch let innerError {
              completion(.failure(innerError))
            }
          }
        case let .failure(error):
          completion(.failure(error))
        }
      }
  }
}

public extension Illithid {
  /// Returns the names of subreddits beginning with `startsWith`
  /// - Parameters:
  ///   - startsWith: The string to search for, up to fifty characters long
  ///   - exact: If `true` only return exact matches
  ///   - includeNsfw: If `false`, do not suggest NSFW subreddits
  ///   - includeUnadvertisable: If `false`, excludes subreddits with `hide_ads` set to `true` or
  ///                            which are on the `anti_ads_subreddits` list
  ///   - queue: The `DispatchQueue` on which `completion` is executed
  ///   - completion: Called with either an `AFError` or a `[String]` containing the names suggested by autocomplete
  /// - Returns: The generated `DataRequest`
  @discardableResult
  func completeSubredditNames(startsWith query: String,
                              exact: Bool = false,
                              includeNsfw: Bool = true,
                              includeUnadvertisable: Bool = true,
                              queue: DispatchQueue = .main,
                              completion: @escaping (Result<[String], AFError>) -> Void)
    -> DataRequest {
    assert(query.count <= 50, "Query must be no more than 50 characters")
    return session.request(SearchRouter.completeSubredditName(query: query, exact: exact, over_18: includeNsfw,
                                                              include_unadvertisable: includeUnadvertisable))
      .validate()
      .responseDecodable(of: CompletedSubredditNames.self, queue: queue, decoder: decoder) { response in
        switch response.result {
        case let .success(names):
          completion(.success(names.names))
        case let .failure(error):
          completion(.failure(error))
        }
      }
  }

  /// Returns the names of subreddits beginning with `startsWith`
  /// - Parameters:
  ///   - startsWith: The string to search for, up to fifty characters long
  ///   - exact: If `true` only return exact matches
  ///   - includeNsfw: If `false`, do not suggest NSFW subreddits
  ///   - includeUnadvertisable: If `false`, excludes subreddits with `hide_ads` set to `true` or
  ///                            which are on the `anti_ads_subreddits` list
  ///   - queue: The `DispatchQueue` on which the result will be published is executed
  /// - Returns: The generated `AnyPublisher<[String, AFError]>` containing either an `AFError` or a `[String]` containing the names suggested by autocomplete
  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func completeSubredditNames(startsWith query: String,
                              exact: Bool = false,
                              includeNsfw: Bool = true,
                              includeUnadvertisable: Bool = true,
                              queue: DispatchQueue = .main)
    -> AnyPublisher<[String], AFError> {
    assert(query.count <= 50, "Query must be less than 50 characters")
    return session.request(SearchRouter.completeSubredditName(query: query, exact: exact, over_18: includeNsfw,
                                                              include_unadvertisable: includeUnadvertisable))
      .validate()
      .publishDecodable(type: CompletedSubredditNames.self, queue: queue, decoder: decoder)
      .value()
      .map { $0.names }
      .eraseToAnyPublisher()
  }

  /// Returns the full `Subreddit` objects of subreddits beginning with `startsWith`
  /// - Parameters:
  ///   - startsWith: The string to search for, up to twenty-five characters long
  ///   - exact: If `true` only return exact matches
  ///   - limit: The maximum number of results to return. Must be between one and ten
  ///   - includeNsfw: If `false`, do not suggest NSFW subreddits
  ///   - includeProfiles: If `false`, do not suggest user profile subreddits
  ///   - queue: The `DispatchQueue` on which `completion` will be called
  ///   - completion: The callback to be performed
  /// - Returns: The generated `DataRequest`
  @discardableResult
  func completeSubreddits(startsWith query: String,
                          exact: Bool = false,
                          limit: Int = 5,
                          includeNsfw: Bool = true,
                          includeProfiles: Bool = true,
                          queue: DispatchQueue = .main,
                          completion: @escaping (Result<[Subreddit], AFError>) -> Void)
    -> DataRequest {
    assert(query.count <= 25, "Query must be no more than 25 characters")
    assert(limit >= 1 && limit <= 10, "Limit must be between 1 and 10, inclusive")
    return session.request(SearchRouter.completeSubreddit(query: query, limit: limit, exact: exact,
                                                          include_over_18: includeNsfw,
                                                          include_profiles: includeProfiles))
      .validate()
      .responseDecodable(of: Listing.self, queue: queue, decoder: decoder) { response in
        switch response.result {
        case let .success(listing):
          completion(.success(listing.subreddits))
        case let .failure(error):
          completion(.failure(error))
        }
      }
  }

  /// Returns the full `Subreddit` objects of subreddits beginning with `startsWith`
  /// - Parameters:
  ///   - startsWith: The string to search for, up to twenty-five characters long
  ///   - exact: If `true`, only return exact matches
  ///   - limit: The maximum number of results to return. Must be between one and ten
  ///   - includeNsfw: If `false`, do not suggest NSFW subreddits
  ///   - includeProfiles: If `false`, do not suggest user profile subreddits
  ///   - queue: The `DispatchQueue` on which the result will be posted
  /// - Returns: The generated `AnyPublisher` containing either an `AFError` or a `[Subreddit]` with the suggested subreddits
  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func completeSubreddits(startsWith query: String,
                          exact: Bool = false,
                          limit: Int = 5,
                          includeNsfw: Bool = true,
                          includeProfiles: Bool = true,
                          queue: DispatchQueue = .main)
    -> AnyPublisher<[Subreddit], AFError> {
    assert(query.count <= 25, "Query must be no more than 25 characters")
    assert(limit >= 1 && limit <= 10, "Limit must be between 1 and 10, inclusive")
    return session.request(SearchRouter.completeSubreddit(query: query, limit: limit, exact: exact,
                                                          include_over_18: includeNsfw,
                                                          include_profiles: includeProfiles))
      .validate()
      .publishDecodable(type: Listing.self, queue: queue, decoder: decoder)
      .value()
      .map { $0.subreddits }
      .eraseToAnyPublisher()
  }

  /// Returns `SubredditSuggestion` objects for subreddits beginning with `startsWith`
  /// - Parameters:
  ///   - startsWith: The string to search for, up to fifty characters long
  ///   - exact: If `true`, only return exact matches
  ///   - includeNsfw: If `false`, do not suggest NSFW subreddits
  ///   - includeUnadvertisable: If `false`, excludes subreddits with `hide_ads` set to `true` or
  ///                            which are on the `anti_ads_subreddits` list
  ///   - queue: The `DispatchQueue` on which `completion` will be called
  ///   - completion: The callback that will be called with the result
  /// - Returns: The generated `DataRequest`
  func searchSubreddits(startsWith query: String,
                        exact: Bool = false,
                        includeNsfw: Bool = true,
                        includeUnadvertisable: Bool = true,
                        queue: DispatchQueue = .main,
                        completion: @escaping (Result<[SubredditSuggestion], AFError>) -> Void)
    -> DataRequest {
    assert(query.count <= 50, "Query must be no more than 50 characters")
    return session.request(SearchRouter.searchSubreddit(query: query, exact: exact, over_18: includeNsfw,
                                                        include_unadvertisable: includeUnadvertisable))
      .validate()
      .responseDecodable(of: SubredditSuggestions.self, queue: queue, decoder: decoder) { response in
        switch response.result {
        case let .success(suggestions):
          completion(.success(suggestions.subreddits))
        case let .failure(error):
          completion(.failure(error))
        }
      }
  }

  /// Returns `SubredditSuggestion` objects for subreddits beginning with `startsWith`
  /// - Parameters:
  ///   - startsWith: The string to search for, up to fifty characters long
  ///   - exact: If `true`, only return exact matches
  ///   - includeNsfw: If `false`, do not suggest NSFW subreddits
  ///   - includeUnadvertisable: If `false`, excludes subreddits with `hide_ads` set to `true` or
  ///                            which are on the `anti_ads_subreddits` list
  ///   - queue: The `DispatchQueue` on which `completion` will be called
  /// - Returns: The generated `AnyPublisher`
  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func searchSubreddits(startsWith query: String,
                        exact: Bool = false,
                        includeNsfw: Bool = true,
                        includeUnadvertisable: Bool = true,
                        queue: DispatchQueue = .main)
    -> AnyPublisher<[SubredditSuggestion], AFError> {
    assert(query.count <= 50, "Query must be no more than 50 characters")
    return session.request(SearchRouter.searchSubreddit(query: query, exact: exact, over_18: includeNsfw,
                                                        include_unadvertisable: includeUnadvertisable))
      .validate()
      .publishDecodable(type: SubredditSuggestions.self, queue: queue, decoder: decoder)
      .value()
      .map { $0.subreddits }
      .eraseToAnyPublisher()
  }
}
