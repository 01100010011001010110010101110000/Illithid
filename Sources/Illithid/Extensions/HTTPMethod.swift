//
// HTTPMethod.swift
// Copyright (c) 2019 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 12/24/19
//

import Alamofire
import Foundation
import OAuthSwift

public extension Alamofire.HTTPMethod {
  var oauth: OAuthSwiftHTTPRequest.Method {
    OAuthSwiftHTTPRequest.Method(rawValue: rawValue)!
  }
}

public extension OAuthSwiftHTTPRequest.Method {
  var alamofire: Alamofire.HTTPMethod {
    Alamofire.HTTPMethod(rawValue: rawValue)!
  }
}
