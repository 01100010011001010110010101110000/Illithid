//
// {file}
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on {created}
//

#if canImport(Combine)
  import Combine
#endif
import Foundation

import Alamofire

open class Ulithcat {
  public let baseUrl = URL(string: "https://api.gfycat.com/v1/")!

  internal let session: SessionManager

  internal let decoder: JSONDecoder = .init()
  public init() {
    let alamoConfiguration = URLSessionConfiguration.default
    let osVersion = ProcessInfo().operatingSystemVersion
    let userAgentComponents = [
      "Ulithcat/1",
      "macOS \(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)",
    ]
    let headers = SessionManager.defaultHTTPHeaders.merging([
      "User-Agent": userAgentComponents.joined(separator: ":"),
      "Accept": "application/json",
    ]) { _, new in new }
    alamoConfiguration.httpAdditionalHeaders = headers
    session = SessionManager(configuration: alamoConfiguration)
  }
}

public extension Ulithcat {
  func fetchGfycat(id: String, completion: @escaping (Swift.Result<GfyItem, Error>) -> Void) {
    session.request(URL(string: "gfycats/\(id)", relativeTo: self.baseUrl)!).validate()
      .responseGfyWrapper { response in
        switch response.result {
        case let .success(wrapper):
          completion(.success(wrapper.item))
        case let .failure(error):
          completion(.failure(error))
        }
    }
  }
}
