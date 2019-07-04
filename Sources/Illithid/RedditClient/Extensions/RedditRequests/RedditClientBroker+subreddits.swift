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
import Willow
import SwiftyJSON

public extension RedditClientBroker {
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
  func subreddits(sortBy subredditSort: SubredditSort = .popular,
                  params: ListingParams = .init(), completion: @escaping (Listing) -> Void) {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .secondsSince1970
    let parameters = params.toParameters()
    let queryEncoding = URLEncoding(boolEncoding: .numeric)
    let subredditsListUrl = URL(string: "https://oauth.reddit.com/subreddits/\(subredditSort)")!

    session.request(subredditsListUrl, method: .get, parameters: parameters, encoding: queryEncoding)
      .validate().responseData { response in
        switch response.result {
        case let .success(data):
          do {
            let list = try decoder.decode(Listing.self, from: data)
            completion(list)
          } catch let error as DecodingError {
            let json = try? JSON(data: data).rawString(options: [.sortedKeys, .prettyPrinted])
            let response = json ?? String(data: data, encoding: .utf8) ?? "All decoding attempts failed"
            self.logger.errorMessage("Error decoding subreddits list: \(error)")
            self.logger.errorMessage("JSON data response: \(response)")
          } catch {
            let json = try? JSON(data: data).rawString(options: [.sortedKeys, .prettyPrinted])
            let response = json ?? String(data: data, encoding: .utf8) ?? "All decoding attempts failed"
            self.logger.errorMessage("Unknown error decoding data: \(error)")
            self.logger.errorMessage("JSON data response: \(response)")
          }
        case let .failure(error):
          self.logger.errorMessage("Failed to call subreddits API endpoint: \(error)")
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
