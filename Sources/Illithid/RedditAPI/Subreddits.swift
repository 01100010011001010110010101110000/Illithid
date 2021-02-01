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

// MARK: - SubredditRouter

enum SubredditRouter: URLConvertible {
  case subreddits(sort: SubredditSort)
  case moderators(subredditDisplayName: String)
  case postRequirements(subredditDisplayName: String)

  // MARK: Internal

  func asURL() throws -> URL {
    switch self {
    case let .subreddits(sort):
      return URL(string: "/subreddits/\(sort)", relativeTo: baseUrl)!
    case let .moderators(displayName):
      return URL(string: "/r/\(displayName)/about/moderators", relativeTo: baseUrl)!
    case let .postRequirements(subredditDisplayName):
      return URL(string: "/api/v1/\(subredditDisplayName)/post_requirements", relativeTo: baseUrl)!
    }
  }

  // MARK: Private

  private var baseUrl: URL {
    Illithid.shared.baseURL
  }
}

public extension Illithid {
  /**
   Loads subreddits from the Reddit API

   - Parameters:
     - subredditSort: Subreddit sort method
     - params: Standard listing parameters object
     - completion: Completion handler, is passed the listable as an argument
   */
  func subreddits(sortBy sort: SubredditSort = .popular,
                  params: ListingParameters = .init(), queue: DispatchQueue = .main,
                  completion: @escaping (Result<Listing, AFError>) -> Void) {
    let parameters = params.toParameters()
    readListing(url: SubredditRouter.subreddits(sort: sort),
                queryParameters: parameters, queue: queue) { result in
      completion(result)
    }
  }

  func postRequirements(for subredditName: String, queue: DispatchQueue = .main, completion: @escaping (Result<PostRequirements, AFError>) -> Void) -> DataRequest {
    session.request(SubredditRouter.postRequirements(subredditDisplayName: subredditName))
      .validate()
      .responseDecodable(of: PostRequirements.self, queue: queue, decoder: decoder) { response in
        completion(response.result)
      }
  }
}

// MARK: - Subreddit + PostProvider

extension Subreddit: PostProvider {
  public var isNsfw: Bool {
    over18 ?? false
  }

  public func posts(sortBy sort: PostSort, location: Location?, topInterval: TopInterval?,
                    parameters: ListingParameters, queue: DispatchQueue = .main,
                    completion: @escaping (Result<Listing, AFError>) -> Void)
    -> DataRequest {
    Illithid.shared.fetchPosts(for: self, sortBy: sort, location: location,
                               topInterval: topInterval, params: parameters, queue: queue) { result in
      completion(result)
    }
  }
}

public extension Subreddit {
  /// Fetches `Posts` on a `Subreddit`
  func posts(sortBy postSort: PostSort, location: Location? = nil, topInterval: TopInterval? = nil,
             params: ListingParameters = .init(), queue: DispatchQueue = .main,
             completion: @escaping (Result<Listing, AFError>) -> Void) {
    Illithid.shared.fetchPosts(for: self, sortBy: postSort, location: location, topInterval: topInterval,
                               params: params, queue: queue, completion: completion)
  }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Subreddit {
  /// Loads a specific `Subreddit` by its `Fullname`
  static func fetch(name: Fullname, queue: DispatchQueue = .main) -> AnyPublisher<Subreddit, AFError> {
    Illithid.shared.info(name: name, queue: queue)
      .compactMap { listing in
        listing.subreddits.last
      }.eraseToAnyPublisher()
  }
}

public extension Subreddit {
  /// Loads a specific `Subreddit` by its `Fullname`
  static func fetch(name: Fullname, queue: DispatchQueue = .main,
                    completion: @escaping (Result<Subreddit, Error>) -> Void) {
    Illithid.shared.info(name: name, queue: queue) { result in
      switch result {
      case let .success(listing):
        guard let subreddit = listing.subreddits.last else {
          completion(.failure(Illithid.NotFound(lookingFor: name)))
          return
        }
        completion(.success(subreddit))
      case let .failure(error):
        completion(.failure(error))
      }
    }
  }

  /// Load a `Subreddit` by its `displayName`
  static func fetch(displayName: String, queue: DispatchQueue = .main,
                    completion: @escaping (Result<Subreddit, AFError>) -> Void) {
    let aboutUrl = URL(string: "/r/\(displayName)/about", relativeTo: Illithid.shared.baseURL)!
    Illithid.shared.session.request(aboutUrl, method: .get)
      .validate()
      .responseDecodable(of: Subreddit.self, queue: queue, decoder: Illithid.shared.decoder) { response in
        completion(response.result)
      }
  }
}

// MARK: Subscription

public extension Subreddit {
  func subscribe(queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) {
    Illithid.shared.changeSubscription(of: self, action: .subscribe, queue: queue, completion: completion)
  }

  func unsubscribe(queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) {
    Illithid.shared.changeSubscription(of: self, action: .unsubscribe, queue: queue, completion: completion)
  }
}

// MARK: Moderator fetching

public extension Illithid {
  func moderatorsOf(displayName name: String, queue: DispatchQueue = .main,
                    completion: @escaping (Result<[Moderator], AFError>) -> Void)
    -> DataRequest {
    session.request(SubredditRouter.moderators(subredditDisplayName: name), method: .get)
      .validate()
      .responseDecodable(of: UserList.self, queue: queue, decoder: decoder) { response in
        switch response.result {
        case let .success(list):
          completion(.success(list.users))
        case let .failure(error):
          self.logger.errorMessage("Failed loading moderators of \(name): \(error)")
          completion(.failure(error))
        }
      }
  }

  func moderatorsOf(subreddit: Subreddit, queue: DispatchQueue = .main,
                    completion: @escaping (Result<[Moderator], AFError>) -> Void)
    -> DataRequest {
    moderatorsOf(displayName: subreddit.displayName, queue: queue, completion: completion)
  }
}

public extension Subreddit {
  func moderators(queue: DispatchQueue = .main,
                  completion: @escaping (Result<[Moderator], AFError>) -> Void)
    -> DataRequest {
    Illithid.shared.moderatorsOf(subreddit: self, queue: queue, completion: completion)
  }
}

// MARK: - Subreddit + PostAcceptor

extension Subreddit: PostAcceptor {
  public var uploadTarget: String {
    displayName
  }

  public var permitsSelfPosts: Bool {
    guard let type = submissionType else { return false }
    return type != .link
  }

  public var permitsLinkPosts: Bool {
    guard let type = submissionType else { return false }
    return type != .`self`
  }

  public var permitsImagePosts: Bool {
    guard let type = submissionType else { return false }
    return type != .`self` && allowImages!
  }

  public var permitsGalleryPosts: Bool {
    guard let type = submissionType else { return false }
    return type != .`self` && allowGalleries!
  }

  public var permitsVideoPosts: Bool {
    guard let type = submissionType else { return false }
    return type != .`self` && allowVideos
  }

  public var permitsGifPosts: Bool {
    guard let type = submissionType else { return false }
    return type != .`self` && allowVideogifs
  }

  public var permitsPollPosts: Bool {
    allowPolls ?? false
  }
}
