import Foundation

import Alamofire


/// Object representing the structure of the gif object from RedGif's v2 API
/// - See: https://github.com/Redgifs/api/wiki/2021-upgrade
public struct RedGif: Codable {
  public let gif: Gif
  public let user: User

  enum CodingKeys: String, CodingKey {
    case gif = "gif"
    case user = "user"
  }

  public init(gif: Gif, user: User) {
    self.gif = gif
    self.user = user
  }
}

extension RedGif {
  // MARK: - GIF
  public struct Gif: Codable {
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

    enum CodingKeys: String, CodingKey {
      case id = "id"
      case createDate = "createDate"
      case hasAudio = "hasAudio"
      case width = "width"
      case height = "height"
      case likes = "likes"
      case tags = "tags"
      case verified = "verified"
      case views = "views"
      case duration = "duration"
      case published = "published"
      case urls = "urls"
      case userName = "userName"
      case type = "type"
      case avgColor = "avgColor"
      case gallery = "gallery"
    }

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

    // MARK: - RedGif.Gif.Urls
    public struct Urls: Codable {
      public let sd: URL
      public let hd: URL
      public let gif: URL
      public let poster: URL
      public let thumbnail: URL
      public let videoThumbnail: URL

      enum CodingKeys: String, CodingKey {
        case sd = "sd"
        case hd = "hd"
        case gif = "gif"
        case poster = "poster"
        case thumbnail = "thumbnail"
        case videoThumbnail = "vthumbnail"
      }

      public init(sd: URL, hd: URL, gif: URL, poster: URL, thumbnail: URL, videoThumbnail: URL) {
        self.sd = sd
        self.hd = hd
        self.gif = gif
        self.poster = poster
        self.thumbnail = thumbnail
        self.videoThumbnail = videoThumbnail
      }
    }
  }

  // MARK: - RedGif.User
  public struct User: Codable {
    public let creationTime: Date
    public let followers: Int
    public let following: Int
    public let gifs: Int
    public let name: String
    public let profileImageUrl: URL?
    public let profileUrl: URL
    public let publishedGifs: Int
    public let subscription: Int
    public let url: URL
    public let username: String
    public let verified: Bool
    public let views: Int
    public let poster: URL
    public let preview: URL
    /// The GIF ID of the user's profile's thumbnail GIF
    public let thumbnail: String

    enum CodingKeys: String, CodingKey {
      case creationTime = "creationtime"
      case followers = "followers"
      case following = "following"
      case gifs = "gifs"
      case name = "name"
      case profileImageUrl = "profileImageUrl"
      case profileUrl = "profileUrl"
      case publishedGifs = "publishedGifs"
      case subscription = "subscription"
      case url = "url"
      case username = "username"
      case verified = "verified"
      case views = "views"
      case poster = "poster"
      case preview = "preview"
      case thumbnail = "thumbnail"
    }

    public init(creationTime: Date, followers: Int, following: Int, gifs: Int, name: String, profileImageUrl: URL?,
                profileUrl: URL, publishedGifs: Int, subscription: Int, url: URL, username: String,
                verified: Bool, views: Int, poster: URL, preview: URL, thumbnail: String) {
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
  }
}
