//
//  PostsViewController.swift
//  Illithid
//
//  Created by Tyler Gregory on 4/29/19.
//  Copyright © 2019 flayware. All rights reserved.
//

import Cocoa
import WebKit

import CleanroomLogger

class PostsViewController: NSViewController {
  let notificationCenter = NotificationCenter.default
  let broker = RedditClientBroker.broker
  var loadedSubreddit: Subreddit?
  var posts: [Post] = []

  @IBOutlet var postsTableView: NSTableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    postsTableView.delegate = self
    postsTableView.dataSource = self
    notificationCenter.addObserver(self, selector: #selector(onSubredditChange(_:)),
                                   name: .subredditChanged, object: nil)
  }
}

extension PostsViewController {
  @objc func onSubredditChange(_ notification: Notification) {
    guard let subreddit = notification.object as? Subreddit else {
      Log.debug?.message("No subreddit selected, doing nothing")
      return
    }
    guard loadedSubreddit != subreddit else {
      Log.debug?.message("Switched to the same subreddit, doing nothing")
      return
    }
    let params = ListingParams()
    broker.fetchPosts(for: subreddit, sortBy: .hot, params: params) { list in
      list.metadata.children.forEach { self.posts.append($0.object) }
      self.renderPosts(list)
    }
  }
  
  func renderPosts(_ posts: Listable<Post>) {
    postsTableView.reloadData()
  }
}

extension PostsViewController: NSTableViewDelegate {
  func numberOfRows(in tableView: NSTableView) -> Int {
    return posts.count
  }
}

extension PostsViewController: NSTableViewDataSource {
  func tableView(_ tableView: NSTableView, viewFor _: NSTableColumn?, row: Int) -> NSView? {
    let post = posts[row]
    let videoIdentifier = NSUserInterfaceItemIdentifier(rawValue: "VideoPostCell")
    let imageIdentifier = NSUserInterfaceItemIdentifier(rawValue: "ImagePostCell")
    let textIdentifier = NSUserInterfaceItemIdentifier(rawValue: "TextPostCell")
    if post.is_self {
      return nil
    } else if post.media?.type == "youtube.com" {
      if let cell = postsTableView.makeView(withIdentifier: videoIdentifier, owner: self) as? VideoPostTableCellView {
        cell.postTitle?.stringValue = post.title
        cell.videoWebView.load(URLRequest(url: post.media!.oembed.html.iFrameSrc()!))
        return cell
      } else {
        Log.error?.message("Failed to create a cell")
        return nil
      }
    } else {
      return nil
    }
  }
}
