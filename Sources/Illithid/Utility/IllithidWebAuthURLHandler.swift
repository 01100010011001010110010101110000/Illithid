//
//  File.swift
//
//
//  Created by Tyler Gregory on 7/25/19.
//

import AuthenticationServices
import Foundation

import OAuthSwift

final class IllithidWebAuthURLHandler: OAuthSwiftURLHandlerType {
  var webAuthSession: ASWebAuthenticationSession!
  let callbackURLScheme: String
  let anchor: ASWebAuthenticationPresentationContextProviding

  init(callbackURLScheme: String, anchor: ASWebAuthenticationPresentationContextProviding) {
    self.callbackURLScheme = callbackURLScheme
    self.anchor = anchor
  }

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

extension NSWindow: ASWebAuthenticationPresentationContextProviding {
  public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    return self
  }
}