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

import Foundation

import Alamofire

// MARK: - ActionRouter

enum ActionRouter: URLRequestConvertible, MirrorableEnum {
  case vote(id: Fullname, dir: VoteDirection)
  case save(id: Fullname)
  case unsave(id: Fullname)
  case changeSubscription(sr: [Subreddit], action: SubscribeAction)

  // MARK: Internal

  var parameters: Parameters {
    switch self {
    case let .vote(id, dir):
      return [
        "id": id,
        "dir": dir.rawValue,
      ]
    case let .changeSubscription(sr, action):
      return [
        "sr": sr.map { $0.name }.joined(separator: ","),
        "action": action.rawValue,
      ]
    default:
      return mirror.parameters
    }
  }

  func asURLRequest() throws -> URLRequest {
    let request = try URLRequest(url: URL(string: path, relativeTo: Illithid.shared.baseURL)!, method: .post)
    return try URLEncoding.httpBody.encode(request, with: parameters)
  }

  // MARK: Private

  private var path: String {
    switch self {
    case .vote:
      return "/api/vote"
    case .save:
      return "/api/save"
    case .unsave:
      return "/api/unsave"
    case .changeSubscription:
      return "/api/subscribe"
    }
  }
}

// MARK: - SubscribeAction

public enum SubscribeAction: String, Codable {
  case subscribe = "sub"
  case unsubscribe = "unsub"
}

public extension Illithid {
  @discardableResult
  func vote(comment: Comment, direction: VoteDirection, queue: DispatchQueue = .main,
            completion: @escaping (Result<Data, AFError>) -> Void)
    -> DataRequest {
    vote(fullname: comment.name, direction: direction, queue: queue, completion: completion)
  }

  func vote(comment: Comment, direction: VoteDirection, automaticallyCancelling: Bool = false)
    -> DataTask<Data> {
    vote(fullname: comment.name, direction: direction, automaticallyCancelling: automaticallyCancelling)
  }

  @discardableResult
  func vote(post: Post, direction: VoteDirection, queue: DispatchQueue = .main,
            completion: @escaping (Result<Data, AFError>) -> Void)
    -> DataRequest {
    vote(fullname: post.name, direction: direction, queue: queue, completion: completion)
  }

  func vote(post: Post, direction: VoteDirection, automaticallyCancelling: Bool = false)
    -> DataTask<Data> {
    vote(fullname: post.name, direction: direction, automaticallyCancelling: automaticallyCancelling)
  }

  @discardableResult
  func vote(fullname: Fullname, direction: VoteDirection, queue: DispatchQueue = .main,
            completion: @escaping (Result<Data, AFError>) -> Void)
    -> DataRequest {
    session.request(ActionRouter.vote(id: fullname, dir: direction))
      .validate()
      .responseData(queue: queue) { response in
        completion(response.result)
      }
  }

  func vote(fullname: Fullname, direction: VoteDirection, automaticallyCancelling: Bool = false)
    -> DataTask<Data> {
    session.request(ActionRouter.vote(id: fullname, dir: direction))
      .validate()
      .serializingData(automaticallyCancelling: automaticallyCancelling)
  }

  @discardableResult
  func save(comment: Comment, queue: DispatchQueue = .main,
            completion: @escaping (Result<Data, AFError>) -> Void)
    -> DataRequest {
    save(fullname: comment.name, queue: queue, completion: completion)
  }

  func save(comment: Comment, automaticallyCancelling: Bool = false)
    -> DataTask<Data> {
    save(fullname: comment.name, automaticallyCancelling: automaticallyCancelling)
  }

  @discardableResult
  func save(post: Post, queue: DispatchQueue = .main,
            completion: @escaping (Result<Data, AFError>) -> Void)
    -> DataRequest {
    save(fullname: post.name, queue: queue, completion: completion)
  }

  func save(post: Post, automaticallyCancelling: Bool = false)
    -> DataTask<Data> {
    save(fullname: post.name, automaticallyCancelling: automaticallyCancelling)
  }

  @discardableResult
  func save(fullname: Fullname, queue: DispatchQueue = .main,
            completion: @escaping (Result<Data, AFError>) -> Void)
    -> DataRequest {
    session.request(ActionRouter.save(id: fullname))
      .validate()
      .responseData(queue: queue) { response in
        completion(response.result)
      }
  }

  func save(fullname: Fullname, automaticallyCancelling: Bool = false)
    -> DataTask<Data> {
    session.request(ActionRouter.save(id: fullname))
      .validate()
      .serializingData(automaticallyCancelling: automaticallyCancelling)
  }

  @discardableResult
  func unsave(comment: Comment, queue: DispatchQueue = .main,
              completion: @escaping (Result<Data, AFError>) -> Void)
    -> DataRequest {
    unsave(fullname: comment.name, queue: queue, completion: completion)
  }

  func unsave(comment: Comment, automaticallyCancelling: Bool = false)
    -> DataTask<Data> {
    unsave(fullname: comment.name, automaticallyCancelling: automaticallyCancelling)
  }

  @discardableResult
  func unsave(post: Post, queue: DispatchQueue = .main,
              completion: @escaping (Result<Data, AFError>) -> Void)
    -> DataRequest {
    unsave(fullname: post.name, queue: queue, completion: completion)
  }

  func unsave(post: Post, automaticallyCancelling: Bool = false)
    -> DataTask<Data> {
    unsave(fullname: post.name, automaticallyCancelling: automaticallyCancelling)
  }

  @discardableResult
  func unsave(fullname: Fullname, queue: DispatchQueue = .main,
              completion: @escaping (Result<Data, AFError>) -> Void)
    -> DataRequest {
    session.request(ActionRouter.unsave(id: fullname))
      .validate()
      .responseData(queue: queue) { response in
        completion(response.result)
      }
  }

  func unsave(fullname: Fullname, automaticallyCancelling: Bool = false)
    -> DataTask<Data> {
    session.request(ActionRouter.unsave(id: fullname))
      .validate()
      .serializingData(automaticallyCancelling: automaticallyCancelling)
  }

  @discardableResult
  func changeSubscription(of subreddits: [Subreddit], action: SubscribeAction, queue: DispatchQueue = .main,
                          completion: @escaping (Result<Data, AFError>) -> Void)
    -> DataRequest {
    session.request(ActionRouter.changeSubscription(sr: subreddits, action: action))
      .validate()
      .responseData(queue: queue) { response in
        completion(response.result)
      }
  }

  @discardableResult
  func changeSubscription(of subreddit: Subreddit, action: SubscribeAction, queue: DispatchQueue = .main,
                          completion: @escaping (Result<Data, AFError>) -> Void)
    -> DataRequest {
    changeSubscription(of: [subreddit], action: action, queue: queue, completion: completion)
  }
}
