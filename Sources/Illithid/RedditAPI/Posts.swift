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

// MARK: - PostRouter

enum PostRouter: URLRequestConvertible {
  case postsFromPostProvider(provider: PostProvider, sort: PostSort, topInterval: TopInterval?, location: Location?, listing: ListingParameters)
  case submit(parameters: BaseNewPostParameters)
  case submitGallery(parameters: GalleryPostParameters)
  case submitPoll(parameters: PollPostParameters)
  case storeVisit(fullnames: [Fullname])

  // MARK: Internal

  /// The AF redirector to use when fetching posts from `FrontPage` objects.
  /// This adds the contents of the `Authorization` header to the redirected request if we are still talking to Reddit's authenticated endpoint.
  ///
  /// - Remark: This is necessary to handle `FrontPage.random`, because Reddit handles that endpoint by replying with an HTTP 302 to a random subreddit,
  /// and without the `Authorization` header, we receive a 403 when following the redirect.
  static let frontPageRedirector = Redirector(behavior: .modify({ task, request, _ -> URLRequest? in
    let authzHeaderName = "Authorization"
    if request.url?.host == "oauth.reddit.com",
       let authzHeader = task.originalRequest?.headers[authzHeaderName] {
      var newRequest = request
      newRequest.setValue(authzHeader, forHTTPHeaderField: authzHeaderName)
      return newRequest
    }
    return request
  }))

  func asURLRequest() throws -> URLRequest {
    switch self {
    case let .postsFromPostProvider(provider, sort, topInterval,
                                    location, params):
      return try constructPostsFetchRequest(
        url: URL(string: provider.postsPath, relativeTo: Illithid.shared.baseURL)!.appendingPathComponent(sort.rawValue),
        topInterval: topInterval, location: location, listingParameters: params
      )
    case let .submit(parameters):
      let request = try URLRequest(url: URL(string: "/api/submit", relativeTo: baseUrl)!, method: .post)
      return try URLEncoding(boolEncoding: .numeric).encode(request, with: parameters.toParameters())
    case let .submitGallery(parameters):
      let request = try URLRequest(url: URL(string: "/api/submit_gallery_post", relativeTo: baseUrl)!, method: .post)
      return try JSONEncoding.default.encode(request, with: parameters.toParameters())
    case let .submitPoll(parameters):
      let request = try URLRequest(url: URL(string: "/api/submit_poll_post", relativeTo: baseUrl)!, method: .post)
      return try JSONEncoding.default.encode(request, with: parameters.toParameters())
    case let .storeVisit(names):
      let request = try URLRequest(url: URL(string: "/api/store_visits", relativeTo: baseUrl)!, method: .post)
      let parameters: Parameters = [
        "links": names.joined(separator: ","),
      ]
      return try URLEncoding(boolEncoding: .numeric).encode(request, with: parameters)
    }
  }

  // MARK: Private

  private var baseUrl: URL {
    Illithid.shared.baseURL
  }

  private func constructPostsFetchRequest(url: URL, topInterval: TopInterval?,
                                          location: Location?, listingParameters: ListingParameters)
    throws -> URLRequest {
    let request = try URLRequest(url: url, method: .get)
    var parameters = listingParameters.toParameters()
    if let interval = topInterval { parameters["t"] = interval }
    if let location = location { parameters["g"] = location }
    return try URLEncoding(boolEncoding: .numeric).encode(request, with: parameters)
  }
}

public extension Illithid {
  // MARK: Fetch Posts

  @discardableResult
  func fetchPosts<Provider: PostProvider>(for provider: Provider, sortBy postSort: PostSort,
                                          location: Location? = nil, topInterval: TopInterval? = nil,
                                          params: ListingParameters = .init(), queue: DispatchQueue = .main,
                                          completion: @escaping (Result<Listing, AFError>) -> Void)
    -> DataRequest {
    let request = PostRouter.postsFromPostProvider(provider: provider, sort: postSort,
                                                   topInterval: topInterval, location: location, listing: params)

    return readListing(request: request, queue: queue) { result in
      completion(result)
    }
  }

