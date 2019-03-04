//
//  SubredditsViewController.swift
//  Illithid
//
//  Created by Tyler Gregory on 2/19/19.
//  Copyright © 2019 flayware. All rights reserved.
//

import Cocoa

import CleanroomLogger

class SubredditsViewController: NSViewController {
    @IBOutlet var subredditsTableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subredditsTableView.delegate = self
        subredditsTableView.dataSource = self
    }
}

extension SubredditsViewController: NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 2
    }
}

extension SubredditsViewController: NSTableViewDataSource {
    func tableView(_ tableView: NSTableView, viewFor _: NSTableColumn?, row: Int) -> NSView? {
        let identifier = NSUserInterfaceItemIdentifier(rawValue: "Post")
        if let cell = subredditsTableView.makeView(withIdentifier: identifier, owner: self) as? SubredditTableCellView {
            cell.title?.stringValue = "title test"
            cell.subredditDescription?.stringValue = "description test"
            cell.preview.image = NSImage(named: "NSUser")
            Log.debug?.message("Returning post table cell view")
            return cell
        } else {
            Log.error?.message("I failed to create a cell")
            return nil
        }
    }
}
