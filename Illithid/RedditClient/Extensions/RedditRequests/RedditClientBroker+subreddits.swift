//
//  SessionManager+subreddits.swift
//  Illithid
//
//  Created by Tyler Gregory on 3/3/19.
//  Copyright © 2019 flayware. All rights reserved.
//

import Foundation

import Alamofire
import CleanroomLogger

extension RedditClientBroker {
  func listSubreddits(sortBy subredditSort: SubredditSort, before: String = "", after: String = "", count: Int = 0,
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
          } catch {
            Log.error?.message("Error decoding subreddits list: \(error)")
            Log.error?.message("Raw data response: \(String(decoding: data, as: UTF8.self))")
          }
        case let .failure(error):
          Log.error?.message("Failed to call subreddits API endpoint: \(error)")
        }
      }
  }
}
