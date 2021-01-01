//
//  File.swift
//  
//
//  Created by Tyler Gregory on 1/1/21.
//

import Foundation

public struct NewPostResponse: Codable {
  let json: NewPostWrapper

  enum CodingKeys: String, CodingKey {
    case json
  }

  struct NewPostWrapper: Codable {
    let data: NewPostData
    let errors: [[String]]

    enum CodingKeys: String, CodingKey {
      case data
      case errors
    }
  }
}

public struct NewPostData: Codable {
  let id: ID36
  let name: Fullname
  let draftCount: Int
  let url: URL

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case url
    case draftCount = "drafts_count"
  }
}
