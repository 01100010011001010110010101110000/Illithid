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

/// Whether the flair is plaintext or richtext
public enum FlairType: String, Codable {
  case text
  case richtext
}

/// A richtext chunk containing either plaintext, or an emoji and its URL
public struct FlairRichtext: Codable {
  public enum RichtextType: String, Codable {
    case text
    case emoji
  }

  public let emojiShortcode: String?
  public let emojiUrl: URL?
  public let type: RichtextType
  public let text: String?

  enum CodingKeys: String, CodingKey {
    case type = "e"
    case text = "t"
    case emojiShortcode = "a"
    case emojiUrl = "u"
  }
}