  // MARK: Submit Posts

  @discardableResult
  func submit(parameters: BaseNewPostParameters, queue: DispatchQueue = .main,
              completion: @escaping (Result<NewPostResponse, AFError>) -> Void)
    -> DataRequest {
    session.request(PostRouter.submit(parameters: parameters))
      .validate()
      .responseDecodable(of: NewPostResponse.self, queue: queue, decoder: decoder) { response in
        completion(response.result)
      }
  }

  @discardableResult
  func submitGalleryPost(parameters: GalleryPostParameters, queue: DispatchQueue = .main,
                         completion: @escaping (Result<NewPostResponse, AFError>) -> Void)
    -> DataRequest {
    session.request(PostRouter.submitGallery(parameters: parameters))
      .validate()
      .responseDecodable(of: NewPostResponse.self, queue: queue, decoder: decoder) { response in
        completion(response.result)
      }
  }

  @discardableResult
  func submitPollPost(parameters: PollPostParameters, queue: DispatchQueue = .main,
                      completion: @escaping (Result<NewPostResponse, AFError>) -> Void)
    -> DataRequest {
    session.request(PostRouter.submitPoll(parameters: parameters))
      .validate()
      .responseDecodable(of: NewPostResponse.self, queue: queue, decoder: decoder) { response in
        completion(response.result)
      }
  }

  @discardableResult
  func submitLinkPost(parameters: LinkPostParameters, queue: DispatchQueue = .main,
                      completion: @escaping (Result<NewPostResponse, AFError>) -> Void)
    -> DataRequest {
    submit(parameters: parameters, queue: queue, completion: completion)
  }

  @discardableResult
  func submitSelfPost(parameters: SelfPostParameters, queue: DispatchQueue = .main,
                      completion: @escaping (Result<NewPostResponse, AFError>) -> Void)
    -> DataRequest {
    submit(parameters: parameters, queue: queue, completion: completion)
  }

  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func submit(parameters: BaseNewPostParameters, validateOnSubmit _: Bool = true, queue: DispatchQueue = .main)
    -> AnyPublisher<NewPostResponse, AFError> {
    session.request(PostRouter.submit(parameters: parameters))
      .validate()
      .publishDecodable(type: NewPostResponse.self, queue: queue, decoder: decoder)
      .value()
  }

  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func submitGalleryPost(parameters: GalleryPostParameters, queue: DispatchQueue = .main)
    -> AnyPublisher<NewPostResponse, AFError> {
    session.request(PostRouter.submitGallery(parameters: parameters))
      .validate()
      .publishDecodable(type: NewPostResponse.self, queue: queue, decoder: decoder)
      .value()
  }

  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func submitPollPost(parameters: PollPostParameters, queue: DispatchQueue = .main)
    -> AnyPublisher<NewPostResponse, AFError> {
    session.request(PostRouter.submitPoll(parameters: parameters))
      .validate()
      .publishDecodable(type: NewPostResponse.self, queue: queue, decoder: decoder)
      .value()
  }

  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func submitLinkPost(parameters: LinkPostParameters, queue: DispatchQueue = .main)
    -> AnyPublisher<NewPostResponse, AFError> {
    submit(parameters: parameters, queue: queue)
  }

  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func submitSelfPost(parameters: SelfPostParameters, queue: DispatchQueue = .main)
    -> AnyPublisher<NewPostResponse, AFError> {
    submit(parameters: parameters, queue: queue)
  }

