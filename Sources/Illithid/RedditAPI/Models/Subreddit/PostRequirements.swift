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

// MARK: - PostRequirements

public struct PostRequirements: Codable {
  // MARK: Public

  // MARK: Body requirements

  public let bodyBlacklistedStrings: [String]
  public let bodyRegexes: [String]
  public let bodyRequiredStrings: [String]
  public let bodyRestrictionPolicy: BodyRestrictionPolicy
  public let bodyTextMaxLength: Int?
  public let bodyTextMinLength: Int?

  // MARK: Domain requirements

  public let domainBlacklist: [String]
  public let domainWhitelist: [String]

  // MARK: Gallery requirements

  public let galleryCaptionsRequirement: GalleryCaptionsRequirement
  public let galleryMaxItems: Int?
  public let galleryMinItems: Int?
  public let galleryUrlsRequirement: GalleryUrlsRequirement

  // MARK: Guidelines

  public let guidelinesDisplayPolicy: String?
  public let guidelinesText: String?

  // MARK: Flair requirements

  /// Whether a post is required to be flaired
  /// - Note: This setting is ignored if the subreddit has no configured flairs
  public let isFlairRequired: Bool

  // MARK: Link requirements

  public let linkRepostAge: Int?
  public let linkRestrictionPolicy: LinkRestrictionPolicy

  // MARK: Title requirements

  public let titleBlacklistedStrings: [String]
  public let titleRegexes: [String]
  public let titleRequiredStrings: [String]
  public let titleTextMaxLength: Int?
  public let titleTextMinLength: Int?

  public func validateSelfPost(title: String, body: String?) -> [ValidationFailure] {
    titleIsValid(title) + bodyIsValid(body)
  }

  public func validateLinkPost(title: String, link: URL) -> [ValidationFailure] {
    titleIsValid(title) + linkIsValid(link)
  }

  public func validateImagePost(title: String) -> [ValidationFailure] {
    titleIsValid(title)
  }

  public func validatePollPost(title: String) -> [ValidationFailure] {
    titleIsValid(title)
  }

  public func validateVideoPost(title: String) -> [ValidationFailure] {
    titleIsValid(title)
  }

  public func validateGalleryPost(title: String, items _: [GalleryDataItem]) -> [ValidationFailure] {
    titleIsValid(title)
  }

  // MARK: Private

  private enum CodingKeys: String, CodingKey {
    case bodyBlacklistedStrings = "body_blacklisted_strings"
    case bodyRegexes = "body_regexes"
    case bodyRequiredStrings = "body_required_strings"
    case bodyRestrictionPolicy = "body_restriction_policy"
    case bodyTextMaxLength = "body_text_max_length"
    case bodyTextMinLength = "body_text_min_length"
    case domainBlacklist = "domain_blacklist"
    case domainWhitelist = "domain_whitelist"
    case galleryCaptionsRequirement = "gallery_captions_requirement"
    case galleryMaxItems = "gallery_max_items"
    case galleryMinItems = "gallery_min_items"
    case galleryUrlsRequirement = "gallery_urls_requirement"
    case guidelinesDisplayPolicy = "guidelines_display_policy"
    case guidelinesText = "guidelines_text"
    case isFlairRequired = "is_flair_required"
    case linkRepostAge = "link_repost_age"
    case linkRestrictionPolicy = "link_restriction_policy"
    case titleBlacklistedStrings = "title_blacklisted_strings"
    case titleRegexes = "title_regexes"
    case titleRequiredStrings = "title_required_strings"
    case titleTextMaxLength = "title_text_max_length"
    case titleTextMinLength = "title_text_min_length"
  }

  private func titleIsValid(_ title: String) -> [ValidationFailure] {
    var failures: [ValidationFailure] = []
    if title.isEmpty {
      failures.append(.titleIsRequired)
    }
    if let minimum = titleTextMinLength, title.count < minimum {
      failures.append(.titleTooShort(minLength: minimum))
    } else if let maximum = titleTextMaxLength, title.count > maximum {
      failures.append(.titleTooLong(maxLength: maximum))
    }

    titleRequiredStrings.forEach { required in
      if title.range(of: required, options: .caseInsensitive) == nil {
        failures.append(.missingRequiredTitleString(string: required))
      }
    }
    titleBlacklistedStrings.forEach { banned in
      if title.range(of: banned, options: .caseInsensitive) != nil {
        failures.append(.titleContainsBannedString(string: banned))
      }
    }

    titleRegexes.forEach { pattern in
      guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { return }
      if regex.firstMatch(in: title, range: NSRange(location: 0, length: title.count)) == nil {
        failures.append(.missingTitleRegexMatch(regex: pattern))
      }
    }
    return failures
  }

