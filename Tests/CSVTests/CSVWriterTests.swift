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
        return property(forKey: .dataWrittenToMemoryStreamKey) as? Data
    }
    
}

class CSVWriterTests: XCTestCase {
    
    static let allTests = [
        ("testSingleFieldSingleRecord", testSingleFieldSingleRecord),
        ("testSingleFieldMultipleRecord", testSingleFieldMultipleRecord),
        ("testMultipleFieldSingleRecord", testMultipleFieldSingleRecord),
        ("testMultipleFieldMultipleRecord", testMultipleFieldMultipleRecord),
        ("testQuoted", testQuoted),
        ("testQuotedNewline", testQuotedNewline),
        ("testEscapeQuote", testEscapeQuote)
    ]
    
    /// xxxx
    func testSingleFieldSingleRecord() {
        let str = "TEST-test-1234-😄😆👨‍👩‍👧‍👦"
        
        let stream = OutputStream(toMemory: ())
        stream.open()
        
        let csv = CSVWriter(stream: stream)
        csv.beginNewRecord()
        csv.write(field: str)
        
        stream.close()
        let data = stream.data!
        let csvStr = String(data: data, encoding: .utf8)!

        XCTAssertEqual(csvStr, str)
    }

    /// xxxx
    /// xxxx
    func testSingleFieldMultipleRecord() {
        let str = "TEST-test-1234-😄😆👨‍👩‍👧‍👦"
        
        let stream = OutputStream(toMemory: ())
        stream.open()
        
        let csv = CSVWriter(stream: stream)
        csv.beginNewRecord()
        csv.write(field: str + "-1")
        csv.beginNewRecord()
        csv.write(field: str + "-2")
        
        stream.close()
        let data = stream.data!
        let csvStr = String(data: data, encoding: .utf8)!
        
        XCTAssertEqual(csvStr, "\(str)-1\n\(str)-2")
    }
    
    /// xxxx,xxxx
    func testMultipleFieldSingleRecord() {
        let str = "TEST-test-1234-😄😆👨‍👩‍👧‍👦"
        
        let stream = OutputStream(toMemory: ())
        stream.open()
        
        let csv = CSVWriter(stream: stream)
        csv.beginNewRecord()
        csv.write(field: str + "-1")
        csv.write(field: str + "-2")

        stream.close()
        let data = stream.data!
        let csvStr = String(data: data, encoding: .utf8)!
        
        XCTAssertEqual(csvStr, "\(str)-1,\(str)-2")
    }

    /// xxxx,xxxx
    /// xxxx,xxxx
    func testMultipleFieldMultipleRecord() {
        let str = "TEST-test-1234-😄😆👨‍👩‍👧‍👦"
        
        let stream = OutputStream(toMemory: ())
        stream.open()
        
        let csv = CSVWriter(stream: stream)
        csv.beginNewRecord()
        csv.write(field: str + "-1-1")
        csv.write(field: str + "-1-2")
        csv.beginNewRecord()
        csv.write(field: str + "-2-1")
        csv.write(field: str + "-2-2")
        
        stream.close()
        let data = stream.data!
        let csvStr = String(data: data, encoding: .utf8)!
        
        XCTAssertEqual(csvStr, "\(str)-1-1,\(str)-1-2\n\(str)-2-1,\(str)-2-2")
    }
    
    /// "xxxx",xxxx
    func testQuoted() {
        let str = "TEST-test-1234-😄😆👨‍👩‍👧‍👦"
        
        let stream = OutputStream(toMemory: ())
        stream.open()
        
        let csv = CSVWriter(stream: stream)
        csv.beginNewRecord()
        csv.write(field: str + "-1", quoted: true)
        csv.write(field: str + "-2") // quoted: false
        
        stream.close()
        let data = stream.data!
        let csvStr = String(data: data, encoding: .utf8)!
        
        XCTAssertEqual(csvStr, "\"\(str)-1\",\(str)-2")
    }
    
    /// xxxx,"xx\nxx"
    func testQuotedNewline() {
        let str = "TEST-test-1234-😄😆👨‍👩‍👧‍👦"
        
        let stream = OutputStream(toMemory: ())
        stream.open()
        
        let csv = CSVWriter(stream: stream)
        csv.beginNewRecord()
        csv.write(field: str + "-1") // quoted: false
        csv.write(field: str + "-\n-2", quoted: true)
        
        stream.close()
        let data = stream.data!
        let csvStr = String(data: data, encoding: .utf8)!
        
        XCTAssertEqual(csvStr, "\(str)-1,\"\(str)-\n-2\"")
    }
    
    /// xxxx,"xx""xx"
    func testEscapeQuote() {
        let str = "TEST-test-1234-😄😆👨‍👩‍👧‍👦"
        
        let stream = OutputStream(toMemory: ())
        stream.open()
        
        let csv = CSVWriter(stream: stream)
        csv.beginNewRecord()
        csv.write(field: str + "-1") // quoted: false
        csv.write(field: str + "-\"-2", quoted: true)
        
        stream.close()
        let data = stream.data!
        let csvStr = String(data: data, encoding: .utf8)!
        
        XCTAssertEqual(csvStr, "\(str)-1,\"\(str)-\"\"-2\"")
    }
    
}
