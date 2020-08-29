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
