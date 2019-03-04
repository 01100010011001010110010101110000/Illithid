//
//  PostTableCellView.swift
//  Illithid
//
//  Created by Tyler Gregory on 2/19/19.
//  Copyright © 2019 flayware. All rights reserved.
//

import Cocoa

import Swift

class SubredditTableCellView: NSTableCellView {
    @IBOutlet var title: NSTextField!
    @IBOutlet var subredditDescription: NSTextField!
    @IBOutlet var preview: NSImageView!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
}
