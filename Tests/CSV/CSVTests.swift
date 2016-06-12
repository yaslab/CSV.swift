//
//  CSVTests.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/11.
//
//

import XCTest
@testable import CSV

class CSVTests: XCTestCase {

    func testSample1() {
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
    
    func testSample2() {
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

    func testSample3() {
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

    func testSample4() {
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
    
    func testSample5() {
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
    
    func testBufferSizeMod0() {
        let csvString = "0,1,2,3,4,5,6,7,8,9\n"
        let csv = try! CSV(string: csvString, bufferSize: 12)
        XCTAssertEqual(csv.bufferSize, 12)
    }
    
    func testBufferSizeMod1() {
        let csvString = "0,1,2,3,4,5,6,7,8,9\n"
        let csv = try! CSV(string: csvString, bufferSize: 13)
        XCTAssertEqual(csv.bufferSize, 16)
    }
    
    func testBufferSizeMod2() {
        let csvString = "0,1,2,3,4,5,6,7,8,9\n"
        let csv = try! CSV(string: csvString, bufferSize: 14)
        XCTAssertEqual(csv.bufferSize, 16)
    }
    
    func testBufferSizeMod3() {
        let csvString = "0,1,2,3,4,5,6,7,8,9\n"
        let csv = try! CSV(string: csvString, bufferSize: 15)
        XCTAssertEqual(csv.bufferSize, 16)
    }
    
    func testBufferSizeMod4() {
        let csvString = "0,1,2,3,4,5,6,7,8,9\n"
        let csv = try! CSV(string: csvString, bufferSize: 16)
        XCTAssertEqual(csv.bufferSize, 16)
    }
    
    func testSmallBufferSize() {
        let line = "0,1,2,3,4,5,6,7,8,9\n"
        var csv = ""
        for _ in 0..<10000 {
            csv += line
        }
        var i = 0
        for row in try! CSV(string: csv, bufferSize: 10) {
            XCTAssertEqual(row, ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"])
            i += 1
        }
        XCTAssertEqual(i, 10000)
    }
    
}
