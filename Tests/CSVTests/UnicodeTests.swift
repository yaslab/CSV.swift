//
//  UnicodeTests.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/10/18.
//  Copyright © 2016 yaslab. All rights reserved.
//

import Foundation
import XCTest

@testable import CSV

class UnicodeTests: XCTestCase {

    func testUTF8WithBOM() throws {
        let csvString = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\","
        let encoding = String.Encoding.utf8
        var mutableData = Data()
        mutableData.append(contentsOf: [0xef, 0xbb, 0xbf])  // UTF-8 BOM
        mutableData.append(csvString.data(using: encoding)!)
        try withTempURL { url in
            try mutableData.write(to: url)

            let csv = CSVReader(url: url)
            let records = csv.map { try! $0.get() }
            XCTAssertEqual(records[0].columns, ["abab", "", "cdcd", "efef"])
            XCTAssertEqual(records[1].columns, ["zxcv", "asdf", "qw\"er", ""])
        }
    }

    // func testUTF16WithNativeEndianBOM() {
    //     let csvString = "abab,,cdcd,efef\r\nzxcv,😆asdf,\"qw\"\"er\","
    //     let encoding = String.Encoding.utf16
    //     var mutableData = Data()
    //     mutableData.append(csvString.data(using: encoding)!)
    //     let stream = InputStream(data: mutableData as Data)
    //     let csv = try! CSVReader(stream: stream, codecType: UTF16.self, endian: .unknown)
    //     let records = getRecords(csv: csv)
    //     XCTAssertEqual(records[0], ["abab", "", "cdcd", "efef"])
    //     XCTAssertEqual(records[1], ["zxcv", "😆asdf", "qw\"er", ""])
    // }

    // func testUTF16WithBigEndianBOM() {
    //     let csvString = "abab,,cdcd,efef\r\n😆zxcv,asdf,\"qw\"\"er\","
    //     let encoding = String.Encoding.utf16BigEndian
    //     var mutableData = Data()
    //     mutableData.append(contentsOf: UnicodeBOM.utf16BE)
    //     mutableData.append(csvString.data(using: encoding)!)
    //     let stream = InputStream(data: mutableData as Data)
    //     let csv = try! CSVReader(stream: stream, codecType: UTF16.self, endian: .big)
    //     let records = getRecords(csv: csv)
    //     XCTAssertEqual(records[0], ["abab", "", "cdcd", "efef"])
    //     XCTAssertEqual(records[1], ["😆zxcv", "asdf", "qw\"er", ""])
    // }

    // func testUTF16WithLittleEndianBOM() {
    //     let csvString = "abab,,cdcd,efef\r\nzxcv😆,asdf,\"qw\"\"er\","
    //     let encoding = String.Encoding.utf16LittleEndian
    //     var mutableData = Data()
    //     mutableData.append(contentsOf: UnicodeBOM.utf16LE)
    //     mutableData.append(csvString.data(using: encoding)!)
    //     let stream = InputStream(data: mutableData as Data)
    //     let csv = try! CSVReader(stream: stream, codecType: UTF16.self, endian: .little)
    //     let records = getRecords(csv: csv)
    //     XCTAssertEqual(records[0], ["abab", "", "cdcd", "efef"])
    //     XCTAssertEqual(records[1], ["zxcv😆", "asdf", "qw\"er", ""])
    // }

    // func testUTF32WithNativeEndianBOM() {
    //     let csvString = "😆abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\","
    //     let encoding = String.Encoding.utf32
    //     var mutableData = Data()
    //     mutableData.append(csvString.data(using: encoding)!)
    //     let stream = InputStream(data: mutableData as Data)
    //     let csv = try! CSVReader(stream: stream, codecType: UTF32.self, endian: .unknown)
    //     let records = getRecords(csv: csv)
    //     XCTAssertEqual(records[0], ["😆abab", "", "cdcd", "efef"])
    //     XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
    // }

    // func testUTF32WithBigEndianBOM() {
    //     let csvString = "abab,,cd😆cd,efef\r\nzxcv,asdf,\"qw\"\"er\","
    //     let encoding = String.Encoding.utf32BigEndian
    //     var mutableData = Data()
    //     mutableData.append(contentsOf: UnicodeBOM.utf32BE)
    //     mutableData.append(csvString.data(using: encoding)!)
    //     let stream = InputStream(data: mutableData as Data)
    //     let csv = try! CSVReader(stream: stream, codecType: UTF32.self, endian: .big)
    //     let records = getRecords(csv: csv)
    //     XCTAssertEqual(records[0], ["abab", "", "cd😆cd", "efef"])
    //     XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
    // }

    // func testUTF32WithLittleEndianBOM() {
    //     let csvString = "abab,,cdcd,ef😆ef\r\nzxcv,asdf,\"qw\"\"er\","
    //     let encoding = String.Encoding.utf32LittleEndian
    //     var mutableData = Data()
    //     mutableData.append(contentsOf: UnicodeBOM.utf32LE)
    //     mutableData.append(csvString.data(using: encoding)!)
    //     let stream = InputStream(data: mutableData as Data)
    //     let csv = try! CSVReader(stream: stream, codecType: UTF32.self, endian: .little)
    //     let records = getRecords(csv: csv)
    //     XCTAssertEqual(records[0], ["abab", "", "cdcd", "ef😆ef"])
    //     XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
    // }

    // private func getRecords(csv: CSVReader) -> [[String]] {
    // return csv.map { $0 }
    //        var records = [[String]]()
    //        try! csv.enumerateRows { (record, _, _) in
    //            records.append(record)
    //        }
    //        return records
    // }

}