  /// Marks `Posts` as visited
  ///
  /// - Parameters:
  ///   - fullnames: An array of `Post` `Fullnames` to mark as visited
  ///   - queue: The `DispatchQueue` on which the completion handler is called
  ///   - completion: A closure to execute when the request has finished
  /// - Returns: The `DataRequest` which holds the request
  /// - Note: The current user *must* be a Reddit premium subscriber for this to work
  @discardableResult
  func storeVisits(to fullnames: [Fullname], queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void)
    -> DataRequest {
    session.request(PostRouter.storeVisit(fullnames: fullnames))
      .validate()
      .responseData(queue: queue) { completion($0.result) }
  }

  /// Marks `Posts` as visited
  ///
  /// - Parameters:
  ///   - fullnames: An array of `Post` `Fullnames` to mark as visited
  ///   - queue: The `DispatchQueue` on which the `DataResponse` is published
  /// - Returns: The `AnyPublisher` which holds the request
  /// - Note: The current user *must* be a Reddit premium subscriber for this to work
  @discardableResult
  func storeVisits(to fullnames: [Fullname], queue: DispatchQueue = .main)
    -> AnyPublisher<Data, AFError> {
    session.request(PostRouter.storeVisit(fullnames: fullnames))
      .validate()
      .publishData(queue: queue)
      .value()
  }

  /// Marks `Posts` as visited
  ///
  /// - Parameters:
  ///   - fullnames: An array of `Post` `Fullnames` to mark as visited
  ///   - automaticallyCancelling: If `true`, automatically cancels the network request when the `Task` is cancelled
  /// - Returns: The `DataTask` which holds the request
  /// - Note: The current user *must* be a Reddit premium subscriber for this to work
  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func storeVisits(to fullnames: [Fullname], automaticallyCancelling: Bool = false)
    -> DataTask<Data> {
    session.request(PostRouter.storeVisit(fullnames: fullnames))
      .validate()
      .serializingData(automaticallyCancelling: automaticallyCancelling)
  }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Post {
  static func fetch(name: Fullname, queue: DispatchQueue = .main) -> AnyPublisher<Post, AFError> {
    Illithid.shared.info(name: name, queue: queue)
      .compactMap { listing in
        listing.posts.last
      }.eraseToAnyPublisher()
  }

  static func fetch(name: Fullname, automaticallyCancelling: Bool = false) async throws -> Post {
    let result = await Illithid.shared.info(name: name, automaticallyCancelling: automaticallyCancelling).result
    switch result {
    case let .success(listing):
      if let post = listing.posts.first { return post }
      else { throw Illithid.NotFound(lookingFor: name) }
    case let .failure(error):
      throw error
    }
  }
}

public extension Post {
  @discardableResult
  static func fetch(name: Fullname, queue: DispatchQueue = .main, completion: @escaping (Result<Post, Error>) -> Void) -> DataRequest {
    Illithid.shared.info(name: name, queue: queue) { result in
      switch result {
      case let .success(listing):
        guard let post = listing.posts.last else {
          completion(.failure(Illithid.NotFound(lookingFor: name)))
          return
        }
        completion(.success(post))
      case let .failure(error):
        completion(.failure(error))
      }
    }
  }

  /// Fetches `Posts` from `r/all`, a metasubreddit which contains posts from all `Subreddits`
  /// - Parameters:
  ///   - postSort: The `PostSort` by which to sort the `Posts`
  ///   - location:
  ///   - topInterval: The interval in which to search for top `Posts` when `postSort` is `.top`
  ///   - params: Default parameters applicable to every `Listing` returning endpoint on Reddit
  ///   - queue: The `DispatchQueue` on which the completion handler will be called
  ///   - completion: The callback function to execute when we get the `Post` `Listing` back from Reddit
  @discardableResult
  static func all(sortBy postSort: PostSort, location: Location? = nil, topInterval: TopInterval? = nil,
                  params: ListingParameters = .init(), queue: DispatchQueue = .main, completion: @escaping (Result<Listing, AFError>) -> Void)
    -> DataRequest {
    Illithid.shared.fetchPosts(for: FrontPage.all, sortBy: postSort, location: location, topInterval: topInterval,
                               params: params, queue: queue, completion: completion)
  }

