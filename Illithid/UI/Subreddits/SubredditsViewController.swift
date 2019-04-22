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
  var count: Int = 0
  
  var loadingSubreddits = false

  @IBOutlet var subredditsTableView: NSTableView!
  @IBOutlet var subredditsScrollView: NSScrollView!

  override func viewWillAppear() {
    super.viewWillAppear()
    RedditClientBroker.broker.listSubreddits(sortBy: .default, includeCategories: true) { [unowned self] list in
      self.count += list.metadata.dist
      Log.debug?.message("Found first page\n\(list)")
      self.before = list.metadata.before
      self.after = list.metadata.after
      let preAppendSize = self.subreddits.count
      list.metadata.children.forEach { self.subreddits.append($0.object) }
      self.subredditsTableView.reloadData()
      list.metadata.children.enumerated().forEach { [unowned self] (offset, child) in
        let subreddit = child.object
        RedditClientBroker.broker.fetchSubredditHeaderImages(subreddit) { [unowned self] response in
          subreddit.headerImage = response.result.value
          self.subredditsTableView.reloadData(forRowIndexes: IndexSet(integer: offset + preAppendSize),
                                              columnIndexes: IndexSet(integer: 0))
        }
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    subredditsTableView.delegate = self
    subredditsTableView.dataSource = self

    notificationCenter.addObserver(self, selector: #selector(onLiveScroll(_:)),
                                   name: NSScrollView.didLiveScrollNotification, object: subredditsScrollView)
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
      cell.preview.image = subreddits[row].headerImage
      return cell
    } else {
      Log.error?.message("Failed to create a cell")
      return nil
    }
  }
}

extension SubredditsViewController {
  /// When we get sufficiently close to the end load more subreddits
  @objc func onLiveScroll(_ notification: Notification) {
    guard loadingSubreddits == false else { return }
    guard let scrollView = notification.object as? NSScrollView else { return }
    let currentPosition = Int(scrollView.contentView.bounds.maxY)
    let tableLength = Int(subredditsTableView.bounds.height)
    if tableLength - currentPosition < 200 {
      loadingSubreddits = true
      RedditClientBroker.broker.listSubreddits(sortBy: .popular, after: after ?? "",
                                               count: count) { [unowned self] list in
        self.before = list.metadata.before
        self.after = list.metadata.after
        self.count += list.metadata.dist
        let preAppendSize = self.subreddits.count
                         
        list.metadata.children.forEach { self.subreddits.append($0.object) }
        let insertionIndex = IndexSet(integersIn: preAppendSize ..< self.subreddits.count)
        self.subredditsTableView.beginUpdates()
        self.subredditsTableView.insertRows(at: insertionIndex,
                                            withAnimation: [.slideLeft, .effectGap])
        self.subredditsTableView.endUpdates()
                                                
        Log.debug?.message("Found next page\n\(list)")
        list.metadata.children.enumerated().forEach { [unowned self] (offset, child) in
          let subreddit = child.object
          RedditClientBroker.broker.fetchSubredditHeaderImages(subreddit) { [unowned self] response in
            subreddit.headerImage = response.result.value
            self.subredditsTableView.reloadData(forRowIndexes: IndexSet(integer: offset + preAppendSize),
                                                columnIndexes: IndexSet(integer: 0))
          }
        }
        self.loadingSubreddits = false
      }
    }
  }
}
