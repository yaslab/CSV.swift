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
        ("testSubscript", testSubscript),
        ("testCSVState1", testCSVState1)
    ]
    
    func testOneLine() {
        let csv = "\"abc\",1,2"
        var i = 0
        for row in try! CSV(string: csv) {
            switch i {
            case 0: XCTAssertEqual(row, ["abc", "1", "2"])
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
            case 0: XCTAssertEqual(row, ["abc", "1", "2"])
            case 1: XCTAssertEqual(row, ["cde", "3", "4"])
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
            case 0: XCTAssertEqual(row, ["abc", "1", "2"])
            case 1: XCTAssertEqual(row, ["cde", "3", "4"])
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
            case 0: XCTAssertEqual(row, ["abc", "1", "2"])
            case 1: XCTAssertEqual(row, ["cde", "3", "4"])
            case 2: XCTAssertEqual(row, [" "])
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
            case 0: XCTAssertEqual(row, ["abc", "1", "2"])
            case 1: XCTAssertEqual(row, [""])
            case 2: XCTAssertEqual(row, ["cde", "3", "4"])
            default: break
            }
            i += 1
        }
        XCTAssertEqual(i, 3)
    }
    
    func testCommaInQuotationMarks() {
        let csvString = "abab,\"cd,cd\",efef"
        var csv = try! CSV(string: csvString)
        let row = csv.next()!
        XCTAssertEqual(row, ["abab", "cd,cd", "efef"])
    }
    
    func testEscapedQuotationMark1() {
        let csvString = "abab,\"\"\"cdcd\",efef\r\nzxcv,asdf,qwer"
        var csv = try! CSV(string: csvString)
        var row = csv.next()!
        XCTAssertEqual(row, ["abab", "\"cdcd", "efef"])
        row = csv.next()!
        XCTAssertEqual(row, ["zxcv", "asdf", "qwer"])
    }
    
    func testEscapedQuotationMark2() {
        let csvString = "abab,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\""
        var csv = try! CSV(string: csvString)
        var row = csv.next()!
        XCTAssertEqual(row, ["abab", "cdcd", "efef"])
        row = csv.next()!
        XCTAssertEqual(row, ["zxcv", "asdf", "qw\"er"])
    }
    
    func testEmptyField() {
        let csvString = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\","
        var csv = try! CSV(string: csvString)
        var row = csv.next()!
        XCTAssertEqual(row, ["abab", "", "cdcd", "efef"])
        row = csv.next()!
        XCTAssertEqual(row, ["zxcv", "asdf", "qw\"er", ""])
    }
    
    func testDoubleQuoteBeforeLineBreak() {
        let csv = "\"abc\",1,\"2\"\n\n\"cde\",3,\"4\""
        var i = 0
        for row in try! CSV(string: csv) {
            switch i {
            case 0: XCTAssertEqual(row, ["abc", "1", "2"])
            case 1: XCTAssertEqual(row, [""])
            case 2: XCTAssertEqual(row, ["cde", "3", "4"])
            default: break
            }
            i += 1
        }
        XCTAssertEqual(i, 3)
    }

    func testSubscript() {
        let csvString = "id,name\n001,hoge\n002,fuga"
        var csv = try! CSV(string: csvString, hasHeaderRow: true)
        var i = 0
        while csv.next() != nil {
            switch i {
            case 0:
                XCTAssertEqual(csv["id"], "001")
                XCTAssertEqual(csv["name"], "hoge")
            case 1:
                XCTAssertEqual(csv["id"], "002")
                XCTAssertEqual(csv["name"], "fuga")
            default:
                break
            }
            i += 1
        }
        XCTAssertEqual(i, 2)
    }
    
    func testCSVState1() {
        let it = "あ,い1,\"う\",えお\n,,x,".unicodeScalars.makeIterator()
        var csv = try! CSV(iterator: it, hasHeaderRow: defaultHasHeaderRow, trimFields: defaultTrimFields, delimiter: defaultDelimiter)
        
        var rows = [[String]]()
        
        while let row = csv.next() {
            rows.append(row)
        }
        XCTAssertEqual(rows.count, 2)
        XCTAssertEqual(rows[0], ["あ", "い1", "う", "えお"])
        XCTAssertEqual(rows[1], ["", "", "x", ""])
    }

}
