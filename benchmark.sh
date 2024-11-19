#!/usr/bin/env zsh

set -eu

SCRIPT_DIT=$(cd "$(dirname "$0")"; pwd)

if [ $# = 0 ]; then
  PACKAGE=".package(path: \"../\")"
  FLAG=""
  echo "Use local source code"
else
  PACKAGE=".package(url: \"https://github.com/yaslab/CSV.swift.git\", exact: \"$1\")"
  FLAG="-DLEGACY"
  echo "Use tag $1"
fi

cd "$SCRIPT_DIT"
mkdir -p ./benchmark/Sources/benchmark
cd benchmark

cat << EOF > ./Package.swift
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "benchmark",
  platforms: [.macOS(.v13)],
  dependencies: [
    $PACKAGE
  ],
  targets: [
    .executableTarget(
      name: "benchmark", 
      dependencies: [.product(name: "CSV", package: "CSV.swift")])
  ]
)
EOF

cat << EOF > ./Sources/benchmark/main.swift
import Foundation
import CSV

let _loop = 8

print("method | hasHeaderRow | trimFields | time (sec)")
print("--- | --- | --- | ---")

@inline(never)
func read_from_file(_ url: URL, config: CSVReaderConfiguration) throws {
  let start = Date()
  
  for _ in 0 ..< _loop {
#if LEGACY
    guard let stream = InputStream(url: url) else {
      throw NSError(domain: "Cannot open stream", code: -1)
    }
    let reader = try CSVReader(stream: stream, hasHeaderRow: config.hasHeaderRow, trimFields: config.trimFields)
    while let _ = reader.next() {
      if let error = reader.error {
        throw error
      }
    }
#else
    let reader = CSVReader(url: url, configuration: config)
    for result in reader {
      _ = try result.get()
    }
#endif
  }

  print("read_from_file | \(config.hasHeaderRow) | \(config.trimFields) | " + String(format: "%.4f", Date().timeIntervalSince(start)))
}

@inline(never)
func read_from_data(_ data: Data, config: CSVReaderConfiguration) throws {
  let start = Date()
  
  for _ in 0 ..< _loop {
#if LEGACY
    let stream = InputStream(data: data)
    let reader = try CSVReader(stream: stream, hasHeaderRow: config.hasHeaderRow, trimFields: config.trimFields)
    while let _ = reader.next() {
      if let error = reader.error {
        throw error
      }
    }
#else
    let reader = CSVReader(data: data, configuration: config)
    for result in reader {
      _ = try result.get()
    }
#endif
  }

  print("read_from_data | \(config.hasHeaderRow) | \(config.trimFields) | " + String(format: "%.4f", Date().timeIntervalSince(start)))
}

@inline(never)
func read_from_string(_ string: String, config: CSVReaderConfiguration) throws {
  let start = Date()
  
  for _ in 0 ..< _loop {
#if LEGACY
    let reader = try CSVReader(string: string, hasHeaderRow: config.hasHeaderRow, trimFields: config.trimFields)
    while let _ = reader.next() {
      if let error = reader.error {
        throw error
      }
    }
#else
    let reader = CSVReader(string: string, configuration: config)
    for result in reader {
      _ = try result.get()
    }
#endif
  }

  print("read_from_string | \(config.hasHeaderRow) | \(config.trimFields) | " + String(format: "%.4f", Date().timeIntervalSince(start)))
}

guard let path = CommandLine.arguments.dropFirst().first else {
  print("error: missing file path")
  exit(1)
}

do {
  let url = URL(filePath: path)

  try read_from_file(url, config: .csv(hasHeaderRow: false, trimFields: false))
  try read_from_file(url, config: .csv(hasHeaderRow: true, trimFields: false))
  try read_from_file(url, config: .csv(hasHeaderRow: false, trimFields: true))

  let data = try Data(contentsOf: url)

  try read_from_data(data, config: .csv(hasHeaderRow: false, trimFields: false))
  try read_from_data(data, config: .csv(hasHeaderRow: true, trimFields: false))
  try read_from_data(data, config: .csv(hasHeaderRow: false, trimFields: true))

  let string = String(decoding: data, as: UTF8.self)

  try read_from_string(string, config: .csv(hasHeaderRow: false, trimFields: false))
  try read_from_string(string, config: .csv(hasHeaderRow: true, trimFields: false))
  try read_from_string(string, config: .csv(hasHeaderRow: false, trimFields: true))
} catch {
  print("error:", error)
}
EOF

if [ ! -f ./list_person_all_extended_utf8.zip ]; then
  curl -O "https://www.aozora.gr.jp/index_pages/list_person_all_extended_utf8.zip"
  unzip ./list_person_all_extended_utf8.zip
fi

swift package clean

swift run \
  -c release \
  -Xswiftc "-swift-version" \
  -Xswiftc "6" \
  -Xswiftc "$FLAG" \
  benchmark "`pwd`/list_person_all_extended_utf8.csv"
