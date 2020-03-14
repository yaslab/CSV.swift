# CSV.swift

[![Build Status](https://travis-ci.org/yaslab/CSV.swift.svg?branch=master)](https://travis-ci.org/yaslab/CSV.swift)
[![codecov](https://codecov.io/gh/yaslab/CSV.swift/branch/master/graph/badge.svg)](https://codecov.io/gh/yaslab/CSV.swift)
[![Open Source Helpers](https://www.codetriage.com/yaslab/csv.swift/badges/users.svg)](https://www.codetriage.com/yaslab/csv.swift)

CSV reading and writing library written in Swift.

## Usage for reading CSV

### From string

```swift
import CSV

let csvString = "1,foo\n2,bar"
let csv = try! CSVReader(string: csvString)
while let row = csv.next() {
    print("\(row)")
}
// => ["1", "foo"]
// => ["2", "bar"]
```

### From file

NOTE: The default character encoding is `UTF8`.

```swift
import Foundation
import CSV

let stream = InputStream(fileAtPath: "/path/to/file.csv")!
let csv = try! CSVReader(stream: stream)
while let row = csv.next() {
    print("\(row)")
}
```

### Getting the header row

```swift
import CSV

let csvString = "id,name\n1,foo\n2,bar"
let csv = try! CSVReader(string: csvString,
                         hasHeaderRow: true) // It must be true.

let headerRow = csv.headerRow!
print("\(headerRow)") // => ["id", "name"]

while let row = csv.next() {
    print("\(row)")
}
// => ["1", "foo"]
// => ["2", "bar"]
```

### Get the field value using subscript

```swift
import CSV

let csvString = "id,name\n1,foo"
let csv = try! CSVReader(string: csvString,
                         hasHeaderRow: true) // It must be true.

while csv.next() != nil {
    print("\(csv["id"]!)")   // => "1"
    print("\(csv["name"]!)") // => "foo"
}
```

### Provide the character encoding

If you use a file path, you can provide the character encoding to initializer.

```swift
import Foundation
import CSV

let stream = InputStream(fileAtPath: "/path/to/file.csv")!
let csv = try! CSVReader(stream: stream,
                         codecType: UTF16.self,
                         endian: .big)
```

### Reading a row into a Decodable object

If you have a destination object that conforms to the `Decodable` protocol, you can serialize a row with a new instances of the object.

```swift
struct DecodableExample: Decodable {
    let intKey: Int
    let stringKey: String
    let optionalStringKey: String?
}

let csv = """
    intKey,stringKey,optionalStringKey
    1234,abcd,
    """

var records = [DecodableExample]()
do {
    let reader = try CSVReader(string: csv, hasHeaderRow: true)
    let decoder = CSVRowDecoder()
    while reader.next() != nil {
        let row = try decoder.decode(DecodableExample.self, from: reader)
        records.append(row)
    }
} catch {
    // Invalid row format
}
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

### CocoaPods

```ruby
pod 'CSV.swift', '~> 2.4.3'
```

### Carthage

```
github "yaslab/CSV.swift" ~> 2.4.3
```

### Swift Package Manager

```swift
.package(url: "https://github.com/yaslab/CSV.swift.git", .upToNextMinor(from: "2.4.3"))
```

## Reference specification

- [RFC4180](http://www.ietf.org/rfc/rfc4180.txt) ([en](http://www.ietf.org/rfc/rfc4180.txt), [ja](http://www.kasai.fm/wiki/rfc4180jp))

## License

CSV.swift is released under the MIT license. See the [LICENSE](https://github.com/yaslab/CSV.swift/blob/master/LICENSE) file for more info.
