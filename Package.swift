// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "CSV.swift",
    products: [
        .library(name: "CSV", targets: ["CSV"])
    ],
    targets: [
        .target(name: "CSV"),
        .testTarget(name: "CSVTests", dependencies: ["CSV"])
    ],
    swiftLanguageVersions: [4]
)
