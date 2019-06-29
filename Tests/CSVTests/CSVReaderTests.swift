//
//  CSVReaderTests.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/11.
//  Copyright © 2016 yaslab. All rights reserved.
//

import XCTest
@testable import CSV

class CSVReaderTests: XCTestCase {

    func testOneLine() {
        let csv = "\"abc\",1,2"
        var i = 0

        for record in AnyIterator(try! CSVReader(string: csv)) {
            switch i {
            case 0: XCTAssertEqual(record, ["abc", "1", "2"])
            default: break
            }
            i += 1
        }
        XCTAssertEqual(i, 1)
    }

    func testTwoLines() {
        let csv = "\"abc\",1,2\n\"cde\",3,4"
        var i = 0
        for record in AnyIterator(try! CSVReader(string: csv)) {
            switch i {
            case 0: XCTAssertEqual(record, ["abc", "1", "2"])
            case 1: XCTAssertEqual(record, ["cde", "3", "4"])
            default: break
            }
            i += 1
        }
        XCTAssertEqual(i, 2)
    }

    func testLastLineIsEmpty() {
        let csv = "\"abc\",1,2\n\"cde\",3,4\n"
        var i = 0
        for record in AnyIterator(try! CSVReader(string: csv)) {
            switch i {
            case 0: XCTAssertEqual(record, ["abc", "1", "2"])
            case 1: XCTAssertEqual(record, ["cde", "3", "4"])
            default: break
            }
            i += 1
        }
        XCTAssertEqual(i, 2)
    }

    func testLastLineIsWhiteSpace() {
        let csv = "\"abc\",1,2\n\"cde\",3,4\n "
        var i = 0
        for record in AnyIterator(try! CSVReader(string: csv)) {
            switch i {
            case 0: XCTAssertEqual(record, ["abc", "1", "2"])
            case 1: XCTAssertEqual(record, ["cde", "3", "4"])
            case 2: XCTAssertEqual(record, [" "])
            default: break
            }
            i += 1
        }
        XCTAssertEqual(i, 3)
    }

    func testMiddleLineIsEmpty() {
        let csv = "\"abc\",1,2\n\n\"cde\",3,4"
        var i = 0
        for record in AnyIterator(try! CSVReader(string: csv)) {
            switch i {
            case 0: XCTAssertEqual(record, ["abc", "1", "2"])
            case 1: XCTAssertEqual(record, [""])
            case 2: XCTAssertEqual(record, ["cde", "3", "4"])
            default: break
            }
            i += 1
        }
        XCTAssertEqual(i, 3)
    }

    func testCommaInQuotationMarks() {
        let csvString = "abab,\"cd,cd\",efef"
        let csv = try! CSVReader(string: csvString)
        let record = csv.next()!
        XCTAssertEqual(record, ["abab", "cd,cd", "efef"])
    }

    func testEscapedQuotationMark1() {
        let csvString = "abab,\"\"\"cdcd\",efef\r\nzxcv,asdf,qwer"
        let csv = try! CSVReader(string: csvString)
        var record = csv.next()!
        XCTAssertEqual(record, ["abab", "\"cdcd", "efef"])
        record = csv.next()!
        XCTAssertEqual(record, ["zxcv", "asdf", "qwer"])
    }

    func testEscapedQuotationMark2() {
        let csvString = "abab,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\""
        let csv = try! CSVReader(string: csvString)
        var record = csv.next()!
        XCTAssertEqual(record, ["abab", "cdcd", "efef"])
        record = csv.next()!
        XCTAssertEqual(record, ["zxcv", "asdf", "qw\"er"])
    }

    func testEmptyField() {
        let csvString = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\","
        let csv = try! CSVReader(string: csvString)
        var record = csv.next()!
        XCTAssertEqual(record, ["abab", "", "cdcd", "efef"])
        record = csv.next()!
        XCTAssertEqual(record, ["zxcv", "asdf", "qw\"er", ""])
    }

