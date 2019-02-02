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
    self.responseScrollView.documentView!.insertText("")
    RedditClientBroker.broker.session.request(self.urlTextField.stringValue).validate().responseData { response in
      switch response.result {
      case let .success(data):
        let object = try! JSON(data: data)
        self.responseScrollView.documentView!.insertText(object.rawString() ?? "We have a successful call but no JSON raw string")
      case let .failure(error):
        Log.error?.message("Failed to execute: \(self.urlTextField.stringValue)\n\n\(error)")
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.urlTextField.stringValue = "https://oauth.reddit.com/"
  }
}
