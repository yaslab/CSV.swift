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
        ("testFromFilePath", testFromFilePath),
        ("testGettingTheHeaderRow", testGettingTheHeaderRow),
        ("testGetTheFieldValueUsingSubscript", testGetTheFieldValueUsingSubscript),
        ("testProvideTheCharacterEncoding", testProvideTheCharacterEncoding)
    ]
    
    func testFromCSVString() {
        for row in try! CSV(string: "1,foo\n2,bar") {
            print("\(row)")
            // => ["1", "foo"]
            // => ["2", "bar"]
        }
    }
    
    func testFromFilePath() {
//        let stream = InputStream(fileAtPath: "/path/to/file.csv")!
//        for row in try! CSV(stream: stream) {
//            print("\(row)")
//        }
    }
    
    func testGettingTheHeaderRow() {
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
    }
    
    func testGetTheFieldValueUsingSubscript() {
        var csv = try! CSV(
            string: "id,name\n1,foo",
            hasHeaderRow: true) // It must be true.
        
        while let _ = csv.next() {
            print("\(csv["id"]!)")   // => "1"
            print("\(csv["name"]!)") // => "foo"
        }
    }
    
    func testProvideTheCharacterEncoding() {
//        let csv = try! CSV(
//            stream: InputStream(fileAtPath: "/path/to/file.csv")!,
//            codecType: UTF16.self,
//            endian: .big)
    }
    
}
