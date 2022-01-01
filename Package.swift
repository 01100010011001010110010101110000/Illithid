// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Illithid",
  platforms: [
    .macOS(.v10_15),
  ],
  products: [
    .library(
      name: "Illithid",
      targets: ["Illithid", "Ulithari"]
    ),
  ],
  dependencies: [
    .package(name: "Alamofire", url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: Version(5, 5, 0))),
    .package(name: "OAuthSwift", url: "https://github.com/OAuthSwift/OAuthSwift.git", .revision("8e62dc0243de97e37640e97fd0641fad4dbe6e1f")),
    .package(name: "Willow", url: "https://github.com/Nike-Inc/Willow.git", .upToNextMajor(from: Version(6, 0, 0))),
    .package(name: "KeychainAccess", url: "https://github.com/kishikawakatsumi/KeychainAccess.git", .upToNextMajor(from: Version(4, 2, 2))),
    .package(name: "swift-collections", url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: Version(1, 0, 0))),
  ],
  targets: [
    .target(
      name: "Illithid",
      dependencies: [
        .product(name: "Alamofire", package: "Alamofire"),
        .product(name: "OAuthSwift", package: "OAuthSwift"),
        .product(name: "Willow", package: "Willow"),
        .product(name: "KeychainAccess", package: "KeychainAccess"),
        .product(name: "OrderedCollections", package: "swift-collections"),
      ]
    ),
    .testTarget(
      name: "IllithidTests",
      dependencies: ["Illithid"]
    ),
    .testTarget(
      name: "UlithariTests",
      dependencies: ["Ulithari"]
    ),
    .target(
      name: "Ulithari",
      dependencies: [.product(name: "Alamofire", package: "Alamofire")]
    ),
  ],
  swiftLanguageVersions: [.v5]
)
