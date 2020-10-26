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

// MARK: - Preview

public struct Preview: Codable {
  // MARK: - ImagePreview

  public struct ImagePreview: Codable, Identifiable {
    public let source: Source
    public let resolutions: [Source]
    public let variants: Variants?
    public let id: String
  }

  // MARK: - RedditVideoPreview

  public struct RedditVideoPreview: Codable {
    public let fallbackUrl: URL
    public let height, width: Int
    public let scrubberMediaUrl: URL
    public let dashUrl: URL
    public let duration: Int
    public let hlsUrl: URL
    public let isGif: Bool
    public let transcodingStatus: String
  }

  // MARK: - VariantsClass

  public struct Variants: Codable {
    public let obfuscated: PreviewVariant?
    public let gif: PreviewVariant?
    public let mp4: PreviewVariant?
    public let nsfw: PreviewVariant?
  }

  // MARK: - GIF

  public struct PreviewVariant: Codable {
    public let source: Source
    public let resolutions: [Source]
  }

  // MARK: - Source

  public struct Source: Codable {
    // MARK: Lifecycle

    public init(url: URL, width: Int, height: Int) {
      self.url = url
      self.width = width
      self.height = height
    }

    // MARK: Public

    public let url: URL
    public let width: Int
    public let height: Int
  }

  public let images: [ImagePreview]
  public let redditVideoPreview: RedditVideoPreview?
  public let enabled: Bool
}
