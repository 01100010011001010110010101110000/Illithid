// Copyright (C) 2020 Tyler Gregory (@01100010011001010110010101110000)
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of  MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <http://www.gnu.org/licenses/>.

import Foundation

// MARK: - GalleryDataItem

/// The object representing the ordered gallery view
/// - Note: `mediaId` should be tied back to the post's `MediaMetadata` to get the content for each item
public struct GalleryDataItem: Codable, Identifiable {
  // MARK: Lifecycle

  public init(id: Int, mediaId: String, caption: String?, outboundUrl: URL?) {
    self.id = id
    self.mediaId = mediaId
    self.caption = caption
    self.outboundUrl = outboundUrl
  }

  /// A convenience initializer when preparing a gallery item for upload
  ///
  /// - Parameters:
  ///   - mediaId: The `assetId` of the uploaded media after calling `Illithid.uploadMedia`
  ///   - caption: The caption of the gallery item
  ///   - outboundUrl: The URL the linked to by the gallery item's capton
  /// - Remark: The `id` parameter exists only when fetching an existing gallery post from reddit, it is not needed for gallery post creation
  public init(mediaId: String, caption: String?, outboundUrl: URL?) {
    id = 0
    self.mediaId = mediaId
    self.caption = caption
    self.outboundUrl = outboundUrl
  }

  // MARK: Public

  public let id: Int
  public let mediaId: String
  public let caption: String?
  public let outboundUrl: URL?

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(mediaId, forKey: .mediaId)
    try container.encode(caption, forKey: .caption)
    try container.encode(outboundUrl, forKey: .outboundUrl)
  }

  // MARK: Internal

  internal func asDictionary() -> [String: String] {
    [
      "media_id": mediaId,
      "caption": caption ?? "",
      "outbound_url": outboundUrl?.absoluteString ?? "",
    ]
  }

  // MARK: Private

  private enum CodingKeys: String, CodingKey {
    case id
    case mediaId = "media_id"
    case caption
    case outboundUrl = "outbound_url"
  }
}

// MARK: - GalleryData

public struct GalleryData: Codable {
  public let items: [GalleryDataItem]
}
