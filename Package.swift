// swift-tools-version:5.4

import PackageDescription

let package = Package(
  name: "mew-wallet-db",
  platforms: [
    .iOS(.v11),
    .macOS(.v10_13),
  ],
  products: [
    .library(name: "mew-wallet-db", targets: ["mew-wallet-db"])
  ],
  dependencies: [
    .package(name: "mdbx-ios", url: "https://github.com/Foboz/mdbx-ios.git", .upToNextMinor(from: "1.0.7"))
  ],
  targets: [
    .target(name: "mew-wallet-db", dependencies: [], path: "Sources"),
    .testTarget(name: "mew-wallet-db-tests", dependencies: ["mew-wallet-db"]),
  ]
)
