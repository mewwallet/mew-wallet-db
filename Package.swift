// swift-tools-version:5.4

import PackageDescription

let package = Package(
  name: "mew-wallet-db",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_13)
  ],
  products: [
    .library(name: "mew-wallet-db", targets: ["mew-wallet-db"])
  ],
  dependencies: [
    .package(name: "MEWextensions", url: "https://github.com/Foboz/MEWextensions.git", .exact("1.0.9")),
    .package(name: "mdbx-ios", url: "https://github.com/Foboz/mdbx-ios.git", .branch("feature/engine-update")),
    .package(name: "SwiftProtobuf", url: "https://github.com/apple/swift-protobuf.git", .upToNextMinor(from: "1.18.0"))
    
  ],
  targets: [
    .target(name: "mew-wallet-db", dependencies: ["mdbx-ios", "MEWextensions", "SwiftProtobuf"], path: "Sources"),
    .testTarget(name: "mew-wallet-db-tests", dependencies: ["mew-wallet-db"], path: "Tests", resources: [ .process("marketItems.json"), .process("tokenMetas.json")])
  ]
)
