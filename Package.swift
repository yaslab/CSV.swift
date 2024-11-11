// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CSV.swift",
    platforms: [
        .iOS(.v14), .tvOS(.v14), .watchOS(.v7), .macOS(.v11),
    ],
    products: [
        .library(name: "CSV", targets: ["CSV"])
    ],
    targets: [
        .target(name: "CSV"),
        .testTarget(name: "CSVTests", dependencies: ["CSV"]),
    ]
)
