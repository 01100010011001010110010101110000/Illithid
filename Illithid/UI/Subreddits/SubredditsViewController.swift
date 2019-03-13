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
    RedditClientBroker.broker.listSubreddits(sortBy: .default, completion: { [unowned self] list in
      list.metadata.children.forEach { [unowned self] child in
        self.subreddits.append(child.object)
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
//  func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
      // TODO replace this with a computation based on the object at the corresponding index in subreddits
//    return toMeasureView.subredditDescription.bounds.height + toMeasureView.title.bounds.height + 19
//  }
}

extension SubredditsViewController: NSTableViewDataSource {
  func tableView(_ tableView: NSTableView, viewFor _: NSTableColumn?, row: Int) -> NSView? {
    let identifier = NSUserInterfaceItemIdentifier(rawValue: "Post")
    if let cell = subredditsTableView.makeView(withIdentifier: identifier, owner: self) as? SubredditTableCellView {
      cell.title?.stringValue = subreddits[row].displayName
      cell.subredditDescription?.stringValue = subreddits[row].publicDescription
      cell.preview.image = NSImage(named: "NSUser")
      return cell
    } else {
      Log.error?.message("Failed to create a cell")
      return nil
    }
  }
}
