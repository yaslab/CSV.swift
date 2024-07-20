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

    func testOneLine() throws {
        let csv = "\"abc\",1,2"
        var i = 0

        for result in CSVReader(string: csv) {
            let record = try result.get()
            switch i {
            case 0: XCTAssertEqual(record.columns, ["abc", "1", "2"])
            default: break
            }
            i += 1
        }
        XCTAssertEqual(i, 1)
    }

    func testTwoLines() throws {
        let csv = "\"abc\",1,2\n\"cde\",3,4"
        var i = 0
        for result in CSVReader(string: csv) {
            let record = try result.get()
            switch i {
            case 0: XCTAssertEqual(record.columns, ["abc", "1", "2"])
            case 1: XCTAssertEqual(record.columns, ["cde", "3", "4"])
            default: break
            }
            i += 1
        }
        XCTAssertEqual(i, 2)
    }

    func testLastLineIsEmpty() throws {
        let csv = "\"abc\",1,2\n\"cde\",3,4\n"
        var i = 0
        for result in CSVReader(string: csv) {
            let record = try result.get()
            switch i {
            case 0: XCTAssertEqual(record.columns, ["abc", "1", "2"])
            case 1: XCTAssertEqual(record.columns, ["cde", "3", "4"])
            default: break
            }
            i += 1
        }
        XCTAssertEqual(i, 2)
    }

    func testLastLineIsWhiteSpace() throws {
        let csv = "\"abc\",1,2\n\"cde\",3,4\n "
        var i = 0
        for result in CSVReader(string: csv) {
            let record = try result.get()
            switch i {
            case 0: XCTAssertEqual(record.columns, ["abc", "1", "2"])
            case 1: XCTAssertEqual(record.columns, ["cde", "3", "4"])
            case 2: XCTAssertEqual(record.columns, [" "])
            default: break
            }
            i += 1
        }
        XCTAssertEqual(i, 3)
    }

    func testMiddleLineIsEmpty() throws {
        let csv = "\"abc\",1,2\n\n\"cde\",3,4"
        var i = 0
        for result in CSVReader(string: csv) {
            let record = try result.get()
            switch i {
            case 0: XCTAssertEqual(record.columns, ["abc", "1", "2"])
            case 1: XCTAssertEqual(record.columns, [""])
            case 2: XCTAssertEqual(record.columns, ["cde", "3", "4"])
            default: break
            }
            i += 1
        }
        XCTAssertEqual(i, 3)
    }

    func testCommaInQuotationMarks() throws {
        let csvString = "abab,\"cd,cd\",efef"
        let csv = CSVReader(string: csvString)
        let record = try Array(csv)[0].get()
        XCTAssertEqual(record.columns, ["abab", "cd,cd", "efef"])
    }

    func testEscapedQuotationMark1() throws {
        let csvString = "abab,\"\"\"cdcd\",efef\r\nzxcv,asdf,qwer"
        let csv = Array(CSVReader(string: csvString))
        var record = try csv[0].get()
        XCTAssertEqual(record.columns, ["abab", "\"cdcd", "efef"])
        record = try csv[1].get()
        XCTAssertEqual(record.columns, ["zxcv", "asdf", "qwer"])
    }

    func testEscapedQuotationMark2() throws {
        let csvString = "abab,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\""
        let csv = Array(CSVReader(string: csvString))
        var record = try csv[0].get()
        XCTAssertEqual(record.columns, ["abab", "cdcd", "efef"])
        record = try csv[1].get()
        XCTAssertEqual(record.columns, ["zxcv", "asdf", "qw\"er"])
    }

    func testEmptyField() throws {
        let csvString = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\","
        let csv = Array(CSVReader(string: csvString))
        var record = try csv[0].get()
        XCTAssertEqual(record.columns, ["abab", "", "cdcd", "efef"])
        record = try csv[1].get()
        XCTAssertEqual(record.columns, ["zxcv", "asdf", "qw\"er", ""])
    }

    func testDoubleQuoteBeforeLineBreak1() throws {
        let csv = "\"abc\",1,\"2\"\n\n\"cde\",3,\"4\""
        var i = 0
        for result in CSVReader(string: csv) {
            let record = try result.get()
            switch i {
            case 0: XCTAssertEqual(record.columns, ["abc", "1", "2"])
            case 1: XCTAssertEqual(record.columns, [""])
            case 2: XCTAssertEqual(record.columns, ["cde", "3", "4"])
            default: break
            }
            i += 1
        }
        XCTAssertEqual(i, 3)
    }

    func testDoubleQuoteBeforeLineBreak2() throws {
        let csv = "\"abc\",1,\"2\"\r\n\"cde\",3,\"4\"\r"
        var i = 0
        for result in CSVReader(string: csv) {
            let record = try result.get()
            switch i {
            case 0: XCTAssertEqual(record.columns, ["abc", "1", "2"])
            case 1: XCTAssertEqual(record.columns, ["cde", "3", "4"])
            default: break
            }
            i += 1
        }
        XCTAssertEqual(i, 2)
    }

    func testCSVState1() throws {
        let data = "あ,い1,\"う\",えお\n,,x,".data(using: .utf8)!

        let csv = CSVReader(data: data)

        let records = Array(csv)

        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(try records[0].get().columns, ["あ", "い1", "う", "えお"])
        XCTAssertEqual(try records[1].get().columns, ["", "", "x", ""])
    }

    func testSubscriptInt() throws {
        let csvString = "a,bb,ccc"
        let csv = CSVReader(string: csvString)
        for result in csv {
            let record = try result.get()
            XCTAssertEqual(record[0], "a")
            XCTAssertEqual(record[1], "bb")
            XCTAssertEqual(record[2], "ccc")
        }
    }

    func testHasHeaderRow1() throws {
        let csvString = "key1,key2\nvalue1,value2"
        let csv = CSVReader(string: csvString, configuration: .init(hasHeaderRow: true))
        var it = csv.makeIterator()
        let row = try it.next()!.get()
        XCTAssertEqual(row.header, ["key1", "key2"])
        XCTAssertEqual(row.columns, ["value1", "value2"])
    }

    func testHasHeaderRow2() throws {
        let csvString = "key1,key2\n"
        let csv = CSVReader(string: csvString, configuration: .init(hasHeaderRow: true))
        var it = csv.makeIterator()
        let result = it.next()
        XCTAssertNil(result)
    }

    func testHasHeaderRow3() throws {
        let csvString = "key1,key2"
        let csv = CSVReader(string: csvString, configuration: .init(hasHeaderRow: true))
        var it = csv.makeIterator()
        let result = it.next()
        XCTAssertNil(result)
    }

    func testHasHeaderRow4() throws {
        let csvString = ""
        do {
            let csv = CSVReader(string: csvString, configuration: .init(hasHeaderRow: true))
            var it = csv.makeIterator()
            let result = it.next()
            try result?.get()
            XCTFail("CSVReader did not throw an error")
        } catch CSVError.cannotReadHeaderRow {
            // Success
        } catch {
            XCTFail("\(error)")
        }
    }

    func testSubscript1() throws {
        let csvString = "key1,key2\nvalue1,value2"
        let csv = CSVReader(string: csvString, configuration: .init(hasHeaderRow: true))
        let rows = Array(csv)
        let row = try rows[0].get()
        XCTAssertEqual(row["key1"], "value1")
        XCTAssertEqual(row["key2"], "value2")
        XCTAssertNil(row["key9"])
    }

    func testSubscript2() throws {
        let csvString = "key1,key2\nvalue1"
        let csv = CSVReader(string: csvString, configuration: .init(hasHeaderRow: true))
        let rows = Array(csv)
        let row = try rows[0].get()
        XCTAssertEqual(row["key1"], "value1")
        XCTAssertEqual(row["key2"], "")
        XCTAssertNil(row["key9"])
    }

    func testToArray() throws {
        let csvString = "1,2,3,4,5\n6,7,8,9,0"
        let csv = CSVReader(string: csvString)
        let records = Array(csv)
        XCTAssertEqual(try records[0].get().columns, ["1", "2", "3", "4", "5"])
        XCTAssertEqual(try records[1].get().columns, ["6", "7", "8", "9", "0"])
    }

}
