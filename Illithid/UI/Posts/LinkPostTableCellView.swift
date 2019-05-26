//
//  LinkPostTableCellView.swift
//  Illithid
//
//  Created by Tyler Gregory on 5/24/19.
//  Copyright © 2019 flayware. All rights reserved.
//

import Cocoa
import WebKit

class LinkPostTableCellView: NSTableCellView {
  @IBOutlet var postTitleTextField: NSTextField!
  @IBOutlet var linkWebView: WKWebView!
  
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
}