    func testDoubleQuoteBeforeLineBreak1() {
        let csv = "\"abc\",1,\"2\"\n\n\"cde\",3,\"4\""
        var i = 0
        for record in AnyIterator(try! CSVReader(string: csv)) {
            switch i {
            case 0: XCTAssertEqual(record, ["abc", "1", "2"])
            case 1: XCTAssertEqual(record, [""])
            case 2: XCTAssertEqual(record, ["cde", "3", "4"])
            default: break
            }
            i += 1
        }
        XCTAssertEqual(i, 3)
    }

    func testDoubleQuoteBeforeLineBreak2() {
        let csv = "\"abc\",1,\"2\"\r\n\"cde\",3,\"4\"\r"
        var i = 0
        for record in AnyIterator(try! CSVReader(string: csv)) {
            switch i {
            case 0: XCTAssertEqual(record, ["abc", "1", "2"])
            case 1: XCTAssertEqual(record, ["cde", "3", "4"])
            default: break
            }
            i += 1
        }
        XCTAssertEqual(i, 2)
    }

    func testCSVState1() {
        let it = "あ,い1,\"う\",えお\n,,x,".unicodeScalars.makeIterator()
        let config = CSVReader.Configuration(hasHeaderRow: false,
                                             trimFields: false,
                                             delimiter: ",",
                                             whitespaces: .whitespaces)
        let csv = try! CSVReader(iterator: it, configuration: config)

        var records = [[String]]()

        while let record = csv.next() {
            records.append(record)
        }
        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records[0], ["あ", "い1", "う", "えお"])
        XCTAssertEqual(records[1], ["", "", "x", ""])
    }

    func testSubscriptInt() {
        let csvString = "a,bb,ccc"
        let csv = try! CSVReader(string: csvString)
        for record in AnyIterator(csv) {
            XCTAssertEqual(record[0], "a")
            XCTAssertEqual(record[1], "bb")
            XCTAssertEqual(record[2], "ccc")
        }
    }

    func testHasHeaderRow1() {
        let csvString = "key1,key2\nvalue1,value2"
        let csv = try! CSVReader(string: csvString, hasHeaderRow: true)
        XCTAssertEqual(csv.headerRow, ["key1", "key2"])
        XCTAssertNil(csv.currentRow)
        csv.next()
        XCTAssertEqual(csv.currentRow, ["value1", "value2"])
    }

    func testHasHeaderRow2() {
        let csvString = "key1,key2\n"
        let csv = try! CSVReader(string: csvString, hasHeaderRow: true)
        XCTAssertEqual(csv.headerRow, ["key1", "key2"])
        XCTAssertNil(csv.currentRow)
        csv.next()
        XCTAssertNil(csv.currentRow)
    }

    func testHasHeaderRow3() {
        let csvString = "key1,key2"
        let csv = try! CSVReader(string: csvString, hasHeaderRow: true)
        XCTAssertEqual(csv.headerRow, ["key1", "key2"])
        XCTAssertNil(csv.currentRow)
        csv.next()
        XCTAssertNil(csv.currentRow)
    }

    func testHasHeaderRow4() {
        let csvString = ""
        do {
            _ = try CSVReader(string: csvString, hasHeaderRow: true)
            XCTFail("CSVReader did not throw an error")
        } catch CSVError.cannotReadHeaderRow {
            // Success
        } catch {
            XCTFail("\(error)")
        }
    }

    func testSubscript1() {
        let csvString = "key1,key2\nvalue1,value2"
        let csv = try! CSVReader(string: csvString, hasHeaderRow: true)
        csv.next()
        XCTAssertEqual(csv["key1"], "value1")
        XCTAssertEqual(csv["key2"], "value2")
        XCTAssertNil(csv["key9"])
    }

    func testSubscript2() {
        let csvString = "key1,key2\nvalue1"
        let csv = try! CSVReader(string: csvString, hasHeaderRow: true)
        csv.next()
        XCTAssertEqual(csv["key1"], "value1")
        XCTAssertEqual(csv["key2"], "")
        XCTAssertNil(csv["key9"])
    }

    func testToArray() {
        let csvString = "1,2,3,4,5\n6,7,8,9,0"
        let csv = try! CSVReader(string: csvString)
        let records = AnyIterator(csv).map { $0 }
        XCTAssertEqual(records[0], ["1", "2", "3", "4", "5"])
        XCTAssertEqual(records[1], ["6", "7", "8", "9", "0"])
    }

}
