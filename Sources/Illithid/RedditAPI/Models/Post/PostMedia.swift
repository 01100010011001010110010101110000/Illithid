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

public struct PostMedia: Codable {
  // MARK: Public

  public struct RedditVideo: Codable {
    // MARK: Public

    public enum TranscodeStatus: String, Codable {
      case completed
    }

    public let dashUrl: URL
    public let duration: Int
    public let fallbackUrl: URL
    public let height: Int
    public let hlsUrl: URL
    public let isGif: Bool
    public let scrubberMediaUrl: URL
    public let transcodingStatus: TranscodeStatus
    public let width: Int

    // MARK: Private

    private enum CodingKeys: String, CodingKey {
      case dashUrl = "dash_url"
      case duration
      case fallbackUrl = "fallback_url"
      case height
      case hlsUrl = "hls_url"
      case isGif = "is_gif"
      case scrubberMediaUrl = "scrubber_media_url"
      case transcodingStatus = "transcoding_status"
      case width
    }
  }

  public struct EmbeddingParameters: Codable {
    // MARK: Public

    public let providerUrl: URL
    public let title: String?
    public let type: String
    public let html: String
    public let thumbnailWidth: Int?
    public let thumbnailHeight: Int?
    public let height: Int?
    public let width: Int
    public let version: String
    public let authorName: String?
    public let providerName: String
    public let authorUrl: URL?

    // MARK: Private

    private enum CodingKeys: String, CodingKey {
      case providerUrl = "provider_url"
      case title
      case type
      case html
      case thumbnailWidth = "thumbnail_width"
      case thumbnailHeight = "thumbnail_height"
      case height
      case width
      case version
      case authorName = "author_name"
      case providerName = "provider_name"
      case authorUrl = "author_url"
    }
  }

  public let type: String?
  public let oembed: EmbeddingParameters?
  public let redditVideo: RedditVideo?

  // MARK: Private

  private enum CodingKeys: String, CodingKey {
    case type
    case oembed
    case redditVideo = "reddit_video"
  }
}
