//
// Multireddits.swift
// Copyright (c) 2019 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 12/24/19
//

import Foundation

extension Multireddit: PostsProvider {
  public func posts(sortBy sort: PostSort, location: Location?, topInterval: TopInterval?,
                    parameters: ListingParameters, queue: DispatchQueue? = nil,
                    completion: @escaping (Result<Listing, Error>) -> Void) {
    Illithid.shared.fetchPosts(for: self, sortBy: sort, location: location,
                               topInterval: topInterval, params: parameters) { listing in
      completion(.success(listing))
    }
  }
}