  private func bodyIsValid(_ body: String?) -> [ValidationFailure] {
    var failures: [ValidationFailure] = []
    switch bodyRestrictionPolicy {
    case .none:
      break
    case .required:
      if body?.isEmpty ?? true { failures.append(.bodyIsRequired) }
    case .notAllowed:
      // We return here because other body restrictions are not meaningful if a body is not allowed
      if !(body?.isEmpty ?? false) { return [.bodyIsForbidden] }
    }

    if let minimum = bodyTextMinLength, (body?.count ?? 0) < minimum {
      failures.append(.bodyTooShort(minLength: minimum))
    } else if let maximum = bodyTextMaxLength, (body?.count ?? 0) > maximum {
      failures.append(.bodyTooLong(maxLength: maximum))
    }

    if bodyRestrictionPolicy == .required {
      bodyRequiredStrings.forEach { required in
        if body?.range(of: required, options: .caseInsensitive) == nil {
          failures.append(.missingRequiredBodyString(string: required))
        }
      }
    } else if bodyRestrictionPolicy == .none || bodyRestrictionPolicy == .required {
      // Reddit does not allow setting required strings when the body is optional
      bodyBlacklistedStrings.forEach { banned in
        if body?.range(of: banned, options: .caseInsensitive) != nil {
          failures.append(.bodyContainsBannedString(string: banned))
        }
      }
    }

    bodyRegexes.forEach { pattern in
      // OPTIMIZE: It may be worth constructing the NSRegularExpressions on decode, if it turns out this is too expensive
      guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { return }
      if regex.firstMatch(in: body ?? "", range: NSRange(location: 0, length: body?.count ?? 0)) == nil {
        failures.append(.missingBodyRegexMatch(regex: pattern))
      }
    }
    return failures
  }

  private func linkIsValid(_ url: URL) -> [ValidationFailure] {
    switch linkRestrictionPolicy {
    case .none:
      return []
    case .blacklist:
      guard let host = url.host else { return [ValidationFailure.invalidLink(link: url)] }
      if domainBlacklist.contains(host) { return [ValidationFailure.domainIsBlacklisted(domain: host)] }
    case .whitelist:
      guard let host = url.host else { return [ValidationFailure.invalidLink(link: url)] }
      if !domainWhitelist.contains(host) { return [ValidationFailure.domainIsNotWhitelisted(allowedDomains: domainWhitelist)] }
    }
    return []
  }
}

public extension PostRequirements {
  enum ValidationFailure {
    /// The subreddit requires a title on its posts
    /// - Note: This is not something configurable in a subreddit's settings, but all posts require a title
    case titleIsRequired
    case titleTooShort(minLength: Int)
    case titleTooLong(maxLength: Int)
    case titleContainsBannedString(string: String)
    case missingRequiredTitleString(string: String)
    case missingTitleRegexMatch(regex: String)

    case bodyIsForbidden
    case bodyIsRequired
    case bodyTooShort(minLength: Int)
    case bodyTooLong(maxLength: Int)
    case bodyContainsBannedString(string: String)
    case missingRequiredBodyString(string: String)
    case missingBodyRegexMatch(regex: String)

    case invalidLink(link: URL)
    case domainIsBlacklisted(domain: String)
    case domainIsNotWhitelisted(allowedDomains: [String])

    case missingFlair
  }

  enum BodyRestrictionPolicy: String, Codable {
    /// A self post body is optional
    case none
    /// A self post body is required
    case required
    /// A self post body is not allowed
    case notAllowed
  }

  enum LinkRestrictionPolicy: String, Codable {
    /// A link may be posted to any domain
    case none
    /// Links may only be posted to `domainWhitelist`
    case whitelist
    /// A link may be posted to any domain **except** those in `domainBlacklist`
    case blacklist
  }

  enum GalleryCaptionsRequirement: String, Codable {
    case none
  }

  enum GalleryUrlsRequirement: String, Codable {
    case none
  }
}
