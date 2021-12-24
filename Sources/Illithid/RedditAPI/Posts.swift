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

enum PostRouter: URLConvertible {
  case subreddit(displayName: String, sort: PostSort)
  case userMultireddit(username: String, multiName: String, sort: PostSort)
  case frontPage(page: FrontPage, sort: PostSort)
  case submit
  case submitGallery
  case submitPoll

  // MARK: Internal

  /// The AF redirector to use when fetching posts from `FrontPage` objects.
  /// This adds the contents of the `Authorization` header to the redirected request if we are still talking to Reddit's authenticated endpoint.
  ///
  /// - Remark: This is necessary to handle `FrontPage.random`, because Reddit handles that endpoint by replying with an HTTP 302 to a random subreddit,
  /// and without the `Authorization` header, we receive a 403 when following the redirect.
  static let frontPageRedirector = Redirector(behavior: .modify({ task, request, _ -> URLRequest? in
    if request.url?.host == "oauth.reddit.com",
       let authzHeader = task.originalRequest?.headers["Authorization"] {
      var newRequest = request
      newRequest.setValue(authzHeader, forHTTPHeaderField: "Authorization")
      return newRequest
    }
    return request
  }))

  func asURL() throws -> URL {
    switch self {
    case let .subreddit(displayName, sort):
      return URL(string: "/r/\(displayName)/\(sort)", relativeTo: baseUrl)!
    case let .userMultireddit(username, multiName, sort):
      return URL(string: "/user/\(username)/m/\(multiName)/\(sort)", relativeTo: baseUrl)!
    case let .frontPage(page, sort):
      return try page.asURL().appendingPathComponent("\(sort)")
    case .submit:
      return URL(string: "/api/submit", relativeTo: baseUrl)!
    case .submitGallery:
      return URL(string: "/api/submit_gallery_post", relativeTo: baseUrl)!
    case .submitPoll:
      return URL(string: "/api/submit_poll_post", relativeTo: baseUrl)!
    }
  }

  // MARK: Private

  private var baseUrl: URL {
    Illithid.shared.baseURL
  }
}

public extension Illithid {
  // MARK: Fetch Posts

  @discardableResult
  func fetchPosts(for subreddit: Subreddit, sortBy postSort: PostSort,
                  location: Location? = nil, topInterval: TopInterval? = nil,
                  params: ListingParameters = .init(), queue: DispatchQueue = .main,
                  completion: @escaping (Result<Listing, AFError>) -> Void)
    -> DataRequest {
    let url = PostRouter.subreddit(displayName: subreddit.displayName, sort: postSort)
    var parameters = params.toParameters()
    if let interval = topInterval { parameters["t"] = interval }
    if let location = location { parameters["g"] = location }

    return readListing(url: url, queryParameters: parameters, queue: queue) { result in
      completion(result)
    }
  }

  @discardableResult
  func fetchPosts(for multireddit: Multireddit, sortBy postSort: PostSort,
                  location: Location? = nil, topInterval: TopInterval? = nil,
                  params: ListingParameters = .init(), queue: DispatchQueue = .main,
                  completion: @escaping (Result<Listing, AFError>) -> Void)
    -> DataRequest {
    let url = PostRouter.userMultireddit(username: multireddit.owner, multiName: multireddit.name, sort: postSort)
    var parameters = params.toParameters()
    if let interval = topInterval { parameters["t"] = interval }
    if let location = location { parameters["g"] = location }

    return readListing(url: url, queryParameters: parameters, queue: queue) { result in
      completion(result)
    }
  }

  @discardableResult
  func fetchPosts(for frontPage: FrontPage, sortBy postSort: PostSort,
                  location: Location? = nil, topInterval: TopInterval? = nil,
                  params: ListingParameters = .init(), queue: DispatchQueue = .main,
                  completion: @escaping (Result<Listing, AFError>) -> Void)
    -> DataRequest {
    let url = PostRouter.frontPage(page: frontPage, sort: postSort)
    var parameters = params.toParameters()

    if let interval = topInterval { parameters["t"] = interval }
    if let location = location { parameters["g"] = location }

    return readListing(url: url, queryParameters: parameters, redirectHandler: PostRouter.frontPageRedirector, queue: queue) { result in
      completion(result)
    }
  }

