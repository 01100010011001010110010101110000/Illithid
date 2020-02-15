//
// GfyItem.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 1/13/20
//

import Foundation

import Alamofire

import Alamofire
import Foundation

// MARK: - GfyItem

public struct GfyWrapper: Codable, Hashable, Equatable {
  public let item: GfyItem

  public static func == (lhs: GfyWrapper, rhs: GfyWrapper) -> Bool {
    lhs.item == rhs.item
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(item)
  }

  enum CodingKeys: String, CodingKey {
    case item = "gfyItem"
  }
}

public struct GfyItem: Codable, Hashable, Equatable {
  public static func == (lhs: GfyItem, rhs: GfyItem) -> Bool {
    lhs.gfyId == rhs.gfyId
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(gfyId)
  }

  public let tags: [String]
  public let languageCategories: [String]
  public let domainWhitelist: [String]
  public let geoWhitelist: [String]
  public let published: Int
  public let nsfw: String
  public let gatekeeper: Int
  public let mp4URL: URL
  public let gifURL: URL
  public let webmURL: URL
  public let webpURL: URL
  public let mobileURL: URL
  public let mobilePosterURL: URL
  public let extraLemmas: String
  public let thumb100PosterURL: URL
  public let miniURL: URL
  public let gif100Px: String
  public let miniPosterURL: URL
  public let max5MBGIF: String
  public let title: String
  public let max2MBGIF: URL
  public let max1MBGIF: URL
  public let posterURL: URL
  public let languageText: String
  public let views: Int
  public let userName: String
  public let gfyItemDescription: String
  public let hasTransparency: Bool
  public let hasAudio: Bool
  public let likes: String
  public let dislikes: String
  public let gfyNumber: String
  public let gfyId: String
  public let gfyName: String
  public let avgColor: String
  public let gfySlug: String?
  public let width: Int
  public let height: Int
  public let frameRate: Double
  public let numFrames: Int
  public let mp4Size: Int
  public let webmSize: Int
  public let createDate: Date
  public let md5: String?
  public let source: Int
  public let contentUrls: [String: Content]

  enum CodingKeys: String, CodingKey {
    case tags
    case languageCategories
    case domainWhitelist
    case geoWhitelist
    case published
    case nsfw
    case gatekeeper
    case mp4URL = "mp4Url"
    case gifURL = "gifUrl"
    case webmURL = "webmUrl"
    case webpURL = "webpUrl"
    case mobileURL = "mobileUrl"
    case mobilePosterURL = "mobilePosterUrl"
    case extraLemmas
    case thumb100PosterURL = "thumb100PosterUrl"
    case miniURL = "miniUrl"
    case gif100Px = "gif100px"
    case miniPosterURL = "miniPosterUrl"
    case max5MBGIF = "max5mbGif"
    case title
    case max2MBGIF = "max2mbGif"
    case max1MBGIF = "max1mbGif"
    case posterURL = "posterUrl"
    case languageText
    case views
    case userName
    case gfyItemDescription = "description"
    case hasTransparency
    case hasAudio
    case likes
    case dislikes
    case gfyNumber
    case gfyId
    case gfyName
    case avgColor
    case gfySlug
    case width
    case height
    case frameRate
    case numFrames
    case mp4Size
    case webmSize
    case createDate
    case md5
    case source
    case contentUrls = "content_urls"
  }
}

// MARK: - ContentURL

public struct Content: Codable, Hashable {
  public let url: URL
  public let size: Int
  public let height: Int
  public let width: Int

  enum CodingKeys: String, CodingKey {
    case url
    case size
    case height
    case width
  }
}
