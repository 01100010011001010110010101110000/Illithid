//
//  VideoPostTableCellView.swift
//  Illithid
//
//  Created by Tyler Gregory on 5/3/19.
//  Copyright © 2019 flayware. All rights reserved.
//

import Cocoa
import WebKit

class VideoPostTableCellView: NSTableCellView {
  @IBOutlet var videoWebView: WKWebView!
  @IBOutlet var postTitle: NSTextField!
  
  let permittedHosts = [
  "youtube.com",
  "google.com"
  ]

  override func draw(_ dirtyRect: NSRect) {
    let configuration = WKWebViewConfiguration()
    configuration.allowsAirPlayForMediaPlayback = true
    videoWebView = WKWebView(frame: .zero, configuration: configuration)
    videoWebView.navigationDelegate = self
    super.draw(dirtyRect)
  }
}

extension VideoPostTableCellView: WKNavigationDelegate {
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
  }
  
  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
               decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    if let host = navigationAction.request.url?.host {
      if permittedHosts.contains(where: { host.contains($0) }) {
        decisionHandler(.allow)
        return
      }
    }
    decisionHandler(.cancel)
  }
}
