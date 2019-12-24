//
// PostsProvider.swift
// Copyright (c) 2019 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 12/24/19
//

public protocol PostsProvider {
  func posts(sortBy sort: PostSort, location: Location?,
             topInterval: TopInterval?, parameters: ListingParameters, completion: @escaping (Result<Listing, Error>) -> Void)
}

public extension PostsProvider {
  func posts(sortBy sort: PostSort, location: Location? = nil,
             topInterval: TopInterval? = nil, parameters: ListingParameters, completion: @escaping (Result<Listing, Error>) -> Void) {
    posts(sortBy: sort, location: location, topInterval: topInterval, parameters: parameters, completion: completion)
  }
}
