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

#if canImport(Combine)
  import Combine
#endif
import Foundation

import Alamofire

// MARK: - PostAcceptorType

public enum PostAcceptorType {
  case account(Account)
  case subreddit(Subreddit)
}

// MARK: - PostAcceptor

public protocol PostAcceptor {
  /// The name of the target subreddit when submitting the post to the Reddit API (i.e. the value of the `sr` field)
  var uploadTarget: String { get }

  var displayName: String { get }

  var permitsSelfPosts: Bool { get }

  var permitsImagePosts: Bool { get }

  var permitsGalleryPosts: Bool { get }

  var permitsVideoPosts: Bool { get }

  var permitsGifPosts: Bool { get }

  var permitsLinkPosts: Bool { get }

  var permitsPollPosts: Bool { get }
}
