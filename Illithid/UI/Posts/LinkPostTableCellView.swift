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
  
  @IBOutlet var postAuthor: NSTextField!
  
  @IBOutlet var postAge: NSTextField!
  @IBOutlet var subredditName: NSTextField!
  
  @IBOutlet var postDownvotes: NSTextField!
  @IBOutlet var postUpvotes: NSTextField!
  @IBOutlet var postCommentsCount: NSTextField!
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
  }
}
