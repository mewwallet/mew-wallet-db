// swift-tools-version:5.10

import PackageDescription

let package = Package(
  name: "mew-wallet-db",
  platforms: [
    .iOS(.v14),
    .macOS(.v11)
  ],
  products: [
    .library(
      name: "mew-wallet-db",
      targets: ["mew-wallet-db"]
    )
  ],
  dependencies: [
    .package(url: "git@github.com:mewwallet/mew-wallet-ios-extensions.git", .upToNextMajor(from: "1.0.0")),
    .package(url: "git@github.com:mewwallet/mdbx-ios.git", .upToNextMajor(from: "1.0.11")),
    .package(url: "https://github.com/apple/swift-algorithms.git", exact: "1.0.0"),
    .package(url: "https://github.com/apple/swift-protobuf.git", .upToNextMinor(from: "1.18.0"))
  ],
  targets: [
    .target(
      name: "mew-wallet-db",
      dependencies: [
        "mdbx-ios",
        .product(name: "Algorithms", package: "swift-algorithms"),
        "mew-wallet-ios-extensions",
        .product(name: "SwiftProtobuf", package: "swift-protobuf")
        
      ],
      path: "Sources",
      exclude: [
        "Models/Concrete/Protos/models"
      ],
      resources: [
        .copy("Privacy/PrivacyInfo.xcprivacy")
      ]
    ),
    .testTarget(
      name: "mew-wallet-db-tests",
      dependencies: ["mew-wallet-db"],
      path: "Tests"
    )
  ]
)
