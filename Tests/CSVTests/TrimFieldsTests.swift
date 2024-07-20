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

    func testTrimFields1() throws {
        let csvString = "abc,def,ghi"
        let csv = CSVReader(string: csvString, configuration: .init(trim: true))
        for result in csv {
            XCTAssertEqual(try result.get().columns, ["abc", "def", "ghi"])
        }
    }

    func testTrimFields2() throws {
        let csvString = " abc,  def,   ghi"
        let csv = CSVReader(string: csvString, configuration: .init(trim: true))
        for result in csv {
            XCTAssertEqual(try result.get().columns, ["abc", "def", "ghi"])
        }
    }

    func testTrimFields3() throws {
        let csvString = "abc ,def  ,ghi   "
        let csv = CSVReader(string: csvString, configuration: .init(trim: true))
        for result in csv {
            XCTAssertEqual(try result.get().columns, ["abc", "def", "ghi"])
        }
    }

    func testTrimFields4() throws {
        let csvString = " abc ,  def  ,   ghi   "
        let csv = CSVReader(string: csvString, configuration: .init(trim: true))
        for result in csv {
            XCTAssertEqual(try result.get().columns, ["abc", "def", "ghi"])
        }
    }

    func testTrimFields5() throws {
        let csvString = "\"abc\",\"def\",\"ghi\""
        let csv = CSVReader(string: csvString, configuration: .init(trim: true))
        for result in csv {
            XCTAssertEqual(try result.get().columns, ["abc", "def", "ghi"])
        }
    }

    func testTrimFields6() throws {
        let csvString = " \"abc\",  \"def\",   \"ghi\""
        let csv = CSVReader(string: csvString, configuration: .init(trim: true))
        for result in csv {
            XCTAssertEqual(try result.get().columns, ["abc", "def", "ghi"])
        }
    }

    func testTrimFields7() throws {
        let csvString = "\"abc\" ,\"def\"  ,\"ghi\"   "
        let csv = CSVReader(string: csvString, configuration: .init(trim: true))
        for result in csv {
            XCTAssertEqual(try result.get().columns, ["abc", "def", "ghi"])
        }
    }

    func testTrimFields8() throws {
        let csvString = " \"abc\" ,  \"def\"  ,   \"ghi\"   "
        let csv = CSVReader(string: csvString, configuration: .init(trim: true))
        for result in csv {
            XCTAssertEqual(try result.get().columns, ["abc", "def", "ghi"])
        }
    }

    func testTrimFields9() {
        let csvString = "\" abc \",\" def \",\" ghi \""
        let csv = CSVReader(string: csvString, configuration: .init(trim: true))
        for result in csv {
            XCTAssertEqual(try result.get().columns, [" abc ", " def ", " ghi "])
        }
    }

    func testTrimFields10() throws {
        let csvString = "\tabc,\t\tdef\t,ghi\t"
        let csv = CSVReader(string: csvString, configuration: .init(trim: true))
        for result in csv {
            XCTAssertEqual(try result.get().columns, ["abc", "def", "ghi"])
        }
    }

    func testTrimFields11() throws {
        let csvString = " abc \n def "
        let csv = CSVReader(string: csvString, configuration: .init(trim: true))
        var it = csv.makeIterator()

        let result1 = it.next()!
        XCTAssertEqual(try result1.get().columns, ["abc"])
        let result2 = it.next()!
        XCTAssertEqual(try result2.get().columns, ["def"])
    }

    func testTrimFields12() throws {
        let csvString = " \"abc \" \n \" def\" "
        let csv = CSVReader(string: csvString, configuration: .init(trim: true))
        var it = csv.makeIterator()

        let result1 = it.next()!
        XCTAssertEqual(try result1.get().columns, ["abc "])
        let result2 = it.next()!
        XCTAssertEqual(try result2.get().columns, [" def"])
    }

    func testTrimFields13() throws {
        let csvString = " abc \t\tdef\t ghi "
        let csv = CSVReader(string: csvString, configuration: .init(trim: true, delimiter: 0x09))  // "\t"
        for result in csv {
            XCTAssertEqual(try result.get().columns, ["abc", "", "def", "ghi"])
        }
    }

    func testTrimFields14() throws {
        let csvString = ""
        let csv = CSVReader(string: csvString, configuration: .init(trim: true))
        let records = csv.compactMap { try? $0.get() }

        XCTAssertEqual(records.count, 0)
    }

    func testTrimFields15() throws {
        let csvString = " "
        let csv = CSVReader(string: csvString, configuration: .init(trim: true))
        let records = csv.compactMap { try? $0.get() }

        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records[0].columns, [""])
    }

    func testTrimFields16() throws {
        let csvString = " , "
        let csv = CSVReader(string: csvString, configuration: .init(trim: true))
        let records = csv.compactMap { try? $0.get() }

        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records[0].columns, ["", ""])
    }

    func testTrimFields17() throws {
        let csvString = " , \n"
        let csv = CSVReader(string: csvString, configuration: .init(trim: true))
        let records = csv.compactMap { try? $0.get() }

        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records[0].columns, ["", ""])
    }

    func testTrimFields18() throws {
        let csvString = " , \n "
        let csv = CSVReader(string: csvString, configuration: .init(trim: true))
        let records = csv.compactMap { try? $0.get() }

        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records[0].columns, ["", ""])
        XCTAssertEqual(records[1].columns, [""])
    }

}
