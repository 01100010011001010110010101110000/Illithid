//
// Comments.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 12/24/19
//

#if canImport(Combine)
  import Combine
#endif
import Foundation

import Alamofire
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
                threaded: Bool = true, truncate: Int = 0, queue: DispatchQueue = .main) -> AnyPublisher<Listing, Error> {
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

    return session.requestPublisher(url: commentsListingURL, method: .get, parameters: encodedParameters,
                                    encoding: queryEncoding, queue: queue)
      .decode(type: [Listing].self, decoder: decoder)
      .mapError { (error) -> Error in
        self.logger.errorMessage { "Error fetching comments: \(error)" }
        return error
      }
      .map { listings in
        listings.last!
      }
      .eraseToAnyPublisher()
  }

  func moreComments(for more: More, in post: Post, depth: Int? = nil,
                    limitChildren: Bool = false, sortBy: CommentsSort = .confidence, queue: DispatchQueue = .main) -> AnyPublisher<[CommentWrapper], Error> {
    let moreUrl: URL = URL(string: "/api/morechildren", relativeTo: baseURL)!
    var parameters: Parameters = [
      "api_type": "json",
      "children": more.children.joined(separator: ","),
      "limit_children": limitChildren,
      "link_id": post.fullname,
      "sort": sortBy.rawValue
    ]
    if let depth = depth { parameters["depth"] = depth }

    return session.requestPublisher(url: moreUrl, method: .post, parameters: parameters,
                                    encoding: URLEncoding(destination: .httpBody, boolEncoding: .numeric), queue: queue)
      .decode(type: MoreChildren.self, decoder: decoder)
      .map { $0.allComments }
      .eraseToAnyPublisher()
  }
}

public extension Comment {
  func upvote(queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) {
    Illithid.shared.vote(fullname: fullname, direction: .up, queue: queue, completion: completion)
  }
  func downvote(queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) {
    Illithid.shared.vote(fullname: fullname, direction: .down, queue: queue, completion: completion)
  }
  func clearVote(queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) {
    Illithid.shared.vote(fullname: fullname, direction: .clear, queue: queue, completion: completion)
  }

  func save(queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) {
    Illithid.shared.save(fullname: fullname, queue: queue, completion: completion)
  }
  func unsave(queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) {
    Illithid.shared.unsave(fullname: fullname, queue: queue, completion: completion)
  }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Comment {
  static func fetch(name: Fullname, queue: DispatchQueue = .main) -> AnyPublisher<Comment, Error> {
    Illithid.shared.info(name: name, queue: queue)
      .compactMap { listing in
        listing.comments.last
      }
      .eraseToAnyPublisher()
  }
}

public extension Comment {
  static func fetch(name: Fullname, queue: DispatchQueue = .main, completion: @escaping (Result<Comment, Error>) -> Void) {
    Illithid.shared.info(name: name, queue: queue) { result in
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
