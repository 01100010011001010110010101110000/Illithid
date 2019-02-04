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
  var textView: NSTextView?
  
  @IBOutlet var urlTextField: NSTextField!
  @IBOutlet var responseScrollView: NSScrollView!

  @IBAction func callApiButton(_: NSButton) {
    guard let textView = self.responseScrollView.documentView as? NSTextView else {
      Log.error?.message("The debug console's textview is unavailable")
      return
    }
    let resultString = textView.textStorage?.mutableString
    resultString?.setString("")
    RedditClientBroker.broker.session.request(self.urlTextField.stringValue).validate().responseData { response in
      switch response.result {
      case let .success(data):
        let object = try! JSON(data: data)
        resultString?.setString(object.rawString() ?? "We have a successful call but no JSON raw string")
        textView.textColor = NSColor.white
        
      case let .failure(error):
        let error = "Failed to execute: \(self.urlTextField.stringValue)\n\n\(error)"
        Log.error?.message(error)
        resultString?.setString(error)
        textView.textColor = NSColor.red
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.urlTextField.stringValue = "https://oauth.reddit.com/"
    guard let textView = self.responseScrollView.documentView as? NSTextView else {
      Log.error?.message("The debug console's textview is unavailable")
      return
    }
    textView.isEditable = false
  }
}
