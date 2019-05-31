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
  let intervalFormatter = DateComponentsFormatter()

  @IBOutlet var postsTableView: PostsTableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    postsTableView.delegate = self
    postsTableView.dataSource = self
    notificationCenter.addObserver(self, selector: #selector(onSubredditChange(_:)),
                                   name: .subredditChanged, object: nil)
    intervalFormatter.allowedUnits = [ .year,.month, .day, .hour, .minute, .second ]
    intervalFormatter.maximumUnitCount = 1
    intervalFormatter.unitsStyle = .abbreviated
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
    subreddit.posts(sortBy: .hot) { list in
      list.metadata.children.forEach { self.posts.append($0.object) }
      self.renderPosts(list)
    }
  }

  func renderPosts(_ posts: Listing<Post>) {
    postsTableView.reloadData()
  }
}

extension PostsViewController: NSTableViewDelegate {
  func numberOfRows(in tableView: NSTableView) -> Int {
    return posts.count
  }
}

extension PostsViewController: NSTableViewDataSource {
  func tableView(_ tableView: NSTableView, viewFor column: NSTableColumn?, row: Int) -> NSView? {
    let post = posts[row]
    let linkIdentifier = NSUserInterfaceItemIdentifier(rawValue: "LinkPostCell")
    let videoIdentifier = NSUserInterfaceItemIdentifier(rawValue: "VideoPostCell")
    let imageIdentifier = NSUserInterfaceItemIdentifier(rawValue: "ImagePostCell")
    let textIdentifier = NSUserInterfaceItemIdentifier(rawValue: "TextPostCell")

    // Post type disambiguation
    // The reddit API does not consistently return a post hint for self posts,
    // and we wish to treat other cases with no hint (which may or may not exist) as a link type
    let hint: PostHint = post.is_self ? .self : (post.post_hint ?? .link)
    
    switch hint {
    case .self:
      if let cell = postsTableView.makeView(withIdentifier: textIdentifier, owner: self) as? TextPostTableCellView {
        cell.postTitle.stringValue = post.title
        let attributedText = try! NSMutableAttributedString(data: Data(post.selftext_html!.utf8),
                                                            options: [.documentType: NSAttributedString.DocumentType.html],
                                                            documentAttributes: nil)
        // Default text color is black, which does not play nice with system themes
        attributedText.addAttributes([.foregroundColor: NSColor.textColor, .font: NSFont.labelFont(ofSize: 18.0)],
                                     range: NSRange(location: 0, length: attributedText.length - 1))
        
        let textView = cell.postTextView.documentView as? NSTextView
        textView?.textStorage?.setAttributedString(attributedText)
        if column?.width ?? CGFloat.infinity < cell.fittingSize.width { column?.width = cell.fittingSize.width }
        return cell
      }
    case .image:
      if let cell = postsTableView.makeView(withIdentifier: imageIdentifier, owner: nil) as? ImagePostTableCellView {
        cell.postTitle.stringValue = post.title
        if let image = broker.imageDownloader.imageCache?.image(for: URLRequest(url: post.url), withIdentifier: nil) {
          cell.postImage.image = image
        } else {
          cell.postImage.image = NSImage(imageLiteralResourceName: "NSUser")
          broker.fetchPostImage(for: post) { [unowned self, row] _ in
            self.postsTableView.reloadData(forRowIndexes: IndexSet(integer: row), columnIndexes: IndexSet(integer: 0))
          }
        }
        if column?.width ?? CGFloat.infinity < cell.fittingSize.width { column?.width = cell.fittingSize.width }
        return cell
      }
    case .link:
      if let cell = postsTableView.makeView(withIdentifier: linkIdentifier, owner: self) as? LinkPostTableCellView {
        
        // Properties returned from the API directly
        cell.postTitle.stringValue = post.title
        cell.postAuthor.stringValue = "u/\(post.author)"
        cell.postUpvotes.stringValue = String(post.ups.postAbbreviation())
        cell.postDownvotes.stringValue = String(post.downs.postAbbreviation())
        cell.postCommentsCount.stringValue = String(post.num_comments.postAbbreviation())
        cell.subredditName.stringValue = post.subreddit_name_prefixed
        cell.postAge.stringValue = intervalFormatter.string(from: post.created_utc, to: .init()) ?? "Blade Runner"
        
        guard let previewImageUrlRequest = selectPostPreview(post) else {
          cell.previewImage.image = NSImage(imageLiteralResourceName: "NSUser")
          return cell
        }
        
        let previewImage = broker.imageDownloader.imageCache?.image(for: previewImageUrlRequest, withIdentifier: nil)
        if let image = previewImage {
          cell.previewImage.image = image
        } else {
          cell.previewImage.image = NSImage(imageLiteralResourceName: "NSUser")
          broker.imageDownloader.download(previewImageUrlRequest) { [weak self, row] response in
            switch response.result {
            case .success:
              self?.postsTableView.reloadData(forRowIndexes: IndexSet(integer: row),
                                              columnIndexes: IndexSet(integer: 0))
            case .failure(let error):
              Log.error?.message("Failed to fetch preview thumbnail: \(error)")
            }
          }
        }
        if column?.width ?? CGFloat.infinity < cell.fittingSize.width { column?.width = cell.fittingSize.width }
        return cell
      }
    case .richVideo, .hostedVideo:
      if post.media?.type == "youtube.com" {
        if let cell = postsTableView.makeView(withIdentifier: videoIdentifier, owner: self) as? VideoPostTableCellView {
          cell.postTitle.stringValue = post.title
          cell.videoWebView.load(URLRequest(url: post.media!.oembed!.html.iFrameSrc()!))
          if column?.width ?? CGFloat.infinity < cell.fittingSize.width { column?.width = cell.fittingSize.width }
          return cell
        }
      } else {
        Log.error?.message("Unhandled media type: \(post.media?.type ?? "No media type")")
        return nil
      }
    }

    Log.error?.message("Switch statement is not exhaustive: \(hint)")
    return nil
  }
}

extension PostsViewController {
  
  func selectPostPreview(_ post: Post) -> URLRequest? {
    let superView = self.postsTableView.superview!
    let superHeight = Int(superView.frame.height)
    let superWidth = Int(superView.frame.width)
    
    for preview in post.previews().reversed() {
      guard preview.width < superWidth else { continue }
      if superHeight.distance(to: (3 * preview.height)) < 100 {
        return URLRequest(url: preview.url)
      }
    }
    
    return nil
  }
}
