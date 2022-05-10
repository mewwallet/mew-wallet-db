// swift-tools-version:5.5

import PackageDescription

let package = Package(
  name: "mew-wallet-db",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15)
  ],
  products: [
    .library(name: "mew-wallet-db",
             targets: ["mew-wallet-db"])
  ],
  dependencies: [
    .package(name: "MEWextensions", url: "https://github.com/Foboz/MEWextensions.git", .upToNextMinor(from: "1.0.11")),
    .package(name: "mdbx-ios", url: "git@github.com:mewwallet/mdbx-ios.git", .branch("feature/engine-update")),
    .package(name: "swift-algorithms", url: "https://github.com/apple/swift-algorithms.git", .exact("1.0.0")),
    .package(name: "SwiftProtobuf", url: "https://github.com/apple/swift-protobuf.git", .upToNextMinor(from: "1.18.0"))
  ],
  targets: [
    .target(name: "mew-wallet-db",
            dependencies: ["mdbx-ios",
                           .product(name: "Algorithms", package: "swift-algorithms"),
                           "MEWextensions",
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
