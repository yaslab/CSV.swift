# CSV.swift

[![Build Status](https://travis-ci.org/yaslab/CSV.swift.svg?branch=master)](https://travis-ci.org/yaslab/CSV.swift)

CSV reading library written in Swift.

## Usage

### From CSV string

```swift
import CSV

for row in try! CSV(string: "1,foo\n2,bar") {
    print("\(row)")
    // => ["1", "foo"]
    // => ["2", "bar"]
}
```

### From file path

```swift
import Foundation
import CSV

let stream = InputStream(fileAtPath: "/path/to/file.csv")!
for row in try! CSV(stream: stream) {
    print("\(row)")
}
```

### Getting the header row

```swift
import CSV

let csv = try! CSV(
    string: "id,name\n1,foo\n2,bar",
    hasHeaderRow: true) // default: false

let headerRow = csv.headerRow!
print("\(headerRow)") // => ["id", "name"]

for row in csv {
    print("\(row)")
    // => ["1", "foo"]
    // => ["2", "bar"]
}
```

### Get the field value using subscript

```swift
import CSV

var csv = try! CSV(
    string: "id,name\n1,foo",
    hasHeaderRow: true) // It must be true.

while let _ = csv.next() {
    print("\(csv["id"]!)")   // => "1"
    print("\(csv["name"]!)") // => "foo"
}
```

### Provide the character encoding

If you use a file path, you can provide the character encoding to initializer.

```swift
import Foundation
import CSV

let csv = try! CSV(
    stream: InputStream(fileAtPath: "/path/to/file.csv")!,
    codecType: UTF16.self,
    endian: .big)
```

## Installation

### CocoaPods

```ruby
pod 'CSV.swift', '~> 1.1'
```

### Carthage

```
github "yaslab/CSV.swift" ~> 1.1
```

### Swift Package Manager

```swift
import PackageDescription

let package = Package(
    name: "PackageName",
    dependencies: [
        .Package(url: "https://github.com/yaslab/CSV.swift.git", majorVersion: 1, minor: 1)
    ]
)
```

## Reference specification

- [RFC4180](http://www.ietf.org/rfc/rfc4180.txt) ([en](http://www.ietf.org/rfc/rfc4180.txt), [ja](http://www.kasai.fm/wiki/rfc4180jp))

## License

CSV.swift is released under the MIT license. See the [LICENSE](https://github.com/yaslab/CSV.swift/blob/master/LICENSE) file for more info.
