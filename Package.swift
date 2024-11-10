// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "CSV.swift",
    platforms: [
        .iOS(.v12), .tvOS(.v12), .watchOS(.v4), .macOS(.v10_13),
    ],
    products: [
        .library(name: "CSV", targets: ["CSV"])
    ],
    targets: [
        .target(name: "CSV"),
        .testTarget(name: "CSVTests", dependencies: ["CSV"]),
    ]
)
