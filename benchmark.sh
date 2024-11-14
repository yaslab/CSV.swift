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
func read_from_file(_ url: URL, hasHeaderRow: Bool, trimFields: Bool) throws {
  let start = Date()
  
  for _ in 0 ..< _loop {
#if LEGACY
    guard let stream = InputStream(url: url) else {
      throw NSError(domain: "Cannot open stream", code: -1)
    }
    let reader = try CSVReader(stream: stream, hasHeaderRow: hasHeaderRow, trimFields: trimFields)
    while let _ = reader.next() {
      if let error = reader.error {
        throw error
      }
    }
#else
    var reader = CSVReader(url: url)
    reader.configuration.hasHeaderRow = hasHeaderRow
    reader.configuration.trimFields = trimFields
    for result in reader {
      _ = try result.get()
    }
#endif
  }

  print("read_from_file | \(hasHeaderRow) | \(trimFields) | " + String(format: "%.4f", Date().timeIntervalSince(start)))
}

@inline(never)
func read_from_data(_ data: Data, hasHeaderRow: Bool, trimFields: Bool) throws {
  let start = Date()
  
  for _ in 0 ..< _loop {
#if LEGACY
    let stream = InputStream(data: data)
    let reader = try CSVReader(stream: stream, hasHeaderRow: hasHeaderRow, trimFields: trimFields)
    while let _ = reader.next() {
      if let error = reader.error {
        throw error
      }
    }
#else
    var reader = CSVReader(data: data)
    reader.configuration.hasHeaderRow = hasHeaderRow
    reader.configuration.trimFields = trimFields
    for result in reader {
      _ = try result.get()
    }
#endif
  }

  print("read_from_data | \(hasHeaderRow) | \(trimFields) | " + String(format: "%.4f", Date().timeIntervalSince(start)))
}

@inline(never)
func read_from_string(_ string: String, hasHeaderRow: Bool, trimFields: Bool) throws {
  let start = Date()
  
  for _ in 0 ..< _loop {
#if LEGACY
    let reader = try CSVReader(string: string, hasHeaderRow: hasHeaderRow, trimFields: trimFields)
    while let _ = reader.next() {
      if let error = reader.error {
        throw error
      }
    }
#else
    var reader = CSVReader(string: string)
    reader.configuration.hasHeaderRow = hasHeaderRow
    reader.configuration.trimFields = trimFields
    for result in reader {
      _ = try result.get()
    }
#endif
  }

  print("read_from_string | \(hasHeaderRow) | \(trimFields) | " + String(format: "%.4f", Date().timeIntervalSince(start)))
}

guard let path = CommandLine.arguments.dropFirst().first else {
  print("error: missing file path")
  exit(1)
}

do {
  let url = URL(filePath: path)

  try read_from_file(url, hasHeaderRow: false, trimFields: false)
  try read_from_file(url, hasHeaderRow: true, trimFields: false)
  try read_from_file(url, hasHeaderRow: false, trimFields: true)

  let data = try Data(contentsOf: url)

  try read_from_data(data, hasHeaderRow: false, trimFields: false)
  try read_from_data(data, hasHeaderRow: true, trimFields: false)
  try read_from_data(data, hasHeaderRow: false, trimFields: true)

  let string = String(decoding: data, as: UTF8.self)

  try read_from_string(string, hasHeaderRow: false, trimFields: false)
  try read_from_string(string, hasHeaderRow: true, trimFields: false)
  try read_from_string(string, hasHeaderRow: false, trimFields: true)
} catch {
  print("error:", error)
}
EOF

if [ ! -f ./list_person_all_extended_utf8.zip ]; then
  curl -O "https://www.aozora.gr.jp/index_pages/list_person_all_extended_utf8.zip"
  unzip ./list_person_all_extended_utf8.zip
fi

swift package clean
swift run -c release -Xswiftc "$FLAG" benchmark "`pwd`/list_person_all_extended_utf8.csv"
