//
//  SessionManager+subreddits.swift
//  Illithid
//
//  Created by Tyler Gregory on 3/3/19.
//  Copyright © 2019 flayware. All rights reserved.
//

import Foundation

import Alamofire
import AlamofireImage
import CleanroomLogger
import SwiftyJSON

extension RedditClientBroker {
  /**
   Loads subreddits from the Reddit API

   - Parameters:
     - subredditSort: Subreddit sort method
     - before: Fetch subreddits before this subreddit ID
     - after: Fetch subreddits after this subreddit ID
     - count: Number of items already seen in the listing
     - includeCategories: Documentation unclear
     - limit: Number of subreddits to fetch (default: 25, max: 100)
     - show: Ignores site wide filters (e.g. hide alreadt voted links) if "all" is passed, else no affect
     - srDetail: Documentation unclear, [could only find this](https://www.reddit.com/r/redditdev/comments/3560mt/what_is_the_query_parameter_sr_detail_for_in/)
     - completion: Completion handler, is passed the listable as an argument
   */
  func listSubreddits(sortBy subredditSort: SubredditSort = .popular,
                      before: String = "", after: String = "", count: Int = 0,
                      includeCategories: Bool = false, limit: Int = 25, show: ShowAllPreference = .filtered,
                      srDetail: Bool = false, completion: @escaping (Listable<Subreddit>) -> Void) {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .secondsSince1970
    let parameters: Parameters = [
      "before": before,
      "after": after,
      "count": count,
      "include_categories": includeCategories,
      "limit": limit,
      "show": show,
      "sr_detail": srDetail
    ]
    let queryEncoding = URLEncoding(boolEncoding: .literal)
    let subredditsListUrl = URL(string: "https://oauth.reddit.com/subreddits/\(subredditSort)")!

    session.request(subredditsListUrl, method: .get, parameters: parameters, encoding: queryEncoding)
      .validate().responseData { response in
        switch response.result {
        case let .success(data):
          do {
            let list = try decoder.decode(Listable<Subreddit>.self, from: data)
            completion(list)
          } catch let error as DecodingError {
            let json = try? JSON(data: data).rawString(options: [.sortedKeys, .prettyPrinted])
            let response = json ?? String(data: data, encoding: .utf8) ?? "All decoding attempts failed"
            Log.error?.message("Error decoding subreddits list: \(error)")
            Log.error?.message("JSON data response: \(response)")
          } catch {
            let json = try? JSON(data: data).rawString(options: [.sortedKeys, .prettyPrinted])
            let response = json ?? String(data: data, encoding: .utf8) ?? "All decoding attempts failed"
            Log.error?.message("Unknown error decoding data: \(error)")
            Log.error?.message("JSON data response: \(response)")
          }
        case let .failure(error):
          Log.error?.message("Failed to call subreddits API endpoint: \(error)")
        }
      }
  }

  func fetchSubredditHeaderImages(_ subreddit: Subreddit, downloader: ImageDownloader? = nil,
                                  completion: @escaping ImageDownloader.CompletionHandler) {
    let imageDownloader = downloader ?? self.imageDownloader
    guard let url = subreddit.headerImageURL else { return }
    let request = URLRequest(url: url)
    imageDownloader.download(request) { completion($0) }
  }
  
  func fetchSubredditHeaderImages(_ subreddits: [Subreddit], downloader: ImageDownloader? = nil,
                                  completion: @escaping ImageDownloader.CompletionHandler) {
    let imageDownloader = downloader ?? self.imageDownloader
    let headerImageURLs: [URLRequest] = subreddits.compactMap { subreddit in
      guard let url = subreddit.headerImageURL else { return nil }
      return URLRequest(url: url)
    }
    guard !headerImageURLs.isEmpty else { return }
    imageDownloader.download(headerImageURLs) { completion($0) }
  }
}