  // MARK: Submit Posts

  @discardableResult
  func submit(kind: NewPostType, subredditDisplayName subreddit: String, title: String, isNsfw: Bool = false, isSpoiler: Bool = false,
              collectionId: UUID? = nil, eventStart: Date? = nil, eventEnd: Date? = nil, eventTimeZone: String? = nil,
              flairId: String? = nil, flairText: String? = nil, resubmit: Bool = false,
              notifyOfReplies subscribe: Bool = true, markdown text: String? = nil,
              linkTo: URL? = nil, videoPosterUrl: URL? = nil, validateOnSubmit: Bool = true, queue: DispatchQueue = .main,
              completion: @escaping (Result<NewPostResponse, AFError>) -> Void)
    -> DataRequest {
    let encoding = URLEncoding(boolEncoding: .numeric)
    let tempParameters: [String: Any?] = [
      "api_type": "json",
      "kind": kind,
      "sr": subreddit,
      "title": title,
      "nsfw": isNsfw,
      "spoiler": isSpoiler,
      "collection_id": collectionId?.uuidString,
      "event_start": eventStart == nil ? nil : redditEventTimeFormatter.string(from: eventStart!),
      "event_end": eventStart == nil ? nil : redditEventTimeFormatter.string(from: eventEnd!),
      "event_tz": eventTimeZone,
      "flair_id": flairId,
      "flair_text": flairText,
      "resubmit": resubmit,
      "sendreplies": subscribe,
      "text": text,
      "url": linkTo?.absoluteString,
      "video_poster_url": videoPosterUrl?.absoluteString,
      "validate_on_submit": validateOnSubmit,
    ]
    let parameters: Parameters = tempParameters.compactMapValues { $0 }

    return session.request(PostRouter.submit, method: .post, parameters: parameters, encoding: encoding)
      .validate()
      .responseDecodable(of: NewPostResponse.self, queue: queue, decoder: decoder) { response in
        completion(response.result)
      }
  }

  @discardableResult
  func submitGalleryPost(subredditDisplayName subreddit: String, title: String, isNsfw: Bool = false, isSpoiler: Bool = false,
                         collectionId: UUID? = nil, eventStart: Date? = nil, eventEnd: Date? = nil, eventTimeZone: String? = nil,
                         flairId: String? = nil, flairText: String? = nil, notifyOfReplies subscribe: Bool = true,
                         galleryItems: [GalleryDataItem], validateOnSubmit: Bool = true, queue: DispatchQueue = .main,
                         completion: @escaping (Result<NewPostResponse, AFError>) -> Void)
    -> DataRequest {
    let encoding = JSONEncoding.default
    let tempParameters: [String: Any?] = [
      "api_type": "json",
      "items": galleryItems.map { $0.asDictionary() },
      "sr": subreddit,
      "title": title,
      "nsfw": isNsfw,
      "spoiler": isSpoiler,
      "collection_id": collectionId?.uuidString,
      "event_start": eventStart == nil ? nil : redditEventTimeFormatter.string(from: eventStart!),
      "event_end": eventStart == nil ? nil : redditEventTimeFormatter.string(from: eventEnd!),
      "event_tz": eventTimeZone,
      "flair_id": flairId,
      "flair_text": flairText,
      "sendreplies": subscribe,
      "validate_on_submit": validateOnSubmit,
    ]
    let parameters: Parameters = tempParameters.compactMapValues { $0 }

    return session.request(PostRouter.submitGallery, method: .post, parameters: parameters, encoding: encoding)
      .validate()
      .responseDecodable(of: NewPostResponse.self, queue: queue, decoder: decoder) { response in
        completion(response.result)
      }
  }

