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
        ("testTrimFields14", testTrimFields14),
        ("testTrimFields15", testTrimFields15),
        ("testTrimFields16", testTrimFields16),
        ("testTrimFields17", testTrimFields17),
        ("testTrimFields18", testTrimFields18)
    ]

    func testTrimFields1() {
        let csvString = "abc,def,ghi"
        let csv = try! CSVReader(string: csvString, trimFields: true)
        for record in AnyIterator(csv) {
            XCTAssertEqual(record, ["abc", "def", "ghi"])
        }
    }

    func testTrimFields2() {
        let csvString = " abc,  def,   ghi"
        let csv = try! CSVReader(string: csvString, trimFields: true)
        for record in AnyIterator(csv) {
            XCTAssertEqual(record, ["abc", "def", "ghi"])
        }
    }

    func testTrimFields3() {
        let csvString = "abc ,def  ,ghi   "
        let csv = try! CSVReader(string: csvString, trimFields: true)
        for record in AnyIterator(csv) {
            XCTAssertEqual(record, ["abc", "def", "ghi"])
        }
    }

    func testTrimFields4() {
        let csvString = " abc ,  def  ,   ghi   "
        let csv = try! CSVReader(string: csvString, trimFields: true)
        for record in AnyIterator(csv) {
            XCTAssertEqual(record, ["abc", "def", "ghi"])
        }
    }

    func testTrimFields5() {
        let csvString = "\"abc\",\"def\",\"ghi\""
        let csv = try! CSVReader(string: csvString, trimFields: true)
        for record in AnyIterator(csv) {
            XCTAssertEqual(record, ["abc", "def", "ghi"])
        }
    }

    func testTrimFields6() {
        let csvString = " \"abc\",  \"def\",   \"ghi\""
        let csv = try! CSVReader(string: csvString, trimFields: true)
        for record in AnyIterator(csv) {
            XCTAssertEqual(record, ["abc", "def", "ghi"])
        }
    }

    func testTrimFields7() {
        let csvString = "\"abc\" ,\"def\"  ,\"ghi\"   "
        let csv = try! CSVReader(string: csvString, trimFields: true)
        for record in AnyIterator(csv) {
            XCTAssertEqual(record, ["abc", "def", "ghi"])
        }
    }

    func testTrimFields8() {
        let csvString = " \"abc\" ,  \"def\"  ,   \"ghi\"   "
        let csv = try! CSVReader(string: csvString, trimFields: true)
        for record in AnyIterator(csv) {
            XCTAssertEqual(record, ["abc", "def", "ghi"])
        }
    }

    func testTrimFields9() {
        let csvString = "\" abc \",\" def \",\" ghi \""
        let csv = try! CSVReader(string: csvString, trimFields: true)
        for record in AnyIterator(csv) {
            XCTAssertEqual(record, [" abc ", " def ", " ghi "])
        }
    }

    func testTrimFields10() {
        let csvString = "\tabc,\t\tdef\t,ghi\t"
        let csv = try! CSVReader(string: csvString, trimFields: true)
        for record in AnyIterator(csv) {
            XCTAssertEqual(record, ["abc", "def", "ghi"])
        }
    }

    func testTrimFields11() {
        let csvString = " abc \n def "
        let csv = try! CSVReader(string: csvString, trimFields: true)

        let record1 = csv.next()!
        XCTAssertEqual(record1, ["abc"])
        let record2 = csv.next()!
        XCTAssertEqual(record2, ["def"])
    }

    func testTrimFields12() {
        let csvString = " \"abc \" \n \" def\" "
        let csv = try! CSVReader(string: csvString, trimFields: true)

        let record1 = csv.next()!
        XCTAssertEqual(record1, ["abc "])
        let record2 = csv.next()!
        XCTAssertEqual(record2, [" def"])
    }

    func testTrimFields13() {
        let csvString = " abc \t\tdef\t ghi "
        let csv = try! CSVReader(string: csvString, trimFields: true, delimiter: "\t")
        for record in AnyIterator(csv) {
            XCTAssertEqual(record, ["abc", "", "def", "ghi"])
        }
    }

    func testTrimFields14() {
        let csvString = ""
        let csv = try! CSVReader(string: csvString, trimFields: true)
        let records = AnyIterator(csv).map { $0 }

        XCTAssertEqual(records.count, 0)
    }

    func testTrimFields15() {
        let csvString = " "
        let csv = try! CSVReader(string: csvString, trimFields: true)
        let records = AnyIterator(csv).map { $0 }

        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records[0], [""])
    }

    func testTrimFields16() {
        let csvString = " , "
        let csv = try! CSVReader(string: csvString, trimFields: true)
        let records = AnyIterator(csv).map { $0 }

        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records[0], ["", ""])
    }

    func testTrimFields17() {
        let csvString = " , \n"
        let csv = try! CSVReader(string: csvString, trimFields: true)
        let records = AnyIterator(csv).map { $0 }

        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records[0], ["", ""])
    }

    func testTrimFields18() {
        let csvString = " , \n "
        let csv = try! CSVReader(string: csvString, trimFields: true)
        let records = AnyIterator(csv).map { $0 }

        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records[0], ["", ""])
        XCTAssertEqual(records[1], [""])
    }

}
