//
//  File.swift
//  
//
//  Created by Tyler Gregory on 12/23/19.
//

extension Multireddit: PostsProvider {
  public func posts(sortBy sort: PostSort, location: Location?, topInterval: TopInterval?, parameters: ListingParameters, completion: @escaping (Result<Listing, Error>) -> Void) {
    Illithid.shared.fetchPosts(for: self, sortBy: sort, location: location, topInterval: topInterval, params: parameters) { listing in
      completion(.success(listing))
    }
  }
}
