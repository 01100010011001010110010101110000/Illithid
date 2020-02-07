//
// More.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 12/24/19
//

import Foundation

public struct More: RedditObject {
  public let count: Int
  public let name: Fullname
  public let id: ID36
  public let parentId: Fullname
  public let depth: Int
  public let children: [ID36]
}
