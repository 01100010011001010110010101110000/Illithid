//
//  ApiDebugConsoleViewController.swift
//  Illithid
//
//  Created by Tyler Gregory on 1/27/19.
//  Copyright © 2019 flayware. All rights reserved.
//

import Cocoa
import Foundation

import Alamofire
import CleanroomLogger
import OAuthSwift
import OAuthSwiftAlamofire
import SwiftyJSON

class ApiDebugConsoleViewController: NSViewController {
  @IBOutlet var urlTextField: NSTextField!
  @IBOutlet var responseScrollView: NSScrollView!

  @IBAction func callApiButton(_: NSButton) {
    let textView = self.responseScrollView.documentView as! NSTextView
    let resultString = textView.textStorage?.mutableString
    resultString?.setString("")
    RedditClientBroker.broker.session.request(self.urlTextField.stringValue).validate().responseData { response in
      switch response.result {
      case let .success(data):
        let object = try! JSON(data: data)
        resultString?.setString(object.rawString() ?? "We have a successful call but no JSON raw string")
        textView.textStorage?.addAttribute(NSAttributedString.Key.foregroundColor,
                                           value: NSColor.white,
                                           range: (NSRange(location: 0, length: resultString?.length ?? 0))
        )
      case let .failure(error):
        let error = "Failed to execute: \(self.urlTextField.stringValue)\n\n\(error)"
        Log.error?.message(error)
        resultString?.setString(error)
        textView.textStorage?.addAttribute(NSAttributedString.Key.foregroundColor,
                                           value: NSColor.red,
                                           range: (NSRange(location: 0, length: resultString?.length ?? 0))
        )
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.urlTextField.stringValue = "https://oauth.reddit.com/"
  }
}
