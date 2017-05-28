//
//  CSVTests.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/11.
//  Copyright © 2016 yaslab. All rights reserved.
//

import XCTest
@testable import CSV

class CSVTests: XCTestCase {

    static let allTests = [
        ("testOneLine", testOneLine),
        ("testTwoLines", testTwoLines),
        ("testLastLineIsEmpty", testLastLineIsEmpty),
        ("testLastLineIsWhiteSpace", testLastLineIsWhiteSpace),
        ("testMiddleLineIsEmpty", testMiddleLineIsEmpty),
        ("testCommaInQuotationMarks", testCommaInQuotationMarks),
        ("testEscapedQuotationMark1", testEscapedQuotationMark1),
        ("testEscapedQuotationMark2", testEscapedQuotationMark2),
        ("testEmptyField", testEmptyField),
        ("testDoubleQuoteBeforeLineBreak", testDoubleQuoteBeforeLineBreak),
        ("testCSVState1", testCSVState1),
        ("testSubscriptInt", testSubscriptInt),
        ("testSubscriptString1", testSubscriptString1),
        ("testSubscriptString2", testSubscriptString2),
        ("testToArray", testToArray),
        ("testToDictionary1", testToDictionary1),
        ("testToDictionary2", testToDictionary2)
    ]

    func testOneLine() {
        let csv = "\"abc\",1,2"
        var i = 0
        for row in try! CSV(string: csv) {
            switch i {
            case 0: XCTAssertEqual(row.toArray(), ["abc", "1", "2"])
            default: break
            }
            i += 1
        }
        XCTAssertEqual(i, 1)
    }

    func testTwoLines() {
        let csv = "\"abc\",1,2\n\"cde\",3,4"
        var i = 0
        for row in try! CSV(string: csv) {
            switch i {
            case 0: XCTAssertEqual(row.toArray(), ["abc", "1", "2"])
            case 1: XCTAssertEqual(row.toArray(), ["cde", "3", "4"])
            default: break
            }
            i += 1
        }
        XCTAssertEqual(i, 2)
    }

    func testLastLineIsEmpty() {
        let csv = "\"abc\",1,2\n\"cde\",3,4\n"
        var i = 0
        for row in try! CSV(string: csv) {
            switch i {
            case 0: XCTAssertEqual(row.toArray(), ["abc", "1", "2"])
            case 1: XCTAssertEqual(row.toArray(), ["cde", "3", "4"])
            default: break
            }
            i += 1
        }
        XCTAssertEqual(i, 2)
    }

    func testLastLineIsWhiteSpace() {
        let csv = "\"abc\",1,2\n\"cde\",3,4\n "
        var i = 0
        for row in try! CSV(string: csv) {
            switch i {
            case 0: XCTAssertEqual(row.toArray(), ["abc", "1", "2"])
            case 1: XCTAssertEqual(row.toArray(), ["cde", "3", "4"])
            case 2: XCTAssertEqual(row.toArray(), [" "])
            default: break
            }
            i += 1
        }
        XCTAssertEqual(i, 3)
    }

    func testMiddleLineIsEmpty() {
        let csv = "\"abc\",1,2\n\n\"cde\",3,4"
        var i = 0
        for row in try! CSV(string: csv) {
            switch i {
            case 0: XCTAssertEqual(row.toArray(), ["abc", "1", "2"])
            case 1: XCTAssertEqual(row.toArray(), [""])
            case 2: XCTAssertEqual(row.toArray(), ["cde", "3", "4"])
            default: break
            }
            i += 1
        }
        XCTAssertEqual(i, 3)
    }

    func testCommaInQuotationMarks() {
        let csvString = "abab,\"cd,cd\",efef"
        let csv = try! CSV(string: csvString)
        let row = csv.next()!
        XCTAssertEqual(row.toArray(), ["abab", "cd,cd", "efef"])
    }

    func testEscapedQuotationMark1() {
        let csvString = "abab,\"\"\"cdcd\",efef\r\nzxcv,asdf,qwer"
        let csv = try! CSV(string: csvString)
        var row = csv.next()!
        XCTAssertEqual(row.toArray(), ["abab", "\"cdcd", "efef"])
        row = csv.next()!
        XCTAssertEqual(row.toArray(), ["zxcv", "asdf", "qwer"])
    }

