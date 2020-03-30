//
// PostProvider.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 3/21/20
//

import Alamofire

import Foundation

public protocol PostProvider {
  var id: String { get }
  var isNsfw: Bool { get }

  @discardableResult
  func posts(sortBy sort: PostSort, location: Location?,
             topInterval: TopInterval?, parameters: ListingParameters, queue: DispatchQueue,
             completion: @escaping (Result<Listing, AFError>) -> Void) -> DataRequest
}
