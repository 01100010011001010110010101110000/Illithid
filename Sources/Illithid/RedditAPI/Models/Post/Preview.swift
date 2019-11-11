//
//  Preview.swift
//  Illithid
//
//  Created by Tyler Gregory on 5/29/19.
//  Copyright © 2019 flayware. All rights reserved.
//

import Foundation

// MARK: - Preview

public struct Preview: Codable {
  public let images: [ImagePreview]
  public let enabled: Bool
}

// MARK: - Image

public struct ImagePreview: Codable {
  public let source: Image
  public let resolutions: [Image]
  public let variants: Variants
  public let id: String

  public struct Image: Codable {
    public let url: URL
    public let width: Int
    public let height: Int
  }
}

// MARK: - Variants

public struct Variants: Codable {}
