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

import AuthenticationServices
import Foundation

import OAuthSwift

// MARK: - IllithidWebAuthURLHandler

final class IllithidWebAuthURLHandler: OAuthSwiftURLHandlerType {
  // MARK: Lifecycle

  init(callbackURLScheme: String, anchor: ASWebAuthenticationPresentationContextProviding) {
    self.callbackURLScheme = callbackURLScheme
    self.anchor = anchor
  }

  // MARK: Internal

  var webAuthSession: ASWebAuthenticationSession!
  let callbackURLScheme: String
  let anchor: ASWebAuthenticationPresentationContextProviding

  func handle(_ url: URL) {
    webAuthSession = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme) { callback, error in
      guard error == nil, let successURL = callback else {
        let msg = error?.localizedDescription.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let urlString = "\(self.callbackURLScheme)?error=\(msg ?? "UNKNOWN")"
        let url = URL(string: urlString)!
        NSWorkspace.shared.open(url)
        return
      }
      NSWorkspace.shared.open(successURL)
    }
    webAuthSession.presentationContextProvider = anchor
    _ = webAuthSession.start()
  }
}

// MARK: - NSWindow + ASWebAuthenticationPresentationContextProviding

extension NSWindow: ASWebAuthenticationPresentationContextProviding {
  public func presentationAnchor(for _: ASWebAuthenticationSession) -> ASPresentationAnchor {
    self
  }
}