  /// Fetches `Posts` from `r/popular`, which is a subset of the posts from `r/all` and is the default front page for non-authenticated users
  /// The announcement of `r/popular` and further details may be found [here](https://www.reddit.com/r/announcements/comments/5u9pl5)
  /// - Parameters:
  ///   - postSort: The `PostSort` by which to sort the `Posts`
  ///   - location:
  ///   - topInterval: The interval in which to search for top `Posts` when `postSort` is `.top`
  ///   - params: Default parameters applicable to every `Listing` returning endpoint on Reddit
  ///   - queue: The `DispatchQueue` on which the completion handler will be called
  ///   - completion: The callback function to execute when we get the `Post` `Listing` back from Reddit
  @discardableResult
  static func popular(sortBy postSort: PostSort, location: Location? = nil, topInterval: TopInterval? = nil,
                      params: ListingParameters = .init(), queue: DispatchQueue = .main, completion: @escaping (Result<Listing, AFError>) -> Void)
    -> DataRequest {
    Illithid.shared.fetchPosts(for: FrontPage.popular, sortBy: postSort, location: location, topInterval: topInterval,
                               params: params, queue: queue, completion: completion)
  }

  /// Fetches `Posts` from a random `Subreddit`
  /// - Parameters:
  ///   - postSort: The `PostSort` by which to sort the `Posts`
  ///   - location:
  ///   - topInterval: The interval in which to search for top `Posts` when `postSort` is `.top`
  ///   - params: Default parameters applicable to every `Listing` returning endpoint on Reddit
  ///   - queue: The `DispatchQueue` on which the completion handler will be called
  ///   - completion: The callback function to execute when we get the `Post` `Listing` back from Reddit
  @discardableResult
  static func random(sortBy postSort: PostSort, location: Location? = nil, topInterval: TopInterval? = nil,
                     params: ListingParameters = .init(), queue: DispatchQueue = .main, completion: @escaping (Result<Listing, AFError>) -> Void)
    -> DataRequest {
    Illithid.shared.fetchPosts(for: FrontPage.random, sortBy: postSort, location: location, topInterval: topInterval,
                               params: params, queue: queue, completion: completion)
  }
}

public extension Post {
  func isModPost(queue: DispatchQueue = .main, completion: @escaping (Result<Bool, AFError>) -> Void) -> DataRequest {
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

public extension Post {
  /// Marks the `Post` as visited
  ///
  /// - Parameters:
  ///   - queue: The `DispatchQueue` on which `completion` will be called
  ///   - completion: A closure to execute when the request has finished
  /// - Returns: The `DataRequest` which holds the request
  /// - Note: The current user *must* be a Reddit premium subscriber for this to work
  func visit(queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void)
    -> DataRequest {
    Illithid.shared.storeVisits(to: [name], queue: queue, completion: completion)
  }

  /// Marks the `Post` as visited
  ///
  /// - Parameters:
  ///   - automaticallyCancelling: If `true`, automatically cancels the network request when the `Task` is cancelled
  /// - Returns: The `DataRequest` which holds the request
  /// - Note: The current user *must* be a Reddit premium subscriber for this to work
  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func visit(automaticallyCancelling: Bool = false)
    -> DataTask<Data> {
    Illithid.shared.storeVisits(to: [name], automaticallyCancelling: automaticallyCancelling)
  }

  /// Marks the `Post` as visited
  ///
  /// - Parameters:
  ///   - queue: The `DispatchQueue` on which the `DataResponse` will be published
  /// - Returns: The `AnyPublisher` which holds the request
  /// - Note: The current user *must* be a Reddit premium subscriber for this to work
  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func visit(queue: DispatchQueue = .main)
    -> AnyPublisher<Data, AFError> {
    Illithid.shared.storeVisits(to: [name], queue: queue)
  }
}
