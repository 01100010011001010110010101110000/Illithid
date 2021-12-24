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

public protocol Savable: RedditObject {
  func save() async throws -> Data
  func save(queue: DispatchQueue, completion: @escaping (Result<Data, AFError>) -> Void) -> DataRequest

  func unsave() async throws -> Data
  func unsave(queue: DispatchQueue, completion: @escaping (Result<Data, AFError>) -> Void) -> DataRequest
}
