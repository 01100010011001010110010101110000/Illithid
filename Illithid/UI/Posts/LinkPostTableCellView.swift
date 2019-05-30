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
  @IBOutlet var postTitle: NSTextField!
  @IBOutlet var previewImage: NSImageView!
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
  }
}
