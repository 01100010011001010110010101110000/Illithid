//
//  PostsTableView.swift
//  Illithid
//
//  Created by Tyler Gregory on 5/30/19.
//  Copyright © 2019 flayware. All rights reserved.
//

import Cocoa

import CleanroomLogger

class PostsTableView: NSTableView {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
  override func resize(withOldSuperviewSize oldSize: NSSize) {
    super.resize(withOldSuperviewSize: oldSize)
    // TODO: This is very inefficient, fix it
    self.reloadData()
  }
}
