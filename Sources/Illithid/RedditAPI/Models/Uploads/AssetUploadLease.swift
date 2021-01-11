//
//  File.swift
//  
//
//  Created by Tyler Gregory on 1/10/21.
//

import Foundation

public struct AssetUploadLease: Decodable {
  let lease: AssetLease
  let asset: AssetDetails

  private enum CodingKeys: String, CodingKey {
    case asset
    case lease = "args"
  }

  struct AssetLease: Decodable {
    let uploadUrl: URL
    let parameters: [String: String]

    var retrievalUrl: URL? {
      guard let key = parameters["key"] else { return nil }
      uploadUrl.appendingPathComponent(key, isDirectory: false)
    }

    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      uploadUrl = try container.decode(URL.self, forKey: .uploadUrl)
      let fields = try container.decode([Field].self, forKey: .fields)
      parameters = fields.reduce(into: [String: String](), { result, field in
        result[field.name] = field.value
      })
    }

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
    let assetId: String
    let payload: AssetPayload
    let processingState: ProcessingState
    let websocketUrl: URL

    private enum CodingKeys: String, CodingKey {
      case assetId = "asset_id"
      case payload
      case processingState = "processing_state"
      case websocketUrl = "websocket_url"
    }

    enum ProcessingState: String, Decodable {
      case incomplete
      case complete
    }
  }

  struct AssetPayload: Decodable {
    let filePath: String

    private enum CodingKeys: String, CodingKey {
      case filePath = "filepath"
    }
  }
}
