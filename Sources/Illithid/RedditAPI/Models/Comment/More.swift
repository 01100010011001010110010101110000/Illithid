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

public struct More: RedditObject {
  public let count: Int
  public let name: Fullname
  public let id: ID36
  public let parentId: Fullname
  public let depth: Int
  public let children: [ID36]

  public static let continueThreadId = "_"

  private enum CodingKeys: String, CodingKey {
    case count
    case name
    case id
    case parentId = "parent_id"
    case depth
    case children
  }
}

/// Data structure returned from `/api/morechildren`
internal struct MoreChildren: Codable {
  fileprivate let json: Json

  public var comments: [Comment] {
    json.data.things.compactMap { thing in
      if case let Listing.Content.comment(comment) = thing { return comment }
      else { return nil }
    }
  }

  public var more: More? {
    for thing in json.data.things {
      if case let Listing.Content.more(more) = thing { return more }
    }
    return nil
  }

  fileprivate struct Json: Codable {
    public let errors: [String]
    public let data: Data

    fileprivate struct Data: Codable {
      public let things: [Listing.Content]
    }
  }
}
