//
//  MediaEmbed.swift
//  Illithid
//
//  Created by Tyler Gregory on 5/2/19.
//  Copyright © 2019 flayware. All rights reserved.
//

import Foundation

struct MediaEmbed: Codable {
  let type: String
  let oembed: EmbeddingParameters
  
  struct EmbeddingParameters: Codable {
    let provider_url: URL
    let title: String
    let type: String
    let html: String
    let thumbnail_width: Int
    let thumbnail_height: Int
    let height: Int
    let width: Int
    let version: String
    let author_name: String?
    let provider_name: String
    let author_url: URL?
  }
}
