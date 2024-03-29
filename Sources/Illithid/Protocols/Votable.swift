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

// MARK: - Votable

public protocol Votable: RedditObject {
  var likes: Bool? { get }
  var ups: Int { get }

  @discardableResult
  func upvote(queue: DispatchQueue, completion: @escaping (Result<Data, AFError>) -> Void) -> DataRequest

  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func upvote() -> DataTask<Data>

  @discardableResult
  func downvote(queue: DispatchQueue, completion: @escaping (Result<Data, AFError>) -> Void) -> DataRequest

  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func downvote() -> DataTask<Data>

  @discardableResult
  func clearVote(queue: DispatchQueue, completion: @escaping (Result<Data, AFError>) -> Void) -> DataRequest

  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func clearVote() -> DataTask<Data>
}

public extension Votable {
  @discardableResult
  func upvote(queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) -> DataRequest {
    Illithid.shared.vote(fullname: name, direction: .up, queue: queue, completion: completion)
  }

  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func upvote() -> DataTask<Data> {
    Illithid.shared.vote(fullname: name, direction: .up, automaticallyCancelling: true)
  }

  @discardableResult
  func downvote(queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) -> DataRequest {
    Illithid.shared.vote(fullname: name, direction: .down, queue: queue, completion: completion)
  }

  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func downvote() -> DataTask<Data> {
    Illithid.shared.vote(fullname: name, direction: .down, automaticallyCancelling: true)
  }

  @discardableResult
  func clearVote(queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) -> DataRequest {
    Illithid.shared.vote(fullname: name, direction: .clear, queue: queue, completion: completion)
  }

  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func clearVote() -> DataTask<Data> {
    Illithid.shared.vote(fullname: name, direction: .clear, automaticallyCancelling: true)
  }
}
