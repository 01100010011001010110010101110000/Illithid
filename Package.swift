// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Illithid",
  platforms: [
    .macOS("10.15")
  ],
  products: [
    .library(
      name: "Illithid",
      targets: ["Illithid", "Ulithari"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire.git", from: .init(5, 0, 5)),
    .package(url: "https://github.com/OAuthSwift/OAuthSwift.git", from: .init(2, 1, 0)),
    .package(url: "https://github.com/Nike-Inc/Willow.git", from: .init(6, 0, 0)),
    .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: .init(4, 1, 0))
  ],
  targets: [
    .target(
      name: "Illithid",
      dependencies: [
        .product(name: "Alamofire"),
        .product(name: "OAuthSwift"),
        .product(name: "Willow"),
        .product(name: "KeychainAccess")
      ]
    ),
    .testTarget(
      name: "IllithidTests",
      dependencies: ["Illithid"]
    ),
    .target(name: "Ulithari", dependencies: [
      .product(name: "Alamofire")
    ])
  ],
  swiftLanguageVersions: [.v5]
)
