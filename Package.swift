// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "AdventOfCode",
  platforms: [.macOS(.v13)],
  dependencies: [
    .package(url: "https://github.com/apple/swift-collections.git", from: .init(1, 1, 4)),
  ],
  targets: [
    .executableTarget(
      name: "aoc",
      dependencies: [.product(name: "Collections", package: "swift-collections")],
      resources: [.copy("Resources")]
    ),
  ]
)
