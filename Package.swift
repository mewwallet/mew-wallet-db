// swift-tools-version:5.5

import PackageDescription

let package = Package(
  name: "mew-wallet-db",
  platforms: [
    .iOS(.v14),
    .macOS(.v10_15)
  ],
  products: [
    .library(name: "mew-wallet-db",
             targets: ["mew-wallet-db"])
  ],
  dependencies: [
    .package(name: "mew-wallet-ios-extensions", url: "https://github.com/mewwallet/mew-wallet-ios-extensions.git", .upToNextMajor(from: "1.0.0")),
    .package(name: "mdbx-ios", url: "git@github.com:mewwallet/mdbx-ios.git", .exact("1.0.9")),
    .package(name: "swift-algorithms", url: "https://github.com/apple/swift-algorithms.git", .exact("1.0.0")),
    .package(name: "SwiftProtobuf", url: "https://github.com/apple/swift-protobuf.git", .upToNextMinor(from: "1.18.0"))
  ],
  targets: [
    .target(name: "mew-wallet-db",
            dependencies: ["mdbx-ios",
                           .product(name: "Algorithms", package: "swift-algorithms"),
                           "mew-wallet-ios-extensions",
                           "SwiftProtobuf"],
            path: "Sources",
            exclude: [
              "Models/Concrete/Protos/models"
            ]),
    
    .testTarget(name: "mew-wallet-db-tests",
            dependencies: ["mew-wallet-db"],
            path: "Tests")
  ]
)
