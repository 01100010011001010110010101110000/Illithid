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

// MARK: - NewPostResponse

public struct NewPostResponse: Codable {
  // MARK: Public

  public struct NewPostWrapper: Codable {
    // MARK: Public

    public let data: NewPostData
    public let errors: [[String]]

    // MARK: Private

    private enum CodingKeys: String, CodingKey {
      case data
      case errors
    }
  }

  public let json: NewPostWrapper

  // MARK: Private

  private enum CodingKeys: String, CodingKey {
    case json
  }
}

// MARK: - NewPostData

public struct NewPostData: Codable {
  // MARK: Public

  /// The ID of the new post
  /// - Note: `nil` when the post *is not* of type `link` or `self`
  public let id: ID36?
  /// The `Fullname` of the new post
  /// - Note: `nil` when the post *is not* of type `link` or `self`
  public let name: Fullname?
  public let draftCount: Int?
  /// The URL of the new post
  /// - Note: `nil` when the post *is not* of type `link` or `self`
  public let url: URL?
  /// The websocket URL for retrieving the status of the post
  /// - Note: `nil` when the post *is* of type `link` or `self`
  public let websocketUrl: URL?
  /// The URL linking to the user's submission page
  /// - Note: `nil` when the post *is* of type `link` or `self`
  public let userSubmittedPage: URL?

  // MARK: Private

  private enum CodingKeys: String, CodingKey {
    case id
    case name
    case url
    case draftCount = "drafts_count"
    case websocketUrl = "websocket_url"
    case userSubmittedPage = "user_submitted_page"
  }
}
