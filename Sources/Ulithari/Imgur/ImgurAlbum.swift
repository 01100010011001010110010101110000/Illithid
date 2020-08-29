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

// MARK: - ImgurAlbum

internal struct ImgurAlbumWrapper: Codable {
  public let data: ImgurAlbum
  public let success: Bool
  public let status: Int

  public init(data: ImgurAlbum, success: Bool, status: Int) {
    self.data = data
    self.success = success
    self.status = status
  }
}

// MARK: - AlbumData

public struct ImgurAlbum: Codable, Identifiable {
  public let id: String
  public let title: String?
  public let dataDescription: String?
  public let datetime: Int
  public let cover: String
  public let coverEdited: Bool?
  public let coverWidth: Int
  public let coverHeight: Int
  public let accountUrl: URL?
  public let accountId: String?
  public let privacy: String
  public let layout: String
  public let views: Int
  public let link: String
  public let favorite: Bool
  public let nsfw: Bool
  public let section: String
  public let imagesCount: Int
  public let inGallery: Bool
  public let isAd: Bool
  public let includeAlbumAds: Bool
  public let isAlbum: Bool
  public let images: [ImgurImage]

  enum CodingKeys: String, CodingKey {
    case id, title
    case dataDescription = "description"
    case datetime, cover
    case coverEdited = "cover_edited"
    case coverWidth = "cover_width"
    case coverHeight = "cover_height"
    case accountUrl = "account_url"
    case accountId = "account_id"
    case privacy, layout, views, link, favorite, nsfw, section
    case imagesCount = "images_count"
    case inGallery = "in_gallery"
    case isAd = "is_ad"
    case includeAlbumAds = "include_album_ads"
    case isAlbum = "is_album"
    case images
  }
}
