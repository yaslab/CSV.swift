//
//  CSVWriterTests.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2017/05/28.
//  Copyright © 2017年 yaslab. All rights reserved.
//

import Foundation
import XCTest

import CSV

extension OutputStream {

    var data: Data? {
        return self.property(forKey: .dataWrittenToMemoryStreamKey) as? Data
    }

}

class CSVWriterTests: XCTestCase {

    let str = "TEST-test-1234-😄😆👨‍👩‍👧‍👦"

    /// xxxx
    func testSingleFieldSingleRecord() {
        let csv = try! CSVWriter(stream: .toMemory())
        csv.beginNewRow()
        try! csv.write(field: str)

        let data = csv.stream.data!
        let csvStr = String(data: data, encoding: .utf8)!

        XCTAssertEqual(csvStr, str)
    }

    /// xxxx
    /// xxxx
    func testSingleFieldMultipleRecord() {
        let stream = OutputStream.toMemory()
        stream.open()

        let csv = try! CSVWriter(stream: stream)
        csv.beginNewRow()
        try! csv.write(field: str + "-1")
        csv.beginNewRow()
        try! csv.write(field: str + "-2")

        stream.close()
        let data = stream.data!
        let csvStr = String(data: data, encoding: .utf8)!

        XCTAssertEqual(csvStr, "\(str)-1\n\(str)-2")
    }

    /// xxxx,xxxx
    func testMultipleFieldSingleRecord() {
        let stream = OutputStream.toMemory()
        stream.open()

        let csv = try! CSVWriter(stream: stream)
        csv.beginNewRow()
        try! csv.write(field: str + "-1")
        try! csv.write(field: str + "-2")

        stream.close()
        let data = stream.data!
        let csvStr = String(data: data, encoding: .utf8)!

        XCTAssertEqual(csvStr, "\(str)-1,\(str)-2")
    }

    /// xxxx,xxxx
    /// xxxx,xxxx
    func testMultipleFieldMultipleRecord() {
        let stream = OutputStream.toMemory()
        stream.open()

        let csv = try! CSVWriter(stream: stream)
        csv.beginNewRow()
        try! csv.write(field: str + "-1-1")
        try! csv.write(field: str + "-1-2")
        csv.beginNewRow()
        try! csv.write(field: str + "-2-1")
        try! csv.write(field: str + "-2-2")

        stream.close()
        let data = stream.data!
        let csvStr = String(data: data, encoding: .utf8)!

        XCTAssertEqual(csvStr, "\(str)-1-1,\(str)-1-2\n\(str)-2-1,\(str)-2-2")
    }

    /// "xxxx",xxxx
    func testQuoted() {
        let stream = OutputStream.toMemory()
        stream.open()

        let csv = try! CSVWriter(stream: stream)
        csv.beginNewRow()
        try! csv.write(field: str + "-1", quoted: true)
        try! csv.write(field: str + "-2") // quoted: false

        stream.close()
        let data = stream.data!
        let csvStr = String(data: data, encoding: .utf8)!

        XCTAssertEqual(csvStr, "\"\(str)-1\",\(str)-2")
    }

    /// xxxx,"xx\nxx"
    func testQuotedNewline() {
        let stream = OutputStream.toMemory()
        stream.open()

        let csv = try! CSVWriter(stream: stream)
        csv.beginNewRow()
        try! csv.write(field: str + "-1") // quoted: false
        try! csv.write(field: str + "-\n-2", quoted: true)

        stream.close()
        let data = stream.data!
        let csvStr = String(data: data, encoding: .utf8)!

        XCTAssertEqual(csvStr, "\(str)-1,\"\(str)-\n-2\"")
    }

    /// xxxx,"xx""xx"
    func testEscapeQuote() {
        let stream = OutputStream.toMemory()
        stream.open()

        let csv = try! CSVWriter(stream: stream)
        csv.beginNewRow()
        try! csv.write(field: str + "-1") // quoted: false
        try! csv.write(field: str + "-\"-2", quoted: true)

        stream.close()
        let data = stream.data!
        let csvStr = String(data: data, encoding: .utf8)!

        XCTAssertEqual(csvStr, "\(str)-1,\"\(str)-\"\"-2\"")
    }

    /// csv.write(row: ["xxxx", "xx,\"xx"])
    /// -> xxxx,"xx,""xx"
    func testEscapeQuoteAutomatically() {
        let stream = OutputStream.toMemory()
        stream.open()
        
        let csv = try! CSVWriter(stream: stream)
        try! csv.write(row: ["id", "testing,\"comma"]) // quoted: false
        
        stream.close()
        let data = stream.data!
        let csvStr = String(data: data, encoding: .utf8)!
        
        XCTAssertEqual(csvStr, "id,\"testing,\"\"comma\"")
    }
    
