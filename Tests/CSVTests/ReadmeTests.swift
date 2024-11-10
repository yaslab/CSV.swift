//
//  ReadmeTests.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/13.
//  Copyright © 2016 yaslab. All rights reserved.
//

import XCTest

@testable import CSV

class ReadmeTests: XCTestCase {

    // MARK: - Reading

    func testFromCSVString() throws {
        let csvString = "1,foo\n2,bar"
        let reader = CSVReader(string: csvString)
        for result in reader {
            let row = try result.get()
            print("\(row.columns)")
        }
        // output:
        // => ["1", "foo"]
        // => ["2", "bar"]
    }

    func testFromFile() throws {
        try Utils.withTempURL { csvURL in
            try "1,foo\n2,bar".data(using: .utf8)!.write(to: csvURL)
            let reader = CSVReader(url: csvURL)
            for result in reader {
                let row = try result.get()
                print("\(row.columns)")
            }
            // output:
            // => ["1", "foo"]
            // => ["2", "bar"]
        }
    }

    func testGettingTheHeaderRow() throws {
        let csvString = "id,name\n1,foo"
        let reader = CSVReader(
            string: csvString,
            hasHeaderRow: true  // It must be true.
        )
        for result in reader {
            let row = try result.get()
            print("\(row.header!)")
            print("\(row.columns)")
        }
        // output:
        // => ["id", "name"]
        // => ["1", "foo"]
    }

    func testGetTheFieldValueUsingKey() throws {
        let csvString = "id,name\n1,foo\n2,bar"
        let reader = CSVReader(
            string: csvString,
            hasHeaderRow: true  // It must be true.
        )
        for result in reader {
            let row = try result.get()
            print("id: \(row["id"]!), name: \(row["name"]!)")
        }
        // output:
        // => id: 1, name: foo
        // => id: 2, name: bar
    }

    func testDecodable() throws {
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
            print("\(model)")
        }
        // output:
        // => DecodableExample(intKey: 1234, stringKey: "abcd", optionalStringKey: nil)
    }

    // MARK: - Writing

    func testWriteToMemory() {
        let stream = OutputStream(toMemory: ())
        let csv = try! CSVWriter(stream: stream)

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
        let csvData = stream.property(forKey: .dataWrittenToMemoryStreamKey) as! NSData
        let csvString = String(data: Data(referencing: csvData), encoding: .utf8)!
        print(csvString)
        // => "id,name\n1,foo\n2,bar"
    }

    func testWriteToFile() {
        //        let stream = OutputStream(toFileAtPath: "/path/to/file.csv", append: false)!
        //        let csv = try! CSVWriter(stream: stream)
        //
        //        try! csv.write(row: ["id", "name"])
        //        try! csv.write(row: ["1", "foo"])
        //        try! csv.write(row: ["1", "bar"])
        //
        //        csv.stream.close()
    }

}
