// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Illithid",
    platforms: [
      .macOS("10.15")
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Illithid",
            targets: ["Illithid"]),
    ],
    dependencies: [
      .package(url: "https://github.com/Alamofire/Alamofire.git", from: .init(4, 9, 1)),
      .package(url: "https://github.com/Alamofire/AlamofireImage.git", from: .init(3, 6, 0)),
      .package(url: "https://github.com/OAuthSwift/OAuthSwift.git", from: .init(2, 1, 0)),
      .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: .init(5, 0, 0)),
      .package(url: "https://github.com/Nike-Inc/Willow.git", from: .init(6, 0, 0)),
      .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: .init(4, 1, 0))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Illithid",
            dependencies: [
              .product(name: "Alamofire"),
              .product(name: "AlamofireImage"),
              .product(name: "OAuthSwift"),
              .product(name: "SwiftyJSON"),
              .product(name: "Willow"),
              .product(name: "KeychainAccess")
          ]),
        .testTarget(
            name: "IllithidTests",
            dependencies: ["Illithid"]),
    ]
)