    func testEscapedQuotationMark2() {
        let csvString = "abab,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\""
        let csv = try! CSV(string: csvString)
        var row = csv.next()!
        XCTAssertEqual(row.toArray(), ["abab", "cdcd", "efef"])
        row = csv.next()!
        XCTAssertEqual(row.toArray(), ["zxcv", "asdf", "qw\"er"])
    }

    func testEmptyField() {
        let csvString = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\","
        let csv = try! CSV(string: csvString)
        var row = csv.next()!
        XCTAssertEqual(row.toArray(), ["abab", "", "cdcd", "efef"])
        row = csv.next()!
        XCTAssertEqual(row.toArray(), ["zxcv", "asdf", "qw\"er", ""])
    }

    func testDoubleQuoteBeforeLineBreak() {
        let csv = "\"abc\",1,\"2\"\n\n\"cde\",3,\"4\""
        var i = 0
        for row in try! CSV(string: csv) {
            switch i {
            case 0: XCTAssertEqual(row.toArray(), ["abc", "1", "2"])
            case 1: XCTAssertEqual(row.toArray(), [""])
            case 2: XCTAssertEqual(row.toArray(), ["cde", "3", "4"])
            default: break
            }
            i += 1
        }
        XCTAssertEqual(i, 3)
    }

    func testCSVState1() {
        let it = "あ,い1,\"う\",えお\n,,x,".unicodeScalars.makeIterator()
        let csv = try! CSV(iterator: it, config: CSVConfiguration())

        var rows = [[String]]()

        while let row = csv.next() {
            rows.append(row.toArray())
        }
        XCTAssertEqual(rows.count, 2)
        XCTAssertEqual(rows[0], ["あ", "い1", "う", "えお"])
        XCTAssertEqual(rows[1], ["", "", "x", ""])
    }

    func testSubscriptInt() {
        let csvString = "a,bb,ccc"
        let csv = try! CSV(string: csvString)
        for row in csv {
            XCTAssertEqual(row[0], "a")
            XCTAssertEqual(row[1], "bb")
            XCTAssertEqual(row[2], "ccc")
        }
    }

    func testSubscriptString1() {
        let csvString = "key1,key2\nvalue1,value2"
        let config = CSVConfiguration(hasHeaderRow: true)
        let csv = try! CSV(string: csvString, config: config)
        for row in csv {
            XCTAssertEqual(row["key1"], "value1")
            XCTAssertEqual(row["key2"], "value2")
            XCTAssertNil(row["key9"])
        }
    }

    func testSubscriptString2() {
        let csvString = "key1,key2\nvalue1"
        let config = CSVConfiguration(hasHeaderRow: true)
        let csv = try! CSV(string: csvString, config: config)
        for row in csv {
            XCTAssertEqual(row["key1"], "value1")
            XCTAssertNil(row["key2"])
            XCTAssertNil(row["key9"])
        }
    }

    func testToArray() {
        let csvString = "1,2,3,4,5\n6,7,8,9,0"
        let csv = try! CSV(string: csvString)
        let rows = csv.map { $0.toArray() }
        XCTAssertEqual(rows[0], ["1", "2", "3", "4", "5"])
        XCTAssertEqual(rows[1], ["6", "7", "8", "9", "0"])
    }

    func testToDictionary1() {
        let csvString = "id,name\n1,name1\n2,name2"
        let config = CSVConfiguration(hasHeaderRow: true)
        let csv = try! CSV(string: csvString, config: config)
        let rows = csv.map { $0.toDictionary() }
        XCTAssertEqual(rows[0]["id"], "1")
        XCTAssertEqual(rows[0]["name"], "name1")
        XCTAssertNil(rows[0]["xxx"])
        XCTAssertEqual(rows[1]["id"], "2")
        XCTAssertEqual(rows[1]["name"], "name2")
        XCTAssertNil(rows[1]["yyy"])
    }

    func testToDictionary2() {
        let csvString = "id,name,id\n1,name1,11\n2,name2,22"
        let config = CSVConfiguration(hasHeaderRow: true)
        let csv = try! CSV(string: csvString, config: config)
        let rows = csv.map { $0.toDictionary() }
        XCTAssertEqual(rows[0]["id"], "1")
        XCTAssertEqual(rows[0]["name"], "name1")
        XCTAssertNil(rows[0]["xxx"])
        XCTAssertEqual(rows[1]["id"], "2")
        XCTAssertEqual(rows[1]["name"], "name2")
        XCTAssertNil(rows[1]["yyy"])
    }

}