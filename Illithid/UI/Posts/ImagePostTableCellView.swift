//
//  ImagePostTableCellView.swift
//  Illithid
//
//  Created by Tyler Gregory on 5/6/19.
//  Copyright © 2019 flayware. All rights reserved.
//

import Cocoa

class ImagePostTableCellView: NSTableCellView {

  @IBOutlet var postTitle: NSTextField!
  @IBOutlet var postImage: NSImageView!
  
  override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
