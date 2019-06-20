//
//  RedditBaseClass.swift
//  Illithid
//
//  Created by Tyler Gregory on 1/18/19.
//  Copyright © 2019 flayware. All rights reserved.
//

import Foundation
import SwiftUI

import Alamofire

public enum ShowAllPreference: CustomStringConvertible {
  public
  var description: String {
      switch self {
      case .all: return "all"
      default: return ""
    }
  }

  case all
  case filtered
}

public enum TopInterval {
  case hour
  case day
  case week
  case month
  case year
  case all
}

public enum Location {
  case GLOBAL
  case US
  case AR
  case AU
  case BG
  case CA
  case CL
  case CO
  case HR
  case CZ
  case FI
  case GR
  case HU
  case IS
  case IN
  case IE
  case JP
  case MY
  case MX
  case NZ
  case PH
  case PL
  case PT
  case PR
  case RO
  case RS
  case SG
  case SE
  case TW
  case TH
  case TR
  case GB
  case US_WA
  case US_DE
  case US_DC
  case US_WI
  case US_WV
  case US_HI
  case US_FL
  case US_WY
  case US_NH
  case US_NJ
  case US_NM
  case US_TX
  case US_LA
  case US_NC
  case US_ND
  case US_NE
  case US_TN
  case US_NY
  case US_PA
  case US_CA
  case US_NV
  case US_VA
  case US_CO
  case US_AK
  case US_AL
  case US_AR
  case US_VT
  case US_IL
  case US_GA
  case US_IN
  case US_IA
  case US_OK
  case US_AZ
  case US_ID
  case US_CT
  case US_ME
  case US_MD
  case US_MA
  case US_OH
  case US_UT
  case US_MO
  case US_MN
  case US_MI
  case US_RI
  case US_KS
  case US_MT
  case US_MS
  case US_SC
  case US_KY
  case US_OR
  case US_SD
}

public struct ListingParams {
  public var after: String = ""
  public var before: String = ""
  public var count: Int = 0
  public var include_categories: Bool = false
  public var limit: Int = 25
  public var show: ShowAllPreference = .filtered
  public var sr_detail: Bool = false
  public var raw_json: Bool = true

  public init() {}

  public func toParameters() -> Parameters {
    var result: [String: Any] = [:]
    let mirror = Mirror(reflecting: self)
    for (property, value) in mirror.children {
      guard let property = property else { continue }
      result[property] = value
    }
    return result
  }
}

typealias ID36 = String
/// The base class for all user-generated content on Reddit
public protocol RedditObject: Codable, Equatable, Identifiable, Hashable {
  /// The object's unique identifier
  var id: String { get } // swiftlint:disable:this identifier_name

  /// The object's full name
  var name: String { get }

  /// The object's type as defined by the Reddit API
  /// e.g. "t5"
  var type: String { get }
}
