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
        let csv = CSVReader(string: csvString)
        for result in csv {
            let row = try result.get()
            print("\(row.columns)")
        }
        // => ["1", "foo"]
        // => ["2", "bar"]
    }

    func testFromFile() {
        //        let stream = InputStream(fileAtPath: "/path/to/file.csv")!
        //        let csv = try! CSVReader(stream: stream)
        //        while let row = csv.next() {
        //            print("\(row)")
        //        }
    }

    func testGettingTheHeaderRow() throws {
        let csvString = "id,name\n1,foo\n2,bar"
        let csv = CSVReader(
            string: csvString,
            configuration: .init(hasHeaderRow: true))  // It must be true.

        for result in csv {
            let row = try result.get()
            print("\(row.header!), \(row.columns)")
        }
        // => ["id", "name"], ["1", "foo"]
        // => ["id", "name"], ["2", "bar"]
    }

    func testGetTheFieldValueUsingKey() throws {
        let csvString = "id,name\n1,foo"
        let csv = CSVReader(
            string: csvString,
            configuration: .init(hasHeaderRow: true))  // It must be true.

        for result in csv {
            let row = try result.get()
            print("\(row["id"]!)")  // => "1"
            print("\(row["name"]!)")  // => "foo"
        }
    }

    func testProvideTheCharacterEncoding() {
        //        let stream = InputStream(fileAtPath: "/path/to/file.csv")!
        //        let csv = try! CSVReader(stream: stream,
        //                                 codecType: UTF16.self,
        //                                 endian: .big)
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
