//
// Comments.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 8/1/20
//

#if canImport(Combine)
  import Combine
#endif
import Foundation

import Alamofire
import Willow

enum CommentRouter: URLConvertible {
  case comments(for: Post)
  case moreComments

  func asURL() throws -> URL {
    switch self {
    case let .comments(post):
      return URL(string: "/r/\(post.subreddit)/comments/\(post.id)", relativeTo: Illithid.shared.baseURL)!
    case .moreComments:
      return URL(string: "/api/morechildren", relativeTo: Illithid.shared.baseURL)!
    }
  }
}

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
  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)  func comments(for post: Post, parameters: ListingParameters,
                                                                              by sort: CommentsSort = .confidence, focusOn comment: ID36? = nil, context: Int? = nil,
                                                                              depth: Int = 0, showEdits: Bool = true, showMore: Bool = true,
                                                                              threaded: Bool = true, truncate: Int = 0, queue: DispatchQueue = .main) -> AnyPublisher<Listing, AFError> {
    let queryEncoding = URLEncoding(boolEncoding: .numeric)

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

    return session.request(CommentRouter.comments(for: post), method: .get,
                           parameters: encodedParameters, encoding: queryEncoding)
      .publishDecodable(type: [Listing].self, queue: queue, decoder: decoder)
      .value()
      .mapError { (error) -> AFError in
        self.logger.errorMessage { "Error fetching comments: \(error)" }
        return error
      }
      .map { listings in
        listings.last!
      }
      .eraseToAnyPublisher()
  }

  func moreComments(for more: More, in post: Post, depth: Int? = nil,
                    limitChildren: Bool = false, sortBy: CommentsSort = .confidence, queue: DispatchQueue = .main) -> AnyPublisher<(comments: [Comment], more: More?), AFError> {
    moreComments(for: more, in: post.name, depth: depth,
                 limitChildren: limitChildren, sortBy: sortBy, queue: queue)
  }

  func moreComments(for more: More, in postFullname: Fullname, depth: Int? = nil,
                    limitChildren: Bool = false, sortBy: CommentsSort = .confidence, queue: DispatchQueue = .main) -> AnyPublisher<(comments: [Comment], more: More?), AFError> {
    var parameters: Parameters = [
      "api_type": "json",
      "children": more.children.joined(separator: ","),
      "limit_children": limitChildren,
      "link_id": postFullname,
      "sort": sortBy.rawValue,
    ]
    if let depth = depth { parameters["depth"] = depth }

    return session.request(CommentRouter.moreComments, method: .post, parameters: parameters,
                           encoding: URLEncoding(destination: .httpBody, boolEncoding: .numeric))
      .publishDecodable(type: MoreChildren.self, queue: queue, decoder: decoder)
      .value()
      .map { ($0.comments, $0.more) }
      .eraseToAnyPublisher()
  }
}

public extension Comment {
  @discardableResult  func upvote(queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) -> DataRequest {
    Illithid.shared.vote(fullname: fullname, direction: .up, queue: queue, completion: completion)
  }

  @discardableResult  func downvote(queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) -> DataRequest {
    Illithid.shared.vote(fullname: fullname, direction: .down, queue: queue, completion: completion)
  }

  @discardableResult  func clearVote(queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) -> DataRequest {
    Illithid.shared.vote(fullname: fullname, direction: .clear, queue: queue, completion: completion)
  }

  @discardableResult  func save(queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) -> DataRequest {
    Illithid.shared.save(fullname: fullname, queue: queue, completion: completion)
  }

  @discardableResult  func unsave(queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) -> DataRequest {
    Illithid.shared.unsave(fullname: fullname, queue: queue, completion: completion)
  }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Comment {
  static func fetch(name: Fullname, queue: DispatchQueue = .main) -> AnyPublisher<Comment, AFError> {
    Illithid.shared.info(name: name, queue: queue)
      .compactMap { listing in
        listing.comments.last
      }
      .eraseToAnyPublisher()
  }
}

public extension Comment {
  @discardableResult  static func fetch(name: Fullname, queue: DispatchQueue = .main, completion: @escaping (Result<Comment, Error>) -> Void) -> DataRequest {
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

public extension Comment {
  func isModComment(queue: DispatchQueue = .main,
                    completion: @escaping (Result<Bool, AFError>) -> Void) -> DataRequest {
    Illithid.shared.moderatorsOf(displayName: subreddit, queue: queue) { result in
      switch result {
      case let .success(moderators):
        if moderators.contains(where: { $0.name == self.author }) {
          completion(.success(true))
        } else {
          completion(.success(false))
        }
      case let .failure(error):
        completion(.failure(error))
      }
    }
  }
}
