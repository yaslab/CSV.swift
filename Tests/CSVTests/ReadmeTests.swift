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

    static let allTests = [
        ("testFromCSVString", testFromCSVString),
        ("testFromFile", testFromFile),
        ("testGettingTheHeaderRow", testGettingTheHeaderRow),
        ("testGetTheFieldValueUsingIndex", testGetTheFieldValueUsingIndex),
        ("testGetTheFieldValueUsingKey", testGetTheFieldValueUsingKey),
        ("testProvideTheCharacterEncoding", testProvideTheCharacterEncoding)
    ]

    func testFromCSVString() {
        let csv = try! CSVReader(string: "1,foo\n2,bar")
        try! csv.enumerateRows { (row, _, _) in
            print("\(row)")
            // => ["1", "foo"]
            // => ["2", "bar"]
        }
    }

    func testFromFile() {
//        let stream = InputStream(fileAtPath: "/path/to/file.csv")!
//        let csv = try! CSV(stream: stream)
//        for row in csv {
//            print("\(row)")
//        }
    }

    func testGettingTheHeaderRow() {
        let csvString = "id,name\n1,foo\n2,bar"
        let csv = try! CSVReader(string: csvString,
                                 hasHeaderRow: true) // It must be true.

        let headerRow = csv.headerRow!
        print("\(headerRow)") // => ["id", "name"]

        try! csv.enumerateRows { (row, _, _) in
            print("\(row)")
            // => ["1", "foo"]
            // => ["2", "bar"]
        }
    }

    func testGetTheFieldValueUsingIndex() {
        let csvString = "1,foo"
        let csv = try! CSVReader(string: csvString)

        try! csv.enumerateRows { (row, _, _) in
            print("\(row[0])") // => "1"
            print("\(row[1])") // => "foo"
        }
    }

    func testGetTheFieldValueUsingKey() {
//        let csvString = "id,name\n1,foo"
//        let config = CSVReader.Configuration(hasHeaderRow: true) // It must be true.
//        let csv = try! CSVReader(string: csvString, configuration: config)
//
//        csv.enumerateRecords { (record, _, _) in
//            print("\(record["id"]!)")   // => "1"
//            print("\(record["name"]!)") // => "foo"
//        }
    }

    func testProvideTheCharacterEncoding() {
//        let csv = try! CSV(
//            stream: InputStream(fileAtPath: "/path/to/file.csv")!,
//            codecType: UTF16.self,
//            endian: .big)
    }

}
