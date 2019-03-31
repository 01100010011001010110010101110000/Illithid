//
//  SubredditsViewController.swift
//  Illithid
//
//  Created by Tyler Gregory on 2/19/19.
//  Copyright © 2019 flayware. All rights reserved.
//

import Cocoa
import Foundation

import AlamofireImage
import CleanroomLogger

class SubredditsViewController: NSViewController {
  var subreddits: [Subreddit] = []
  let imageDownloader = ImageDownloader(maximumActiveDownloads: 20)
  let notificationCenter = NotificationCenter.default
  
  var before: String?
  var after: String?

  @IBOutlet var subredditsTableView: NSTableView!
  @IBOutlet var subredditsScrollView: NSScrollView!
  
  override func viewWillAppear() {
    super.viewWillAppear()
    RedditClientBroker.broker.listSubreddits(sortBy: .default) { [unowned self] list in
      var idx = self.subreddits.count
      self.before = list.metadata.before
      self.after = list.metadata.after
      list.metadata.children.forEach { [unowned self] subreddit in
        self.subreddits.append(subreddit.object)
        if let imageURL = subreddit.object.headerImageURL {
          self.imageDownloader.download([URLRequest(url: imageURL)]) { [unowned self, idx] response in
            self.subreddits[idx].headerImage = response.result.value
            let (columnIdx, rowIdx) = (IndexSet(integer: 0), IndexSet(integer: idx))
            self.subredditsTableView.reloadData(forRowIndexes: rowIdx, columnIndexes: columnIdx)
          }
        }
        idx += 1
      }
      self.subredditsTableView.reloadData()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    subredditsTableView.delegate = self
    subredditsTableView.dataSource = self
    
    self.notificationCenter.addObserver(self, selector: #selector(onLiveScroll(_:)),
                                        name: NSScrollView.didLiveScrollNotification, object: self.subredditsScrollView)
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
      cell.title?.stringValue = subreddits[row].displayName
      cell.subredditDescription?.stringValue = subreddits[row].publicDescription
      cell.preview.image = subreddits[row].headerImage ?? NSImage(named: "NSUser")
      return cell
    } else {
      Log.error?.message("Failed to create a cell")
      return nil
    }
  }
}

extension SubredditsViewController {
  @objc func onLiveScroll(_ notification: Notification) {
    guard let scrollView = notification.object as? NSScrollView else { return }
    let currentPosition = Int(scrollView.contentView.bounds.maxY)
    let tableLngth = Int(subredditsTableView.bounds.height)
    if tableLngth - currentPosition < 200 {
      //TODO load additional subreddits and insert them into the table
      return
    }
  }
}
