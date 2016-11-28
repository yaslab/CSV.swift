//
//  TrimFieldsTests.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/10/18.
//  Copyright © 2016 yaslab. All rights reserved.
//

import XCTest
@testable import CSV

class TrimFieldsTests: XCTestCase {
    
    static let allTests = [
        ("testTrimFields1", testTrimFields1),
        ("testTrimFields2", testTrimFields2),
        ("testTrimFields3", testTrimFields3),
        ("testTrimFields4", testTrimFields4),
        ("testTrimFields5", testTrimFields5),
        ("testTrimFields6", testTrimFields6),
        ("testTrimFields7", testTrimFields7),
        ("testTrimFields8", testTrimFields8),
        ("testTrimFields9", testTrimFields9),
        ("testTrimFields10", testTrimFields10),
        ("testTrimFields11", testTrimFields11),
        ("testTrimFields12", testTrimFields12),
        ("testTrimFields13", testTrimFields13),
    ]

    func testTrimFields1() {
        let csvString = "abc,def,ghi"
        let csv = try! CSV(string: csvString, trimFields: true)
        for row in csv {
            XCTAssertEqual(row, ["abc", "def", "ghi"])
        }
    }
    
    func testTrimFields2() {
        let csvString = " abc,  def,   ghi"
        let csv = try! CSV(string: csvString, trimFields: true)
        for row in csv {
            XCTAssertEqual(row, ["abc", "def", "ghi"])
        }
    }
    
    func testTrimFields3() {
        let csvString = "abc ,def  ,ghi   "
        let csv = try! CSV(string: csvString, trimFields: true)
        for row in csv {
            XCTAssertEqual(row, ["abc", "def", "ghi"])
        }
    }
    
    func testTrimFields4() {
        let csvString = " abc ,  def  ,   ghi   "
        let csv = try! CSV(string: csvString, trimFields: true)
        for row in csv {
            XCTAssertEqual(row, ["abc", "def", "ghi"])
        }
    }
    
    func testTrimFields5() {
        let csvString = "\"abc\",\"def\",\"ghi\""
        let csv = try! CSV(string: csvString, trimFields: true)
        for row in csv {
            XCTAssertEqual(row, ["abc", "def", "ghi"])
        }
    }
    
    func testTrimFields6() {
        let csvString = " \"abc\",  \"def\",   \"ghi\""
        let csv = try! CSV(string: csvString, trimFields: true)
        for row in csv {
            XCTAssertEqual(row, ["abc", "def", "ghi"])
        }
    }
    
    func testTrimFields7() {
        let csvString = "\"abc\" ,\"def\"  ,\"ghi\"   "
        let csv = try! CSV(string: csvString, trimFields: true)
        for row in csv {
            XCTAssertEqual(row, ["abc", "def", "ghi"])
        }
    }
    
    func testTrimFields8() {
        let csvString = " \"abc\" ,  \"def\"  ,   \"ghi\"   "
        let csv = try! CSV(string: csvString, trimFields: true)
        for row in csv {
            XCTAssertEqual(row, ["abc", "def", "ghi"])
        }
    }
    
    func testTrimFields9() {
        let csvString = "\" abc \",\" def \",\" ghi \""
        let csv = try! CSV(string: csvString, trimFields: true)
        for row in csv {
            XCTAssertEqual(row, [" abc ", " def ", " ghi "])
        }
    }
    
    func testTrimFields10() {
        let csvString = "\tabc,\t\tdef\t,ghi\t"
        let csv = try! CSV(string: csvString, trimFields: true)
        for row in csv {
            XCTAssertEqual(row, ["abc", "def", "ghi"])
        }
    }
    
    func testTrimFields11() {
        let csvString = " abc \n def "
        var csv = try! CSV(string: csvString, trimFields: true)
        
        let row1 = csv.next()!
        XCTAssertEqual(row1, ["abc"])
        let row2 = csv.next()!
        XCTAssertEqual(row2, ["def"])
    }
    
    func testTrimFields12() {
        let csvString = " \"abc \" \n \" def\" "
        var csv = try! CSV(string: csvString, trimFields: true)
        
        let row1 = csv.next()!
        XCTAssertEqual(row1, ["abc "])
        let row2 = csv.next()!
        XCTAssertEqual(row2, [" def"])
    }
    
    func testTrimFields13() {
        let csvString = " abc \t\tdef\t ghi "
        let csv = try! CSV(string: csvString, trimFields: true, delimiter: UnicodeScalar("\t")!)
        for row in csv {
            XCTAssertEqual(row, ["abc", "", "def", "ghi"])
        }
    }
    
}
