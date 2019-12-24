public protocol PostsProvider {
  func posts(sortBy sort: PostSort, location: Location?,
             topInterval: TopInterval?, parameters: ListingParameters, completion: @escaping (Result<Listing, Error>) -> Void)
}

public extension PostsProvider {
  func posts(sortBy sort: PostSort, location: Location? = nil,
             topInterval: TopInterval? = nil, parameters: ListingParameters, completion: @escaping (Result<Listing, Error>) -> Void) {
    posts(sortBy: sort, location: location, topInterval: topInterval, parameters: parameters, completion: completion)
  }
}
