// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "AdventOfCode",
  platforms: [.macOS(.v14)],
  dependencies: [
    .package(url: "https://github.com/apple/swift-collections.git", from: .init(1, 1, 4)),
    .package(url: "https://github.com/apple/swift-algorithms.git", from: .init(1, 2, 0)),
  ],
  targets: [
    .executableTarget(
      name: "aoc",
      dependencies: [
        .product(name: "Collections", package: "swift-collections"),
        .product(name: "Algorithms", package: "swift-algorithms"),
      ],
      cSettings: [
        .define("ACCELERATE_NEW_LAPACK"),
        .define("ACCELERATE_LAPACK_ILP64"),
      ]
    ),
  ]
)
