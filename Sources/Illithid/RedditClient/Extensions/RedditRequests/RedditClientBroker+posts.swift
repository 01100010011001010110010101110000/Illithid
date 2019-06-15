//
//  File.swift
//  Illithid
//
//  Created by Tyler Gregory on 4/30/19.
//  Copyright © 2019 flayware. All rights reserved.
//

import Foundation

import Alamofire
import AlamofireImage
import Willow
import SwiftyJSON

public extension RedditClientBroker {
  func fetchPosts(for subreddit: Subreddit, sortBy postSort: PostSort,
                  location: Location? = nil, topInterval: TopInterval? = nil,
                  params: ListingParams = .init(), completion: @escaping (Listing<Post>) -> Void) {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .secondsSince1970
    var parameters = params.toParameters()
    let queryEncoding = URLEncoding(boolEncoding: .numeric)
    let postsUrl = URL(string: "https://oauth.reddit.com/r/\(subreddit.displayName)/\(postSort)")!
    
    // Handle nonsense magic string parameters which apply to specific sorts
    switch postSort {
    case .controversial, .top:
      parameters["t"] = topInterval ?? TopInterval.day
    case .hot:
      parameters["g"] = location ?? Location.GLOBAL
    default:
      break
    }
    
    session.request(postsUrl, method: .get, parameters: parameters, encoding: queryEncoding).validate()
      .responseData { response in
        switch response.result {
        case let .success(data):
          do {
            let list = try decoder.decode(Listing<Post>.self, from: data)
            completion(list)
          } catch let error as DecodingError {
            let json = try? JSON(data: data).rawString(options: [.sortedKeys, .prettyPrinted])
            let response = json ?? String(data: data, encoding: .utf8) ?? "All decoding attempts failed"
            self.logger.errorMessage("Error decoding post list: \(error)")
            self.logger.errorMessage("JSON data response: \(response)")
          } catch {
            let json = try? JSON(data: data).rawString(options: [.sortedKeys, .prettyPrinted])
            let response = json ?? String(data: data, encoding: .utf8) ?? "All decoding attempts failed"
            self.logger.errorMessage("Error decoding post list: \(error)")
            self.logger.errorMessage("JSON data response: \(response)")
          }
        case let .failure(error):
          self.logger.errorMessage("Failed to call posts API endpoint: \(error)")
        }
    }
  }
  
  func fetchPostImage(for post: Post, downloader: ImageDownloader? = nil,
                      completion: @escaping ImageDownloader.CompletionHandler) {
    let imageDownloader = downloader ?? self.imageDownloader
    let request = URLRequest(url: post.url)
    
    imageDownloader.download(request) { completion($0) }
  }
}
