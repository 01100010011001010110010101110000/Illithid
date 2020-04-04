//
// MirrorableEnum.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 4/4/20
//

protocol MirrorableEnum {}

extension MirrorableEnum {
  var mirror: (route: String, parameters: [String: Any]) {
    let reflection = Mirror(reflecting: self)
    guard reflection.displayStyle == .enum, let associated = reflection.children.first else {
      return ("\(self)", [:])
    }
    let values = Mirror(reflecting: associated.value).children
    var params: [String: Any] = [:]
    for case let param in values {
      guard let label = param.label else { continue }
      params[label] = param.value
    }
    return ("\(self)", params)
  }
}
