//
// SwiftResult+AFResult.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 1/25/20
//

import Alamofire

internal extension Swift.Result where Failure == Error {
  init(from afResult: Alamofire.Result<Success>) {
    switch afResult {
    case let .success(success):
      self = .success(success)
    case let .failure(error):
      self = .failure(error)
    }
  }
}
