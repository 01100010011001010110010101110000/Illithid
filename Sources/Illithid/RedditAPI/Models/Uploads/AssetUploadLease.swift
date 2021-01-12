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

public struct AssetUploadLease: Decodable {
  // MARK: Internal

  struct AssetLease: Decodable {
    // MARK: Lifecycle

    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      uploadUrl = try container.decode(URL.self, forKey: .uploadUrl)
      let fields = try container.decode([Field].self, forKey: .fields)
      parameters = fields.reduce(into: [String: String](), { result, field in
        result[field.name] = field.value
      })
    }

    // MARK: Internal

    let uploadUrl: URL
    let parameters: [String: String]

    var retrievalUrl: URL? {
      guard let key = parameters["key"] else { return nil }
      return uploadUrl.appendingPathComponent(key, isDirectory: false)
    }

    // MARK: Private

    private enum CodingKeys: String, CodingKey {
      case uploadUrl = "action"
      case fields
    }

    private struct Field: Decodable {
      let name: String
      let value: String
    }
  }

  struct AssetDetails: Decodable {
    // MARK: Internal

    enum ProcessingState: String, Decodable {
      case incomplete
      case complete
    }

    let assetId: String
    let payload: AssetPayload
    let processingState: ProcessingState
    let websocketUrl: URL

    // MARK: Private

    private enum CodingKeys: String, CodingKey {
      case assetId = "asset_id"
      case payload
      case processingState = "processing_state"
      case websocketUrl = "websocket_url"
    }
  }

  struct AssetPayload: Decodable {
    // MARK: Internal

    let filePath: String

    // MARK: Private

    private enum CodingKeys: String, CodingKey {
      case filePath = "filepath"
    }
  }

  let lease: AssetLease
  let asset: AssetDetails

  // MARK: Private

  private enum CodingKeys: String, CodingKey {
    case asset
    case lease = "args"
  }
}
