//
// PostsProvider.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 12/24/19
//

import Foundation

public protocol PostsProvider {
  func posts(sortBy sort: PostSort, location: Location?,
             topInterval: TopInterval?, parameters: ListingParameters, queue: DispatchQueue?, completion: @escaping (Result<Listing, Error>) -> Void)
}

public extension PostsProvider {
  func posts(sortBy sort: PostSort, location: Location? = nil,
             topInterval: TopInterval? = nil, parameters: ListingParameters, queue: DispatchQueue? = nil, completion: @escaping (Result<Listing, Error>) -> Void) {
    posts(sortBy: sort, location: location, topInterval: topInterval, parameters: parameters, queue: queue, completion: completion)
  }
}
