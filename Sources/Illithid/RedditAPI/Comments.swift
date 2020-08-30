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
import Willow

enum CommentRouter: URLConvertible {
  case comments(for: Post.ID, in: String)
  case moreComments

  func asURL() throws -> URL {
    switch self {
    case let .comments(post, subreddit):
      return URL(string: "/r/\(subreddit)/comments/\(post)", relativeTo: Illithid.shared.baseURL)!
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
  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func comments(for post: Post, parameters: ListingParameters,
                by sort: CommentsSort = .confidence, focusOn comment: ID36? = nil, context: Int? = nil,
                depth: Int = 0, showEdits _: Bool = true, showMore: Bool = true,
                threaded: Bool = true, truncate: Int = 0, queue: DispatchQueue = .main) -> AnyPublisher<Listing, AFError> {
    comments(for: post.id, in: post.subreddit, parameters: parameters, by: sort, focusOn: comment, context: context, depth: depth,
             showEdits: showMore, showMore: showMore, threaded: threaded, truncate: truncate, queue: queue)
  }

  /**
   Fetch comments for a particular `Post`
   - Parameters:
     - postId: The `ID36` of the post for which to fetch comments
     - subredditName: The display name of the subreddit the post is in
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
  func comments(for postId: Post.ID, in subredditName: String, parameters: ListingParameters,
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

    return session.request(CommentRouter.comments(for: postId, in: subredditName), method: .get,
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

  func moreComments(for more: More, on post: Post, depth: Int? = nil,
                    limitChildren: Bool = false, sortBy: CommentsSort = .confidence,
                    queue: DispatchQueue = .main) -> AnyPublisher<(comments: [Comment], more: More?), AFError> {
    moreComments(for: more, on: post.name, in: post.subreddit, depth: depth,
                 limitChildren: limitChildren, sortBy: sortBy, queue: queue)
  }

  func moreComments(for more: More, on postFullname: Fullname, in subredit: String, depth: Int? = nil,
                    limitChildren: Bool = false, sortBy: CommentsSort = .confidence,
                    queue: DispatchQueue = .main) -> AnyPublisher<(comments: [Comment], more: More?), AFError> {
    if more.id == More.continueThreadId {
      // We specify threaded: false to mimic the behavior of /api/morechildren
      return comments(for: postFullname.components(separatedBy: "_").last!, in: subredit,
                      parameters: .init(), by: sortBy, focusOn: more.parentId.components(separatedBy: "_").last!,
                      depth: depth ?? 0, threaded: false, queue: queue)
        .map { listing in
          var comments = listing.comments.filter { $0.fullname != more.parentId }
          for idx in comments.indices {
            comments[idx].depth = (comments[idx].depth ?? 0) + more.depth
          }

          return (comments, listing.more)
        }
        .eraseToAnyPublisher()
    } else {
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
        .map { more in
          (more.comments, more.more)
        }
        .eraseToAnyPublisher()
    }
  }
}

public extension Comment {
  @discardableResult
  func upvote(queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) -> DataRequest {
    Illithid.shared.vote(fullname: fullname, direction: .up, queue: queue, completion: completion)
  }

  @discardableResult
  func downvote(queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) -> DataRequest {
    Illithid.shared.vote(fullname: fullname, direction: .down, queue: queue, completion: completion)
  }

  @discardableResult
  func clearVote(queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) -> DataRequest {
    Illithid.shared.vote(fullname: fullname, direction: .clear, queue: queue, completion: completion)
  }

  @discardableResult
  func save(queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) -> DataRequest {
    Illithid.shared.save(fullname: fullname, queue: queue, completion: completion)
  }

  @discardableResult
  func unsave(queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) -> DataRequest {
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
  /// Fetches a comment using its `Fullname` from Reddit's info endpoint
  /// - Warning: This **will not** return a comment's replies; replies will always be empty. For that, you must use the fetch the comment using its permalink
  @discardableResult
  static func fetch(name: Fullname, queue: DispatchQueue = .main, completion: @escaping (Result<Comment, Error>) -> Void) -> DataRequest {
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
