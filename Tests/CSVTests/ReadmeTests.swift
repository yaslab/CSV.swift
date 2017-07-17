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
        ("testGetTheFieldValueUsingKey", testGetTheFieldValueUsingKey),
        ("testProvideTheCharacterEncoding", testProvideTheCharacterEncoding),
        ("testWriteToMemory", testWriteToMemory),
        ("testWriteToFile", testWriteToFile)
    ]
    
    // MARK: - Reading

    func testFromCSVString() {
        let csvString = "1,foo\n2,bar"
        let csv = try! CSVReader(string: csvString)
        while let row = csv.next() {
            print("\(row)")
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

    func testGettingTheHeaderRow() {
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
    }

    func testGetTheFieldValueUsingKey() {
        let csvString = "id,name\n1,foo"
        let csv = try! CSVReader(string: csvString,
                                 hasHeaderRow: true) // It must be true.
        
        while csv.next() != nil {
            print("\(csv["id"]!)")   // => "1"
            print("\(csv["name"]!)") // => "foo"
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
