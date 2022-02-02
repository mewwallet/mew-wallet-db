// swift-tools-version:5.4

import PackageDescription

let package = Package(
  name: "MEWwalletDB",
  platforms: [
    .iOS(.v11),
    .macOS(.v10_13),
  ],
  products: [
    .library(name: "MEWwalletDB", targets: ["MEWwalletDB"])
  ],
  dependencies: [
    .package(name: "mdbx-ios", url: "https://github.com/Foboz/mdbx-ios.git", .upToNextMinor(from: "1.0.7"))
  ],
  targets: [
    .target(name: "MEWwalletDB", dependencies: ["mdbx-ios", "MEWextensions"], path: "Sources"),
    .testTarget(name: "MEWwalletDBTests", dependencies: ["MEWwalletDB"], path: "Tests", resources: [ .process("marketItems.json"), .process("tokenMetas.json")])
  ]
)
