//
// Comments.swift
// Copyright (c) 2019 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 12/24/19
//

#if canImport(Combine)
  import Combine
#endif
import Foundation

import Alamofire
import SwiftyJSON
import Willow

public extension Illithid {
  /**
   Fetch comments for a particular `Post`
   - Parameters:
     - post: The post for which to fetch comments
     - parameters: The standard `ListingParams` to pass to the listing endopont when slicing through comments
     - focus: The root comment of the returned `Comment` `Listing`
     - context: The number of parents to give the`focus` `Comment`
     - depth: The maximum number of `Comment` subtrees
     - showEdits: Whether to show if a comment has been edited
     - showMore: Whether to append a `more` `Listing` to leaf comments with more replies. Whether a `Comment`'s `replies` attribute is a `more`,
                 a standard `Comment` `Listing`, or the empty string is governed by the sort method.
     - sortBy: Which Reddit sort method to use when fetching comments
     - threaded: If true, the comments listing returns a `Comment` `Listing` with `replies` properties on each comment node. If false, the `Listing` is instead a flat
                 array and the client must determine threading from the `parentID` attribute
     - truncate: Truncate the listing after `truncate` `Comments` if greater than zero
   - Returns: A one-shot `AnyPublisher` with the `Listing` or an error
   */
  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func comments(for post: Post, parameters: ListingParameters,
                by sort: CommentsSort = .confidence, focusOn comment: Comment? = nil, context: Int? = nil,
                depth: Int = 0, showEdits: Bool = true, showMore: Bool = true,
                threaded: Bool = true, truncate: Int = 0) -> AnyPublisher<Listing, Error> {
    let queryEncoding = URLEncoding(boolEncoding: .numeric)
    let commentsListingURL = URL(string: "/r/\(post.subreddit)/comments/\(post.id)", relativeTo: baseURL)!

    var encodedParameters = parameters.toParameters()
    let commentsParameters: Parameters = [
      "comment": comment ?? "",
      "context": context ?? "",
      "depth": depth,
      "showedits": showEdits,
      "showmore": showMore,
      "sort": sort.rawValue,
      "threaded": threaded,
      "truncate": truncate,
    ]
    encodedParameters.merge(commentsParameters) { current, _ in current }

    return session.requestPublisher(url: commentsListingURL, method: .get, parameters: encodedParameters, encoding: queryEncoding)
      .compactMap { response in
        response.data
      }
      .decode(type: [Listing].self, decoder: decoder)
      .mapError { (error) -> Error in
        self.logger.errorMessage { "Error fetching comments: \(error)" }
        return error
      }
      .map { listings in
        listings.last!
      }.eraseToAnyPublisher()
  }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Comment {
  static func fetch(name: Fullname) -> AnyPublisher<Comment, Error> {
    Illithid.shared.info(name: name)
      .compactMap { listing in
        listing.comments.last
      }.eraseToAnyPublisher()
  }
}

public extension Comment {
  static func fetch(name: Fullname, completion: @escaping (Result<Comment>) -> Void) {
    Illithid.shared.info(name: name) { result in
      switch result {
      case let .success(listing):
        guard let comment = listing.comments.last else {
          completion(.failure(Illithid.NotFound(lookingFor: name)))
          return
        }
        completion(.success(comment))
      case let .failure(error):
        completion(.failure(error))
      }
    }
  }
}
