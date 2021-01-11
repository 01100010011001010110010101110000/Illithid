//
//  PostAcceptor.swift
//  
//
//  Created by Tyler Gregory on 1/7/21.
//

#if canImport(Combine)
import Combine
#endif
import Foundation

import Alamofire

public protocol PostAcceptor {
  /// The name of the target subreddit when submitting the post to the Reddit API (i.e. the value of the `sr` field)
  var uploadTarget: String { get }

  func submitLinkPost(title: String, isNsfw: Bool, isSpoiler: Bool,
                      collectionId: UUID?, eventStart: Date?, eventEnd: Date?, eventTimeZone: String?,
                      flairId: String?, flairText: String?, resubmit: Bool,
                      notifyOfReplies subscribe: Bool, linkTo: URL, queue: DispatchQueue,
                      completion: @escaping (Result<NewPostResponse, AFError>) -> Void)
  -> DataRequest

  func submitSelfPost(title: String, isNsfw: Bool, isSpoiler: Bool,
                      collectionId: UUID?, eventStart: Date?, eventEnd: Date?, eventTimeZone: String?,
                      flairId: String?, flairText: String?, notifyOfReplies subscribe: Bool,
                      markdown text: String, queue: DispatchQueue,
                      completion: @escaping (Result<NewPostResponse, AFError>) -> Void)
  -> DataRequest

  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func submitLinkPost(title: String, isNsfw: Bool, isSpoiler: Bool,
                      collectionId: UUID?, eventStart: Date?, eventEnd: Date?, eventTimeZone: String?,
                      flairId: String?, flairText: String?, resubmit: Bool,
                      notifyOfReplies subscribe: Bool, linkTo: URL, queue: DispatchQueue)
  -> AnyPublisher<NewPostResponse, AFError>

  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func submitSelfPost(title: String, isNsfw: Bool, isSpoiler: Bool,
                      collectionId: UUID?, eventStart: Date?, eventEnd: Date?, eventTimeZone: String?,
                      flairId: String?, flairText: String?, notifyOfReplies subscribe: Bool,
                      markdown text: String, queue: DispatchQueue)
  -> AnyPublisher<NewPostResponse, AFError>
}

public extension PostAcceptor {

  @discardableResult
  func submitLinkPost(title: String, isNsfw: Bool = false, isSpoiler: Bool = false,
                      collectionId: UUID? = nil, eventStart: Date? = nil, eventEnd: Date? = nil, eventTimeZone: String? = nil,
                      flairId: String? = nil, flairText: String? = nil, resubmit: Bool = false,
                      notifyOfReplies subscribe: Bool = true, linkTo: URL, queue: DispatchQueue = .main,
                      completion: @escaping (Result<NewPostResponse, AFError>) -> Void)
  -> DataRequest {
    Illithid.shared.submit(kind: .link, subredditDisplayName: uploadTarget, title: title, isNsfw: isNsfw, isSpoiler: isSpoiler,
           collectionId: collectionId, eventStart: eventStart, eventEnd: eventEnd, eventTimeZone: eventTimeZone,
           flairId: flairId, flairText: flairText, resubmit: resubmit, notifyOfReplies: subscribe,
           linkTo: linkTo, queue: queue, completion: completion)
  }


  @discardableResult
  func submitSelfPost(title: String, isNsfw: Bool = false, isSpoiler: Bool = false,
                      collectionId: UUID? = nil, eventStart: Date? = nil, eventEnd: Date? = nil, eventTimeZone: String? = nil,
                      flairId: String? = nil, flairText: String? = nil, notifyOfReplies subscribe: Bool = true,
                      markdown text: String, queue: DispatchQueue = .main,
                      completion: @escaping (Result<NewPostResponse, AFError>) -> Void)
  -> DataRequest {
    Illithid.shared.submit(kind: .`self`, subredditDisplayName: uploadTarget, title: title, isNsfw: isNsfw, isSpoiler: isSpoiler,
           collectionId: collectionId, eventStart: eventStart, eventEnd: eventEnd, eventTimeZone: eventTimeZone,
           flairId: flairId, flairText: flairText, resubmit: false, notifyOfReplies: subscribe, markdown: text,
           queue: queue, completion: completion)
  }

  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func submitLinkPost(title: String, isNsfw: Bool = false, isSpoiler: Bool = false,
                      collectionId: UUID? = nil, eventStart: Date? = nil, eventEnd: Date? = nil, eventTimeZone: String? = nil,
                      flairId: String? = nil, flairText: String? = nil, resubmit: Bool = false,
                      notifyOfReplies subscribe: Bool = true, linkTo: URL, queue: DispatchQueue = .main)
  -> AnyPublisher<NewPostResponse, AFError> {
    Illithid.shared.submit(kind: .link, subredditDisplayName: uploadTarget, title: title, isNsfw: isNsfw, isSpoiler: isSpoiler,
           collectionId: collectionId, eventStart: eventStart, eventEnd: eventEnd, eventTimeZone: eventTimeZone,
           flairId: flairId, flairText: flairText, resubmit: resubmit, notifyOfReplies: subscribe,
           linkTo: linkTo, queue: queue)
  }

  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func submitSelfPost(title: String, isNsfw: Bool = false, isSpoiler: Bool = false,
                      collectionId: UUID? = nil, eventStart: Date? = nil, eventEnd: Date? = nil, eventTimeZone: String? = nil,
                      flairId: String? = nil, flairText: String? = nil, notifyOfReplies subscribe: Bool = true,
                      markdown text: String, queue: DispatchQueue = .main)
  -> AnyPublisher<NewPostResponse, AFError> {
    Illithid.shared.submit(kind: .`self`, subredditDisplayName: uploadTarget, title: title, isNsfw: isNsfw, isSpoiler: isSpoiler,
           collectionId: collectionId, eventStart: eventStart, eventEnd: eventEnd, eventTimeZone: eventTimeZone,
           flairId: flairId, flairText: flairText, resubmit: false, notifyOfReplies: subscribe, markdown: text,
           queue: queue)
  }
}
