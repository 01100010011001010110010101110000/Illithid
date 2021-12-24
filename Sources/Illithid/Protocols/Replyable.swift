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

import Combine
import Foundation

import Alamofire

// MARK: - Replyable

public protocol Replyable: RedditObject {
  /// Reply to the `Replyable` with a new comment
  ///
  /// - Parameter body: The MarkDown string comprising the reply comment
  /// - Parameter automaticallyCancelling: If true the AF request is automatically canceled when the task is canceled
  /// - Throws: An `AFError` if a network error was encountered
  /// - Returns: The newly created reply `Comment`
  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func reply(markdown body: String, automaticallyCancelling: Bool) -> DataTask<Comment>

  /// Reply to the `Replyable` with a new comment
  ///
  /// - Parameters:
  ///   - body: The MarkDown string comprising the reply comment
  ///   - queue: The `DispatchQueue` on which the `DataResponse` will be published
  /// - Returns: An `AnyPublisher` containing either the newly created reply `Comment`, or an `AFError`
  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func reply(markdown body: String, queue: DispatchQueue) -> AnyPublisher<Comment, AFError>
}

public extension Replyable {
  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func reply(markdown body: String, automaticallyCancelling: Bool = false) -> DataTask<Comment> {
    Illithid.shared.postComment(replyingTo: name, markdown: body, automaticallyCanceling: automaticallyCancelling)
  }

  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func reply(markdown body: String, queue: DispatchQueue = .main) -> AnyPublisher<Comment, AFError> {
    Illithid.shared.postComment(replyingTo: name, markdown: body, queue: queue)
  }
}
