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

    func testTrimFields1() {
        let csvString = "abc,def,ghi"
        let config = CSVConfiguration(trimFields: true)
        let csv = try! CSV(string: csvString, config: config)
        for row in csv {
            XCTAssertEqual(row.toArray(), ["abc", "def", "ghi"])
        }
    }

    func testTrimFields2() {
        let csvString = " abc,  def,   ghi"
        let config = CSVConfiguration(trimFields: true)
        let csv = try! CSV(string: csvString, config: config)
        for row in csv {
            XCTAssertEqual(row.toArray(), ["abc", "def", "ghi"])
        }
    }

    func testTrimFields3() {
        let csvString = "abc ,def  ,ghi   "
        let config = CSVConfiguration(trimFields: true)
        let csv = try! CSV(string: csvString, config: config)
        for row in csv {
            XCTAssertEqual(row.toArray(), ["abc", "def", "ghi"])
        }
    }

    func testTrimFields4() {
        let csvString = " abc ,  def  ,   ghi   "
        let config = CSVConfiguration(trimFields: true)
        let csv = try! CSV(string: csvString, config: config)
        for row in csv {
            XCTAssertEqual(row.toArray(), ["abc", "def", "ghi"])
        }
    }

    func testTrimFields5() {
        let csvString = "\"abc\",\"def\",\"ghi\""
        let config = CSVConfiguration(trimFields: true)
        let csv = try! CSV(string: csvString, config: config)
        for row in csv {
            XCTAssertEqual(row.toArray(), ["abc", "def", "ghi"])
        }
    }

    func testTrimFields6() {
        let csvString = " \"abc\",  \"def\",   \"ghi\""
        let config = CSVConfiguration(trimFields: true)
        let csv = try! CSV(string: csvString, config: config)
        for row in csv {
            XCTAssertEqual(row.toArray(), ["abc", "def", "ghi"])
        }
    }

    func testTrimFields7() {
        let csvString = "\"abc\" ,\"def\"  ,\"ghi\"   "
        let config = CSVConfiguration(trimFields: true)
        let csv = try! CSV(string: csvString, config: config)
        for row in csv {
            XCTAssertEqual(row.toArray(), ["abc", "def", "ghi"])
        }
    }

    func testTrimFields8() {
        let csvString = " \"abc\" ,  \"def\"  ,   \"ghi\"   "
        let config = CSVConfiguration(trimFields: true)
        let csv = try! CSV(string: csvString, config: config)
        for row in csv {
            XCTAssertEqual(row.toArray(), ["abc", "def", "ghi"])
        }
    }

    func testTrimFields9() {
        let csvString = "\" abc \",\" def \",\" ghi \""
        let config = CSVConfiguration(trimFields: true)
        let csv = try! CSV(string: csvString, config: config)
        for row in csv {
            XCTAssertEqual(row.toArray(), [" abc ", " def ", " ghi "])
        }
    }

    func testTrimFields10() {
        let csvString = "\tabc,\t\tdef\t,ghi\t"
        let config = CSVConfiguration(trimFields: true)
        let csv = try! CSV(string: csvString, config: config)
        for row in csv {
            XCTAssertEqual(row.toArray(), ["abc", "def", "ghi"])
        }
    }

    func testTrimFields11() {
        let csvString = " abc \n def "
        let config = CSVConfiguration(trimFields: true)
        var csv = try! CSV(string: csvString, config: config)

        let row1 = csv.next()!
        XCTAssertEqual(row1.toArray(), ["abc"])
        let row2 = csv.next()!
        XCTAssertEqual(row2.toArray(), ["def"])
    }

    func testTrimFields12() {
        let csvString = " \"abc \" \n \" def\" "
        let config = CSVConfiguration(trimFields: true)
        var csv = try! CSV(string: csvString, config: config)

        let row1 = csv.next()!
        XCTAssertEqual(row1.toArray(), ["abc "])
        let row2 = csv.next()!
        XCTAssertEqual(row2.toArray(), [" def"])
    }

    func testTrimFields13() {
        let csvString = " abc \t\tdef\t ghi "
        let config = CSVConfiguration(trimFields: true, delimiter: UnicodeScalar("\t")!)
        let csv = try! CSV(string: csvString, config: config)
        for row in csv {
            XCTAssertEqual(row.toArray(), ["abc", "", "def", "ghi"])
        }
    }

}
