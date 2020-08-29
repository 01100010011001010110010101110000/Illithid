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

enum WikiRouter: URLRequestConvertible, URLConvertible, MirrorableEnum {
  case pages(ofSubreddit: String)

  var path: String {
    switch self {
    case let .pages(ofSubreddit):
      return "/r/\(ofSubreddit)/wiki/pages"
    }
  }

  var parameters: Parameters {
    mirror.parameters
  }

  func asURL() throws -> URL {
    URL(string: path, relativeTo: Illithid.shared.baseURL)!
  }

  func asURLRequest() throws -> URLRequest {
    let request = try URLRequest(url: self, method: .get)
    return try URLEncoding.queryString.encode(request, with: parameters)
  }
}

public extension Illithid {
  @discardableResult
  func wikiPages(ofSubreddit displayName: String, queue: DispatchQueue = .main, completion: @escaping (Result<WikiPages, AFError>) -> Void) -> DataRequest {
    session.request(WikiRouter.pages(ofSubreddit: displayName))
      .validate()
      .responseDecodable(of: WikiPages.self, queue: queue, decoder: decoder) { response in
        completion(response.result)
      }
  }

  @discardableResult
  func wikiPages(of subreddit: Subreddit, queue: DispatchQueue = .main, completion: @escaping (Result<WikiPages, AFError>) -> Void) -> DataRequest {
    wikiPages(ofSubreddit: subreddit.displayName, queue: queue, completion: completion)
  }

  @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
  func wikiPages(ofSubreddit displayName: String, queue: DispatchQueue = .main) -> AnyPublisher<WikiPages, AFError> {
    session.request(WikiRouter.pages(ofSubreddit: displayName))
      .validate()
      .publishDecodable(type: WikiPages.self, queue: queue, decoder: decoder)
      .value()
  }

  @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
  func wikiPages(of subreddit: Subreddit, queue: DispatchQueue = .main) -> AnyPublisher<WikiPages, AFError> {
    wikiPages(ofSubreddit: subreddit.displayName, queue: queue)
  }
}

public extension Subreddit {
  @discardableResult
  func wikiPages(queue: DispatchQueue = .main, completion: @escaping (Result<WikiPages, AFError>) -> Void) -> DataRequest {
    Illithid.shared.wikiPages(of: self, queue: queue, completion: completion)
  }

  func wikiPages(queue: DispatchQueue = .main) -> AnyPublisher<WikiPages, AFError> {
    Illithid.shared.wikiPages(of: self, queue: queue)
  }
}
