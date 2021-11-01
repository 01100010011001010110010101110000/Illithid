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

import Alamofire
import Foundation
import OAuthSwift

// MARK: - IllithidRedditRequestInterceptor

final class IllithidRedditRequestInterceptor: OAuthSwift2RequestInterceptor {
  // MARK: Lifecycle

  init(_ oauthSwift: OAuth2Swift, onTokenRenewal: @escaping OAuthSwift.TokenRenewedHandler = { _ in }) {
    self.onTokenRenewal = onTokenRenewal
    super.init(oauthSwift)
  }

  override init(_ oauthSwift: OAuth2Swift) {
    onTokenRenewal = { _ in }
    super.init(oauthSwift)
  }

  // MARK: Internal

  override func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
    super.adapt(urlRequest, for: session) { result in
      switch result {
      case let .success(request):
        do {
          // Without this some API responses come back URL encoded
          if request.url?.host?.hasSuffix("reddit.com") ?? false {
            let request = try URLEncoding.queryString.encode(request, with: ["raw_json": true])
            completion(.success(request))
          } else {
            completion(.success(request))
          }
        } catch {
          completion(.failure(error))
        }
      case let .failure(error):
        completion(.failure(error))
      }
    }
  }

  override func retry(_ request: Request, for: Session, dueTo: Error, completion: @escaping (RetryResult) -> Void) {
    super.retry(request, for: `for`, dueTo: dueTo) { [weak self] result in
      switch result {
      case .retry, .retryWithDelay:
        guard let self = self else { break }
        self.onTokenRenewal(.success(self.oauth2Swift.client.credential))
      default:
        break
      }
      completion(result)
    }
  }

  // MARK: Private

  private let onTokenRenewal: OAuthSwift.TokenRenewedHandler
}

// MARK: - OAuthSwiftRequestInterceptor

/// Add authentification headers from OAuthSwift to Alamofire request
open class OAuthSwiftRequestInterceptor: RequestInterceptor {
  // MARK: Lifecycle

  public init(_ oauthSwift: OAuthSwift) {
    self.oauthSwift = oauthSwift
  }

  // MARK: Open

  open func adapt(_ urlRequest: URLRequest, for _: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
    var config = OAuthSwiftHTTPRequest.Config(
      urlRequest: urlRequest,
      paramsLocation: paramsLocation,
      dataEncoding: dataEncoding
    )
    config.updateRequest(credential: oauthSwift.client.credential)

    do {
      completion(.success(try OAuthSwiftHTTPRequest.makeRequest(config: config)))
    } catch {
      completion(.failure(error))
    }
  }

  open func retry(_: Request, for _: Session, dueTo _: Error, completion: @escaping (RetryResult) -> Void) {
    completion(.doNotRetry)
  }

  // MARK: Public

  public var paramsLocation: OAuthSwiftHTTPRequest.ParamsLocation = .authorizationHeader
  public var dataEncoding: String.Encoding = .utf8
  public var retryLimit = 1

  // MARK: Fileprivate

  fileprivate let oauthSwift: OAuthSwift
  fileprivate var requestsToRetry: [(RetryResult) -> Void] = []
}

// MARK: - OAuthSwift2RequestInterceptor

open class OAuthSwift2RequestInterceptor: OAuthSwiftRequestInterceptor {
  // MARK: Lifecycle

  public init(_ oauthSwift: OAuth2Swift) {
    super.init(oauthSwift)
  }

  // MARK: Open

  override open func retry(_ request: Request, for _: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
    lock.lock(); defer { lock.unlock() }

    if mustRetry(request: request, dueTo: error) {
      // queue requests so they can all be retried when token refresh is done
      requestsToRetry.append(completion)

      if !isRefreshing {
        refreshTokens { [weak self] result in
          guard let strongSelf = self else { return }

          strongSelf.lock.lock(); defer { strongSelf.lock.unlock() }

          var shouldRetry: RetryResult

          switch result {
          case .success:
            shouldRetry = .retry
          case let .failure(error):
            shouldRetry = .doNotRetryWithError(error)
          }

          // process any previously queued requests
          strongSelf.requestsToRetry.forEach { $0(shouldRetry) }
          strongSelf.requestsToRetry.removeAll()
        }
      }
    } else {
      completion(.doNotRetry)
    }
  }

  /// Determine if must retry or not ie. refresh token
  open func mustRetry(request: Request, dueTo _: Error) -> Bool {
    if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401, request.retryCount < retryLimit {
      return true
    }
    return false
  }

  // MARK: Fileprivate

  fileprivate var oauth2Swift: OAuth2Swift { oauthSwift as! OAuth2Swift }

  // MARK: Private

  private let lock = NSLock() // lock required to manage requestToRetry access
  private var isRefreshing = false

  private func refreshTokens(completion: @escaping (Result<Void, Error>) -> Void) {
    guard !isRefreshing else { return }

    isRefreshing = true

    // TODO: - Remove once patch is merged: https://github.com/OAuthSwift/OAuthSwift/pull/681
    var headers = OAuthSwift.Headers()
    if oauth2Swift.accessTokenBasicAuthentification {
      let authentication = "\(oauth2Swift.parameters["consumerKey"]!):".data(using: .utf8)
      if let base64Encoded = authentication?.base64EncodedString() {
        headers["Authorization"] = "Basic \(base64Encoded)"
      }
    }

    oauth2Swift.renewAccessToken(withRefreshToken: oauth2Swift.client.credential.oauthRefreshToken, headers: headers) { [weak self] result in
      guard let strongSelf = self else { return }

      // map success result from TokenSuccess to Void, and failure from OAuthSwiftError to Error
      let refreshResult = result.map { _ in () }.mapError { $0 as Error }
      completion(refreshResult)

      strongSelf.isRefreshing = false
    }
  }
}

extension OAuth1Swift {
  open var requestInterceptor: OAuthSwiftRequestInterceptor {
    OAuthSwiftRequestInterceptor(self)
  }
}

extension OAuth2Swift {
  open var requestInterceptor: OAuthSwift2RequestInterceptor {
    OAuthSwift2RequestInterceptor(self)
  }
}

public extension Alamofire.HTTPMethod {
  var oauth: OAuthSwiftHTTPRequest.Method {
    OAuthSwiftHTTPRequest.Method(rawValue: rawValue)!
  }
}

public extension OAuthSwiftHTTPRequest.Method {
  var alamofire: Alamofire.HTTPMethod {
    Alamofire.HTTPMethod(rawValue: rawValue)
  }
}