  @discardableResult
  func submitLinkPost(subredditDisplayName subreddit: String, title: String, isNsfw: Bool = false, isSpoiler: Bool = false,
                      collectionId: UUID? = nil, eventStart: Date? = nil, eventEnd: Date? = nil, eventTimeZone: String? = nil,
                      flairId: String? = nil, flairText: String? = nil, resubmit: Bool = false,
                      notifyOfReplies subscribe: Bool = true, linkTo: URL, queue: DispatchQueue = .main,
                      completion: @escaping (Result<NewPostResponse, AFError>) -> Void)
    -> DataRequest {
    submit(kind: .link, subredditDisplayName: subreddit, title: title, isNsfw: isNsfw, isSpoiler: isSpoiler,
           collectionId: collectionId, eventStart: eventStart, eventEnd: eventEnd, eventTimeZone: eventTimeZone,
           flairId: flairId, flairText: flairText, resubmit: resubmit, notifyOfReplies: subscribe,
           linkTo: linkTo, queue: queue, completion: completion)
  }

  @discardableResult
  func submitSelfPost(subredditDisplayName subreddit: String, title: String, isNsfw: Bool = false, isSpoiler: Bool = false,
                      collectionId: UUID? = nil, eventStart: Date? = nil, eventEnd: Date? = nil, eventTimeZone: String? = nil,
                      flairId: String? = nil, flairText: String? = nil, notifyOfReplies subscribe: Bool = true,
                      markdown text: String, queue: DispatchQueue = .main,
                      completion: @escaping (Result<NewPostResponse, AFError>) -> Void)
    -> DataRequest {
    submit(kind: .`self`, subredditDisplayName: subreddit, title: title, isNsfw: isNsfw, isSpoiler: isSpoiler,
           collectionId: collectionId, eventStart: eventStart, eventEnd: eventEnd, eventTimeZone: eventTimeZone,
           flairId: flairId, flairText: flairText, resubmit: false, notifyOfReplies: subscribe, markdown: text,
           queue: queue, completion: completion)
  }

  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func submit(kind: NewPostType, subredditDisplayName subreddit: String, title: String, isNsfw: Bool = false, isSpoiler: Bool = false,
              collectionId: UUID? = nil, eventStart: Date? = nil, eventEnd: Date? = nil, eventTimeZone: String? = nil,
              flairId: String? = nil, flairText: String? = nil, resubmit: Bool = false,
              notifyOfReplies subscribe: Bool = true, markdown text: String? = nil,
              linkTo: URL? = nil, videoPosterUrl: URL? = nil, validateOnSubmit: Bool = true, queue: DispatchQueue = .main)
    -> AnyPublisher<NewPostResponse, AFError> {
    let encoding = URLEncoding(boolEncoding: .numeric)
    let dateFormatter = ISO8601DateFormatter()
    let tempParameters: [String: Any?] = [
      "api_type": "json",
      "kind": kind,
      "sr": subreddit,
      "title": title,
      "nsfw": isNsfw,
      "spoiler": isSpoiler,
      "collection_id": collectionId?.uuidString,
      "event_start": eventStart == nil ? nil : dateFormatter.string(from: eventStart!),
      "event_end": eventStart == nil ? nil : dateFormatter.string(from: eventEnd!),
      "event_tz": eventTimeZone,
      "flair_id": flairId,
      "flair_text": flairText,
      "resubmit": resubmit,
      "sendreplies": subscribe,
      "text": text,
      "url": linkTo?.absoluteString,
      "video_poster_url": videoPosterUrl?.absoluteString,
      "validate_on_submit": validateOnSubmit,
    ]
    let parameters: Parameters = tempParameters.compactMapValues { $0 }

    return session.request(PostRouter.submit, method: .post, parameters: parameters, encoding: encoding)
      .validate()
      .publishDecodable(type: NewPostResponse.self, queue: queue, decoder: decoder)
      .value()
  }

  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func submitGalleryPost(subredditDisplayName subreddit: String, title: String, isNsfw: Bool = false, isSpoiler: Bool = false,
                         collectionId: UUID? = nil, eventStart: Date? = nil, eventEnd: Date? = nil, eventTimeZone: String? = nil,
                         flairId: String? = nil, flairText: String? = nil, notifyOfReplies subscribe: Bool = true,
                         galleryItems: [GalleryDataItem], validateOnSubmit: Bool = true, queue: DispatchQueue = .main)
    -> AnyPublisher<NewPostResponse, AFError> {
    let encoding = JSONEncoding.default
    let tempParameters: [String: Any?] = [
      "api_type": "json",
      "items": galleryItems.map { $0.asDictionary() },
      "sr": subreddit,
      "title": title,
      "nsfw": isNsfw,
      "spoiler": isSpoiler,
      "collection_id": collectionId?.uuidString,
      "event_start": eventStart == nil ? nil : redditEventTimeFormatter.string(from: eventStart!),
      "event_end": eventStart == nil ? nil : redditEventTimeFormatter.string(from: eventEnd!),
      "event_tz": eventTimeZone,
      "flair_id": flairId,
      "flair_text": flairText,
      "sendreplies": subscribe,
      "validate_on_submit": validateOnSubmit,
    ]
    let parameters: Parameters = tempParameters.compactMapValues { $0 }

    return session.request(PostRouter.submitGallery, method: .post, parameters: parameters, encoding: encoding)
      .validate()
      .publishDecodable(type: NewPostResponse.self, queue: queue, decoder: decoder)
      .value()
  }

  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func submitLinkPost(subredditDisplayName subreddit: String, title: String, isNsfw: Bool = false, isSpoiler: Bool = false,
                      collectionId: UUID? = nil, eventStart: Date? = nil, eventEnd: Date? = nil, eventTimeZone: String? = nil,
                      flairId: String? = nil, flairText: String? = nil, resubmit: Bool = false,
                      notifyOfReplies subscribe: Bool = true, linkTo: URL, queue: DispatchQueue = .main)
    -> AnyPublisher<NewPostResponse, AFError> {
    submit(kind: .link, subredditDisplayName: subreddit, title: title, isNsfw: isNsfw, isSpoiler: isSpoiler,
           collectionId: collectionId, eventStart: eventStart, eventEnd: eventEnd, eventTimeZone: eventTimeZone,
           flairId: flairId, flairText: flairText, resubmit: resubmit, notifyOfReplies: subscribe,
           linkTo: linkTo, queue: queue)
  }

  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func submitSelfPost(subredditDisplayName subreddit: String, title: String, isNsfw: Bool = false, isSpoiler: Bool = false,
                      collectionId: UUID? = nil, eventStart: Date? = nil, eventEnd: Date? = nil, eventTimeZone: String? = nil,
                      flairId: String? = nil, flairText: String? = nil, notifyOfReplies subscribe: Bool = true,
                      markdown text: String, queue: DispatchQueue = .main)
    -> AnyPublisher<NewPostResponse, AFError> {
    submit(kind: .`self`, subredditDisplayName: subreddit, title: title, isNsfw: isNsfw, isSpoiler: isSpoiler,
           collectionId: collectionId, eventStart: eventStart, eventEnd: eventEnd, eventTimeZone: eventTimeZone,
           flairId: flairId, flairText: flairText, resubmit: false, notifyOfReplies: subscribe, markdown: text,
           queue: queue)
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
}

// MARK: - Post + Votable, Savable

extension Post: Votable, Savable {
  @discardableResult
  public func upvote(queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) -> DataRequest {
    Illithid.shared.vote(fullname: name, direction: .up, queue: queue, completion: completion)
  }