    /// csv.write(row: ["xxxx", "xx\rxx", "xx\nxx", "xx\r\nrxx"])
    /// -> xxxx,"xx\rxx","xx\nxx","xx\r\nxx"
    func testEscapeNewlineAutomatically() {
        let stream = OutputStream.toMemory()
        stream.open()
        
        let csv = try! CSVWriter(stream: stream)
        try! csv.write(row: ["id", "testing\rCR", "testing\nLF", "testing\r\nCRLF"]) // quoted: false
        
        stream.close()
        let data = stream.data!
        let csvStr = String(data: data, encoding: .utf8)!
        
        XCTAssertEqual(csvStr, "id,\"testing\rCR\",\"testing\nLF\",\"testing\r\nCRLF\"")
    }
    
    /// Test delimiter: $
    /// csv.write(row: ["xxxx", "xx$xx"])
    /// -> xxxx$"xx$xx"
    func testEscapeDelimiterAutomatically() {
        let stream = OutputStream.toMemory()
        stream.open()
        
        let csv = try! CSVWriter(stream: stream, delimiter: "$")
        try! csv.write(row: ["id", "testing$dollar"]) // quoted: false
        
        stream.close()
        let data = stream.data!
        let csvStr = String(data: data, encoding: .utf8)!
        
        XCTAssertEqual(csvStr, "id$\"testing$dollar\"")
    }
    
    /// Test delimiter: "\t"
    func testDelimiter() {
        let stream = OutputStream.toMemory()
        stream.open()

        let csv = try! CSVWriter.init(stream: stream, delimiter: "\t")
        csv.beginNewRow()
        try! csv.write(field: str + "-1")
        try! csv.write(field: str + "-2")

        stream.close()
        let data = stream.data!
        let csvStr = String(data: data, encoding: .utf8)!

        XCTAssertEqual(csvStr, "\(str)-1\t\(str)-2")
    }

    /// Test newline: "\r\n"
    func testNewline() {
        let stream = OutputStream.toMemory()
        stream.open()

        let csv = try! CSVWriter.init(stream: stream, newline: .crlf)
        csv.beginNewRow()
        try! csv.write(field: str + "-1")
        csv.beginNewRow()
        try! csv.write(field: str + "-2")

        stream.close()
        let data = stream.data!
        let csvStr = String(data: data, encoding: .utf8)!

        XCTAssertEqual(csvStr, "\(str)-1\r\n\(str)-2")
    }

    /// xxxx,xxxx
    func testValueContainsComma() {
        let stream = OutputStream.toMemory()
        stream.open()

        let csv = try! CSVWriter(stream: stream)
        csv.beginNewRow()
        try! csv.write(field: str + ",1", quoted: true)
        try! csv.write(field: str + ",2") // quoted: false

        stream.close()
        let data = stream.data!
        let csvStr = String(data: data, encoding: .utf8)!

        XCTAssertEqual(csvStr, "\"\(str),1\",\"\(str),2\"")
    }

    /// UTF16 Big Endian
    func testUTF16BE() {
        let stream = OutputStream.toMemory()
        stream.open()

        let csv = try! CSVWriter(stream: stream, codecType: UTF16.self, endian: .big)
        csv.beginNewRow()
        try! csv.write(field: str)

        stream.close()
        let data = stream.data!
        let csvStr = String(data: data, encoding: .utf16BigEndian)!

        XCTAssertEqual(csvStr, str)
    }

    /// UTF16 Little Endian
    func testUTF16LE() {
        let stream = OutputStream.toMemory()
        stream.open()

        let csv = try! CSVWriter(stream: stream, codecType: UTF16.self, endian: .little)
        csv.beginNewRow()
        try! csv.write(field: str)

        stream.close()
        let data = stream.data!
        let csvStr = String(data: data, encoding: .utf16LittleEndian)!

        XCTAssertEqual(csvStr, str)
    }

    /// UTF32 Big Endian
    func testUTF32BE() {
        let stream = OutputStream.toMemory()
        stream.open()

        let csv = try! CSVWriter(stream: stream, codecType: UTF32.self, endian: .big)
        csv.beginNewRow()
        try! csv.write(field: str)

        stream.close()
        let data = stream.data!
        let csvStr = String(data: data, encoding: .utf32BigEndian)!

        XCTAssertEqual(csvStr, str)
    }

    /// UTF32 Little Endian
    func testUTF32LE() {
        let stream = OutputStream.toMemory()
        stream.open()

        let csv = try! CSVWriter(stream: stream, codecType: UTF32.self, endian: .little)
        csv.beginNewRow()
        try! csv.write(field: str)

        stream.close()
        let data = stream.data!
        let csvStr = String(data: data, encoding: .utf32LittleEndian)!

        XCTAssertEqual(csvStr, str)
    }

    func testReadme() {
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

        XCTAssertEqual("id,name\n1,foo\n2,bar", csvString)
    }

}
