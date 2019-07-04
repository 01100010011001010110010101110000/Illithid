//
//  File.swift
//
//
//  Created by Tyler Gregory on 6/20/19.
//

import Combine
import Foundation

import Alamofire
import SwiftyJSON
import Willow

public extension RedditClientBroker {
  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func getComments(for post: Post, parameters: ListingParams, focus: Comment? = nil, context: Int? = nil, depth: Int? = nil, showedits: Bool = true, showmore: Bool = true, sortBy: CommentsSort = .confidence, threaded: Bool = true, truncate: Int = 0)
    -> AnyPublisher<Listing, Error> {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .secondsSince1970
    let queryEncoding = URLEncoding(boolEncoding: .numeric)
    let commentsListingURL = URL(string: "https://oauth.reddit.com/r/\(post.subreddit)/comments/\(post.id)")!

    var encodedParameters = parameters.toParameters()
    encodedParameters["sort"] = sortBy.rawValue

    return session.requestPublisher(url: commentsListingURL, method: .get, parameters: encodedParameters, encoding: queryEncoding)
      .filter { $0.data != nil }
      .map { response in
        print(response.data!)
        return response.data!
      }
      .decode(type: [Listing].self, decoder: decoder)
      .mapError { (error) -> Error in
        self.logger.errorMessage { "Error fetching comments: \(error)" }
        return error
      }
      .map { listings in
        return listings.last!
      }.eraseToAnyPublisher()
  }
}