  @discardableResult
  public func upvote() async throws -> Data {
    try await Illithid.shared.vote(post: self, direction: .up, automaticallyCancelling: true).value
  }

  @discardableResult
  public func downvote(queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) -> DataRequest {
    Illithid.shared.vote(fullname: name, direction: .down, queue: queue, completion: completion)
  }

  @discardableResult
  public func downvote() async throws -> Data {
    try await Illithid.shared.vote(post: self, direction: .down, automaticallyCancelling: true).value
  }

  @discardableResult
  public func clearVote(queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) -> DataRequest {
    Illithid.shared.vote(fullname: name, direction: .clear, queue: queue, completion: completion)
  }

  @discardableResult
  public func clearVote() async throws -> Data {
    try await Illithid.shared.vote(post: self, direction: .clear, automaticallyCancelling: true).value
  }

  @discardableResult
  public func save(queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) -> DataRequest {
    Illithid.shared.save(fullname: name, queue: queue, completion: completion)
  }

  @discardableResult
  public func save() async throws -> Data {
    try await Illithid.shared.save(post: self, automaticallyCancelling: true).value
  }

  @discardableResult
  public func unsave(queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) -> DataRequest {
    Illithid.shared.unsave(fullname: name, queue: queue, completion: completion)
  }

  @discardableResult
  public func unsave() async throws -> Data {
    try await Illithid.shared.unsave(fullname: name, automaticallyCancelling: true).value
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
  ///   - completion: The callback function to execute when we get the `Post` `Listing` back from Reddit
  @discardableResult
  static func all(sortBy postSort: PostSort, location: Location? = nil, topInterval: TopInterval? = nil,
                  params: ListingParameters = .init(), queue: DispatchQueue = .main, completion: @escaping (Result<Listing, AFError>) -> Void)
    -> DataRequest {
    Illithid.shared.fetchPosts(for: .all, sortBy: postSort, location: location, topInterval: topInterval,
                               params: params, queue: queue, completion: completion)
  }

  /// Fetches `Posts` from `r/popular`, which is a subset of the posts from `r/all` and is the default front page for non-authenticated users
  /// The announcement of `r/popular` and further details may be found [here](https://www.reddit.com/r/announcements/comments/5u9pl5)
  /// - Parameters:
  ///   - postSort: The `PostSort` by which to sort the `Posts`
  ///   - location:
  ///   - topInterval: The interval in which to search for top `Posts` when `postSort` is `.top`
  ///   - params: Default parameters applicable to every `Listing` returning endpoint on Reddit
  ///   - completion: The callback function to execute when we get the `Post` `Listing` back from Reddit
  @discardableResult
  static func popular(sortBy postSort: PostSort, location: Location? = nil, topInterval: TopInterval? = nil,
                      params: ListingParameters = .init(), queue: DispatchQueue = .main, completion: @escaping (Result<Listing, AFError>) -> Void)
    -> DataRequest {
    Illithid.shared.fetchPosts(for: .popular, sortBy: postSort, location: location, topInterval: topInterval,
                               params: params, queue: queue, completion: completion)
  }

  /// Fetches `Posts` from a random `Subreddit`
  /// - Parameters:
  ///   - postSort: The `PostSort` by which to sort the `Posts`
  ///   - location:
  ///   - topInterval: The interval in which to search for top `Posts` when `postSort` is `.top`
  ///   - params: Default parameters applicable to every `Listing` returning endpoint on Reddit
  ///   - completion: The callback function to execute when we get the `Post` `Listing` back from Reddit
  @discardableResult
  static func random(sortBy postSort: PostSort, location: Location? = nil, topInterval: TopInterval? = nil,
                     params: ListingParameters = .init(), queue: DispatchQueue = .main, completion: @escaping (Result<Listing, AFError>) -> Void)
    -> DataRequest {
    Illithid.shared.fetchPosts(for: .random, sortBy: postSort, location: location, topInterval: topInterval,
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
