//
//  Preview.swift
//  Illithid
//
//  Created by Tyler Gregory on 5/29/19.
//  Copyright © 2019 flayware. All rights reserved.
//

import Foundation

// MARK: - Preview

struct Preview: Codable {
  let images: [ImagePreview]
  let enabled: Bool
}

// MARK: - Image

struct ImagePreview: Codable {
  let source: Image
  let resolutions: [Image]
  let variants: Variants
  let id: String
  
  struct Image: Codable {
    let url: URL
    let width: Int
    let height: Int
  }
}

// MARK: - Variants

struct Variants: Codable {}
