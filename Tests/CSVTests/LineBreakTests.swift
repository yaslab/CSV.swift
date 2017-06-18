//
//  LineBreakTests.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/11.
//  Copyright © 2016 yaslab. All rights reserved.
//

import XCTest
@testable import CSV

class LineBreakTests: XCTestCase {

    static let allTests = [
        ("testLF", testLF),
        ("testCRLF", testCRLF),
        ("testLastCR", testLastCR),
        ("testLastCRLF", testLastCRLF),
        ("testLastLF", testLastLF),
        ("testLFInQuotationMarks", testLFInQuotationMarks),
        ("testLineBreakLF", testLineBreakLF),
        ("testLineBreakCR", testLineBreakCR),
        ("testLineBreakCRLF", testLineBreakCRLF),
        ("testLineBreakLFLF", testLineBreakLFLF),
        ("testLineBreakCRCR", testLineBreakCRCR),
        ("testLineBreakCRLFCRLF", testLineBreakCRLFCRLF)
    ]

    func testLF() {
        let csv = "abab,cdcd,efef\nzxcv,asdf,qwer"
        let records = parse(csv: csv)
        XCTAssertEqual(records[0], ["abab", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qwer"])
    }

    func testCRLF() {
        let csv = "abab,cdcd,efef\r\nzxcv,asdf,qwer"
        let records = parse(csv: csv)
        XCTAssertEqual(records[0], ["abab", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qwer"])
    }

    func testLastCR() {
        let csv = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\",\r"
        let records = parse(csv: csv)
        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records[0], ["abab", "", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
    }

    func testLastCRLF() {
        let csv = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\",\r\n"
        let records = parse(csv: csv)
        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records[0], ["abab", "", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
    }

    func testLastLF() {
        let csv = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\",\n"
        let records = parse(csv: csv)
        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records[0], ["abab", "", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
    }

    func testLFInQuotationMarks() {
        let csv = "abab,,\"\rcdcd\n\",efef\r\nzxcv,asdf,\"qw\"\"er\",\n"
        let records = parse(csv: csv)
        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records[0], ["abab", "", "\rcdcd\n", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
    }

    func testLineBreakLF() {
        let csv = "qwe,asd\nzxc,rty"
        let records = parse(csv: csv)
        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records[0], ["qwe", "asd"])
        XCTAssertEqual(records[1], ["zxc", "rty"])
    }

    func testLineBreakCR() {
        let csv = "qwe,asd\rzxc,rty"
        let records = parse(csv: csv)
        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records[0], ["qwe", "asd"])
        XCTAssertEqual(records[1], ["zxc", "rty"])
    }

    func testLineBreakCRLF() {
        let csv = "qwe,asd\r\nzxc,rty"
        let records = parse(csv: csv)
        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records[0], ["qwe", "asd"])
        XCTAssertEqual(records[1], ["zxc", "rty"])
    }

    func testLineBreakLFLF() {
        let csv = "qwe,asd\n\nzxc,rty"
        let records = parse(csv: csv)
        XCTAssertEqual(records.count, 3)
        XCTAssertEqual(records[0], ["qwe", "asd"])
        XCTAssertEqual(records[1], [""])
        XCTAssertEqual(records[2], ["zxc", "rty"])
    }

    func testLineBreakCRCR() {
        let csv = "qwe,asd\r\rzxc,rty"
        let records = parse(csv: csv)
        XCTAssertEqual(records.count, 3)
        XCTAssertEqual(records[0], ["qwe", "asd"])
        XCTAssertEqual(records[1], [""])
        XCTAssertEqual(records[2], ["zxc", "rty"])
    }

    func testLineBreakCRLFCRLF() {
        let csv = "qwe,asd\r\n\r\nzxc,rty"
        let records = parse(csv: csv)
        XCTAssertEqual(records.count, 3)
        XCTAssertEqual(records[0], ["qwe", "asd"])
        XCTAssertEqual(records[1], [""])
        XCTAssertEqual(records[2], ["zxc", "rty"])
    }

    private func parse(csv: String) -> [[String]] {
        let reader = try! CSVReader(string: csv)
        return reader.map { $0 }
//        var records = [[String]]()
//        try! reader.enumerateRows { (row, _, _) in
//            records.append(row)
//        }
//        return records
    }

}
