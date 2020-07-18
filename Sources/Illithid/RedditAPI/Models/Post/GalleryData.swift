//
// GalleryData.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 7/16/20
//

import Foundation

/// The object representing the ordered gallery view. The Media IDs here should be tied back to the post's `MediaMetadata` to get the content for each item
public struct GalleryDataItem: Codable, Identifiable {
  public let id: Int
  public let mediaId: String
  public let caption: String?
  public let outboundUrl: URL?

  private enum CodingKeys: String, CodingKey {
    case id
    case mediaId = "media_id"
    case caption
    case outboundUrl = "outbound_url"
  }
}

public struct GalleryData: Codable {
  public let items: [GalleryDataItem]
}
