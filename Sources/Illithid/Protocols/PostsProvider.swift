//
// PostsProvider.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 12/24/19
//

import Alamofire

import Foundation

public protocol PostsProvider {
  func posts(sortBy sort: PostSort, location: Location?,
             topInterval: TopInterval?, parameters: ListingParameters, queue: DispatchQueue, completion: @escaping (Result<Listing, AFError>) -> Void)
}
