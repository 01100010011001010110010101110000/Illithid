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

public typealias Moderator = User

// MARK: - User

public struct User: Codable, Identifiable {
  // MARK: Public

  public let name: String
  public let authorFlairText: String?
  public let modPermissions: [String]
  public let date: Date
  public let relId: String
  public let id: Fullname
  public let authorFlairCssClass: String?

  // MARK: Private

  private enum CodingKeys: String, CodingKey {
    case name
    case authorFlairText = "author_flair_text"
    case modPermissions = "mod_permissions"
    case date
    case relId = "rel_id"
    case id
    case authorFlairCssClass = "author_flair_css_class"
  }
}

// MARK: - UserList

internal struct UserList: Codable {
  // MARK: Internal

  let kind: String

  var users: [User] {
    data.children
  }

  // MARK: Fileprivate

  fileprivate struct UserListData: Codable {
    let children: [User]
  }

  fileprivate let data: UserListData
}
