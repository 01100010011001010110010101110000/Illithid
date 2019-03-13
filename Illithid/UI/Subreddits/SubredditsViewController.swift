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
  var subreddits: [Subreddit] = []
  
  @IBOutlet var subredditsTableView: NSTableView!
  
  override func viewWillAppear() {
    super.viewWillAppear()
    RedditClientBroker.broker.listSubreddits(sortBy: .default, completion: { [unowned self] (list) in
      list.data.children.forEach { [unowned self] (child) in
        self.subreddits.append(child.data)
      }
      self.subredditsTableView.reloadData()
    })
  }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        subredditsTableView.delegate = self
        subredditsTableView.dataSource = self
    }
}

extension SubredditsViewController: NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return subreddits.count
    }
}

extension SubredditsViewController: NSTableViewDataSource {
    func tableView(_ tableView: NSTableView, viewFor _: NSTableColumn?, row: Int) -> NSView? {
        let identifier = NSUserInterfaceItemIdentifier(rawValue: "Post")
        if let cell = subredditsTableView.makeView(withIdentifier: identifier, owner: self) as? SubredditTableCellView {
            cell.title?.stringValue = self.subreddits[row].displayName
            cell.subredditDescription?.stringValue = self.subreddits[row].publicDescription
            cell.preview.image = NSImage(named: "NSUser")
            return cell
        } else {
            Log.error?.message("Failed to create a cell")
            return nil
        }
    }
}
