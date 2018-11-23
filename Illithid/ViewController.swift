//
//  ViewController.swift
//  Illithid
//
//  Created by Tyler Gregory on 11/17/18.
//  Copyright © 2018 flayware. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }
  
  override func viewDidAppear() {
    super.viewDidAppear()
    RedditClientBroker.broker.configureOAuth2(window: self.view.window!)
  }

  override var representedObject: Any? {
    didSet {
    // Update the view, if already loaded.
    }
  }


}

