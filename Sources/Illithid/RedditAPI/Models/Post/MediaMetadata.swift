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

/// The object describing an item in a gallery `Post`
public struct MediaMetadata: Codable {
  public enum MediaType: String, Codable {
    case image = "Image"
    case animatedImage = "AnimatedImage"
  }

  public enum Status: String, Codable {
    case valid
  }

  /// The source attributes of a gallery item
  public struct MediaSource: Codable {
    public let width: Int
    public let height: Int
    public let url: URL?
    /// The URL of the item's GIF if the gallery item is a `MediaType.animatedImage`
    public let gif: URL?
    /// The URL of the item's MP4 if the gallery item is a `MediaType.animatedImage`
    public let mp4: URL?

    private enum CodingKeys: String, CodingKey {
      case width = "x"
      case height = "y"
      case url = "u"
      case gif
      case mp4
    }
  }

  public let id: String
  public let status: Status
  public let type: MediaType
  public let mimeType: String
  public let previews: [MediaSource]
  public let source: MediaSource

  private enum CodingKeys: String, CodingKey {
    case id
    case status
    case type = "e"
    case mimeType = "m"
    case previews = "p"
    case source = "s"
  }
}
