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

import Alamofire

// MARK: - RedGif

/// Object representing the structure of the gif object from RedGif's v2 API
/// - See: https://github.com/Redgifs/api/wiki/2021-upgrade
public struct RedGif: Codable {
  // MARK: Lifecycle

  public init(gif: Gif, user: User) {
    self.gif = gif
    self.user = user
  }

  // MARK: Public

  public let gif: Gif
  public let user: User

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case gif
    case user
  }
}

public extension RedGif {
  // MARK: - GIF

  struct Gif: Codable {
    // MARK: Lifecycle

    public init(id: String, createDate: Date, hasAudio: Bool, width: Int, height: Int, likes: Int, tags: [String],
                verified: Bool, views: Int, duration: Int, published: Bool, urls: Urls, userName: String,
                type: Int, avgColor: String, gallery: String?) {
      self.id = id
      self.createDate = createDate
      self.hasAudio = hasAudio
      self.width = width
      self.height = height
      self.likes = likes
      self.tags = tags
      self.verified = verified
      self.views = views
      self.duration = duration
      self.published = published
      self.urls = urls
      self.userName = userName
      self.type = type
      self.avgColor = avgColor
      self.gallery = gallery
    }

    // MARK: Public

    // MARK: - RedGif.Gif.Urls

    public struct Urls: Codable {
      // MARK: Lifecycle

      public init(sd: URL, hd: URL, gif: URL, poster: URL, thumbnail: URL, videoThumbnail: URL) {
        self.sd = sd
        self.hd = hd
        self.gif = gif
        self.poster = poster
        self.thumbnail = thumbnail
        self.videoThumbnail = videoThumbnail
      }

      // MARK: Public

      public let sd: URL
      public let hd: URL
      public let gif: URL
      public let poster: URL
      public let thumbnail: URL
      public let videoThumbnail: URL

      // MARK: Internal

      enum CodingKeys: String, CodingKey {
        case sd
        case hd
        case gif
        case poster
        case thumbnail
        case videoThumbnail = "vthumbnail"
      }
    }

    public let id: String
    public let createDate: Date
    public let hasAudio: Bool
    public let width: Int
    public let height: Int
    public let likes: Int
    public let tags: [String]
    public let verified: Bool
    public let views: Int
    public let duration: Int
    public let published: Bool
    public let urls: Urls
    public let userName: String
    public let type: Int
    /// Hex triplet color code
    /// - Note: Prepended with a #
    public let avgColor: String
    public let gallery: String?

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
      case id
      case createDate
      case hasAudio
      case width
      case height
      case likes
      case tags
      case verified
      case views
      case duration
      case published
      case urls
      case userName
      case type
      case avgColor
      case gallery
    }
  }

  // MARK: - RedGif.User

  struct User: Codable {
    // MARK: Lifecycle

    public init(creationTime: Date, followers: Int, following: Int, gifs: Int, name: String?, profileImageUrl: URL?,
                profileUrl: URL, publishedGifs: Int, subscription: Int, url: URL, username: String,
                verified: Bool, views: Int, poster: URL?, preview: URL?, thumbnail: String?) {
      self.creationTime = creationTime
      self.followers = followers
      self.following = following
      self.gifs = gifs
      self.name = name
      self.profileImageUrl = profileImageUrl
      self.profileUrl = profileUrl
      self.publishedGifs = publishedGifs
      self.subscription = subscription
      self.url = url
      self.username = username
      self.verified = verified
      self.views = views
      self.poster = poster
      self.preview = preview
      self.thumbnail = thumbnail
    }

    // MARK: Public

    public let creationTime: Date
    public let followers: Int
    public let following: Int
    public let gifs: Int
    /// The display name of the user who posted the GIF
    public let name: String?
    public let profileImageUrl: URL?
    public let profileUrl: URL
    public let publishedGifs: Int
    public let subscription: Int
    public let url: URL
    /// The username of the user who posted the GIF
    public let username: String
    public let verified: Bool
    public let views: Int
    public let poster: URL?
    public let preview: URL?
    /// The GIF ID of the user's profile's thumbnail GIF
    public let thumbnail: String?

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
      case creationTime = "creationtime"
      case followers
      case following
      case gifs
      case name
      case profileImageUrl
      case profileUrl
      case publishedGifs
      case subscription
      case url
      case username
      case verified
      case views
      case poster
      case preview
      case thumbnail
    }
  }
}
