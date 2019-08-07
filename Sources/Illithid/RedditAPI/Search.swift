//
//  File.swift
//
//
//  Created by Tyler Gregory on 8/6/19.
//

import Foundation

import Alamofire

public enum SearchType: String {
  case subreddit
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

public extension RedditClientBroker {
  func search(for query: String, subreddit: String? = nil, after: Fullname? = nil, before: Fullname? = nil,
              category: String? = nil, includeFacets: Bool = true,
              limit: UInt = 25, resultsWithinSubreddit: Bool = false, showAll: ShowAllPreference = .filtered,
              topInterval: TopInterval? = nil, resultTypes: Set<SearchType> = [], completion: @escaping (Result<Listing>) -> ()) {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .secondsSince1970
    let queryEncoding = URLEncoding(boolEncoding: .numeric)
    var parameters: Parameters = [
      "q": query
    ]
    let endpoint = subreddit != nil ? URL(string: "/r/\(subreddit!)/search", relativeTo: baseURL)! :
      URL(string: "/search", relativeTo: baseURL)!

    // MARK: Build parameters dictionary

    if before == nil, let afterAnchor = after { parameters["after"] = afterAnchor }
    if let beforeAnchor = before, after == nil { parameters["before"] = beforeAnchor }
    if let categoryFilter = category { parameters["category"] = categoryFilter }
    if limit != 25 { parameters["limit"] = limit }
    if !includeFacets { parameters["include_facets"] = includeFacets }
    if resultsWithinSubreddit { parameters["restrict_sr"] = resultsWithinSubreddit }
    if showAll == .all { parameters["show"] = showAll }
    if let interval = topInterval { parameters["t"] = interval }
    if !resultTypes.isEmpty { parameters["type"] = resultTypes.map { $0.rawValue }.joined(separator: ",") }

    // MARK: Submit request

    session.request(endpoint, method: .get, parameters: parameters, encoding: queryEncoding).validate().responseData { response in
      switch response.result {
      case .success(let data):
        do {
          let listing = try decoder.decode(Listing.self, from: data)
          completion(.success(listing))
        } catch {
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}
