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

// MARK: - Savable

public protocol Savable: RedditObject {
  var saved: Bool { get }

  func save(queue: DispatchQueue, completion: @escaping (Result<Data, AFError>) -> Void) -> DataRequest

  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func save() -> DataTask<Data>

  func unsave(queue: DispatchQueue, completion: @escaping (Result<Data, AFError>) -> Void) -> DataRequest

  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func unsave() -> DataTask<Data>
}

public extension Savable {
  @discardableResult
  func save(queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) -> DataRequest {
    Illithid.shared.save(fullname: name, queue: queue, completion: completion)
  }

  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func save() -> DataTask<Data> {
    Illithid.shared.save(fullname: name, automaticallyCancelling: true)
  }

  @discardableResult
  func unsave(queue: DispatchQueue = .main, completion: @escaping (Result<Data, AFError>) -> Void) -> DataRequest {
    Illithid.shared.unsave(fullname: name, queue: queue, completion: completion)
  }

  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  func unsave() -> DataTask<Data> {
    Illithid.shared.unsave(fullname: name, automaticallyCancelling: true)
  }
}
