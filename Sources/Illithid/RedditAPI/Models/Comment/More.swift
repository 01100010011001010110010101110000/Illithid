//
// More.swift
// Copyright (c) 2019 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 12/24/19
//

import Foundation

public struct More: RedditObject {
  public let count: Int
  public let name: String
  public let id: ID36
  public let parentId: String
  public let depth: Int
  public let children: [ID36]
}
