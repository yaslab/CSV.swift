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
    
    func testFromCSVString() {
        let csv = try! CSV(string: "1,foo\n2,bar")
        for row in csv {
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
        let config = CSVConfiguration(hasHeaderRow: true) // It must be true.
        let csv = try! CSV(string: csvString, config: config)
        
        let headerRow = csv.headerRow!
        print("\(headerRow)") // => ["id", "name"]
        
        for row in csv {
            print("\(row)")
            // => ["1", "foo"]
            // => ["2", "bar"]
        }
    }

    func testGetTheFieldValueUsingIndex() {
        let csvString = "1,foo"
        let csv = try! CSV(string: csvString)
        
        for row in csv {
            print("\(row[0])") // => "1"
            print("\(row[1])") // => "foo"
        }
    }

    
    func testGetTheFieldValueUsingKey() {
        let csvString = "id,name\n1,foo"
        let config = CSVConfiguration(hasHeaderRow: true) // It must be true.
        let csv = try! CSV(string: csvString, config: config)
        
        for row in csv {
            print("\(row["id"]!)")   // => "1"
            print("\(row["name"]!)") // => "foo"
        }
    }
    
    func testProvideTheCharacterEncoding() {
//        let csv = try! CSV(
//            stream: InputStream(fileAtPath: "/path/to/file.csv")!,
//            codecType: UTF16.self,
//            endian: .big)
    }
    
}
