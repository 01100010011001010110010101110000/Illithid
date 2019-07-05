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
  public var description: String {
    switch self {
    case .all: return "all"
    default: return ""
    }
  }

  case all
  case filtered
}

/// The `Kind` of Reddit object, with additional types which appear in the kind field in certain special cases
/// - SeeAlso: [Reddit's type prefixes documentation](https://www.reddit.com/dev/api#fullnames)
public enum Kind: String, Codable {
  case comment = "t1"
  case account = "t2"
  case post = "t3"
  case message = "t4"
  case subreddit = "t5"
  case award = "t6"
  /// A special case of `Kind` used when the comments in a `Comment`'s `replies` field are collapsed
  case more
  /// The `Listing` container which wraps arrays of the other `Kind`s
  case listing = "Listing"
}

/// The interval to use when sorting comments or posts by `top`
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

/// The URL parameters which are applicable to all Listing endpoints in the Reddit API
/// - Parameters:
///     - after: The [`fullname`](https://www.reddit.com/dev/api#fullnames) of the Reddit Object to use as an anchor to fetch the next slice of the listing
///     - before: The [`fullname`](https://www.reddit.com/dev/api#fullnames) of the Reddit Object to use as an anchor to fetch the previous slice of the listing
///     - include_categories: If `true`, include category information on the returned objects
///     - limit: The number of objects to fetch from the listing
///     - show: Whether to bypass filters such as hiding previously visited posts; defaults to filtered
///     - raw_json: If false, HTML escape `<`, `>`, and `&`. [This is forbackwards compatability](https://www.reddit.com/dev/api#response_body_encoding)
/// - SeeAlso: [Reddit's Listing documentation](https://www.reddit.com/dev/api#listings)
public struct ListingParameters {
  public var after: String
  public var before: String
  public var includeCategories: Bool
  public var limit: Int
  public var show: ShowAllPreference
  public var rawJSON: Bool

  public init(after: String = "", before: String = "", includeCategories: Bool = true,
              limit: Int = 25, show: ShowAllPreference = .filtered, rawJSON: Bool = true) {
    self.after = after
    self.before = before
    self.includeCategories = includeCategories
    self.limit = limit
    self.show = show
    self.rawJSON = rawJSON
  }

  public func toParameters() -> Parameters {
    var result: [String: Any] = [:]
    let mirror = Mirror(reflecting: self)
    for (property, value) in mirror.children {
      guard let property = property else { continue }
      let key = property.snakeCased() ?? property
      result[key] = value
    }
    return result
  }
}

/// The base36, non-kind qualified, ID of a Reddit object. IDs are guaranteed to be unique within a `Kind` type
/// - SeeAlso: [Reddit's type fullnames documentation](https://www.reddit.com/dev/api#fullnames)
public typealias ID36 = String
/// The ID36 of an object fully qualifies by prepending it with its type, e.g. `t3_15bfi0`
/// - SeeAlso: [Reddit's type fullnames documentation](https://www.reddit.com/dev/api#fullnames)
public typealias Fullname = String
/// The base class for all user-generated content on Reddit
public protocol RedditObject: Codable, Identifiable, Hashable {
  /// The object's unique identifier
  var id: String { get } // swiftlint:disable:this identifier_name

  /// The object's full name
  var name: String { get }

  /// The object's type as defined by the Reddit API
  /// e.g. "t5"
  var type: String { get }
}
