# CSV.swift

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fyaslab%2FCSV.swift%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/yaslab/CSV.swift)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fyaslab%2FCSV.swift%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/yaslab/CSV.swift)
[![Open Source Helpers](https://www.codetriage.com/yaslab/csv.swift/badges/users.svg)](https://www.codetriage.com/yaslab/csv.swift)

CSV reading and writing library written in Swift.

## Usage for reading CSV

### From string

```swift
import CSV

let csvString = "1,foo\n2,bar"
let reader = CSVReader(string: csvString)
for result in reader {
    let row = try result.get()
    print("=> \(row.columns)")
}
// output:
// => ["1", "foo"]
// => ["2", "bar"]
```

### From file

```swift
import CSV

let csvURL = URL(filePath: "/path/to/file.csv")
let reader = CSVReader(url: csvURL)
for result in reader {
    let row = try result.get()
    print("=> \(row.columns)")
}
```

### Getting the header row

```swift
import CSV

let csvString = "id,name\n1,foo"
let reader = CSVReader(
    string: csvString,
    hasHeaderRow: true  // It must be true.
)
for result in reader {
    let row = try result.get()
    print("=> \(row.header!)")
    print("=> \(row.columns)")
}
// output:
// => ["id", "name"]
// => ["1", "foo"]
```

### Get the field value using subscript

```swift
import CSV

let csvString = "id,name\n1,foo\n2,bar"
let reader = CSVReader(
    string: csvString,
    hasHeaderRow: true  // It must be true.
)
for result in reader {
    let row = try result.get()
    print("=> id: \(row["id"]!), name: \(row["name"]!)")
}
// output:
// => id: 1, name: foo
// => id: 2, name: bar
```

### Reading a row into a Decodable object

If you have a destination object that conforms to the `Decodable` protocol, you can serialize a row with a new instances of the object.

```swift
struct DecodableExample: Decodable {
    let intKey: Int
    let stringKey: String
    let optionalStringKey: String?
}
let csvString = """
    intKey,stringKey,optionalStringKey
    1234,abcd,
    """
let reader = CSVReader(
    string: csvString,
    hasHeaderRow: true  // It must be true.
)
let decoder = CSVRowDecoder()
for result in reader {
    let row = try result.get()
    let model = try decoder.decode(DecodableExample.self, from: row)
    print("=> \(model)")
}
// output:
// => DecodableExample(intKey: 1234, stringKey: "abcd", optionalStringKey: nil)
```

## Usage for writing CSV

### Write to memory and get a CSV String

NOTE: The default character encoding is `UTF8`.

```swift
import Foundation
import CSV

let csv = try! CSVWriter(stream: .toMemory())

// Write a row
try! csv.write(row: ["id", "name"])

// Write fields separately
csv.beginNewRow()
try! csv.write(field: "1")
try! csv.write(field: "foo")
csv.beginNewRow()
try! csv.write(field: "2")
try! csv.write(field: "bar")

csv.stream.close()

// Get a String
let csvData = csv.stream.property(forKey: .dataWrittenToMemoryStreamKey) as! Data
let csvString = String(data: csvData, encoding: .utf8)!
print(csvString)
// => "id,name\n1,foo\n2,bar"
```

### Write to file

NOTE: The default character encoding is `UTF8`.

```swift
import Foundation
import CSV

let stream = OutputStream(toFileAtPath: "/path/to/file.csv", append: false)!
let csv = try! CSVWriter(stream: stream)

try! csv.write(row: ["id", "name"])
try! csv.write(row: ["1", "foo"])
try! csv.write(row: ["1", "bar"])

csv.stream.close()
```

## Installation

### Swift Package Manager

Add the dependency to your `Package.swift`. For example:

```swift
// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MyPackage",
    dependencies: [
        // Add `CSV.swift` package here.
        .package(url: "https://github.com/yaslab/CSV.swift.git", from: "2.5.1")
    ],
    targets: [
        .executableTarget(
            name: "MyCommand",
            dependencies: [
                // Then add it to your module's dependencies.
                .product(name: "CSV", package: "CSV.swift")
            ]
        )
    ]
)
```

### CocoaPods

```ruby
pod 'CSV.swift', '~> 2.5.1'
```

## Reference specification

- [RFC4180](http://www.ietf.org/rfc/rfc4180.txt) ([en](http://www.ietf.org/rfc/rfc4180.txt), [ja](http://www.kasai.fm/wiki/rfc4180jp))

## License

CSV.swift is released under the MIT license. See the [LICENSE](./LICENSE) file for more info.
