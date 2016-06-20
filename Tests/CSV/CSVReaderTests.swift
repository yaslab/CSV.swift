//
//  CSVReaderTests.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/11.
//
//

import XCTest
@testable import CSV

class CSVReaderTests: XCTestCase {

    func test1Line() {
        let csv = "abab,cdcd,efef"
        let encoding = String.Encoding.utf8
        let records = parse(csv: csv, encoding: encoding)
        XCTAssertEqual(records[0], ["abab", "cdcd", "efef"])
    }

    func testQuoted() {
        let csv = "abab,\"cdcd\",efef"
        let encoding = String.Encoding.utf8
        let records = parse(csv: csv, encoding: encoding)
        XCTAssertEqual(records[0], ["abab", "cdcd", "efef"])
    }

    func testLF() {
        let csv = "abab,cdcd,efef\nzxcv,asdf,qwer"
        let encoding = String.Encoding.utf8
        let records = parse(csv: csv, encoding: encoding)
        XCTAssertEqual(records[0], ["abab", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qwer"])
    }

    func testCommaInQuotationMarks() {
        let csv = "abab,\"cd,cd\",efef"
        let encoding = String.Encoding.utf8
        let records = parse(csv: csv, encoding: encoding)
        XCTAssertEqual(records[0], ["abab", "cd,cd", "efef"])
    }

    func testCRLF() {
        let csv = "abab,cdcd,efef\r\nzxcv,asdf,qwer"
        let encoding = String.Encoding.utf8
        let records = parse(csv: csv, encoding: encoding)
        XCTAssertEqual(records[0], ["abab", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qwer"])
    }

    func testEscapedQuotationMark() {
        let csv = "abab,\"\"\"cdcd\",efef\r\nzxcv,asdf,qwer"
        let encoding = String.Encoding.utf8
        let records = parse(csv: csv, encoding: encoding)
        XCTAssertEqual(records[0], ["abab", "\"cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qwer"])
    }

    func testQuotationMark2() {
        let csv = "abab,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\""
        let encoding = String.Encoding.utf8
        let records = parse(csv: csv, encoding: encoding)
        XCTAssertEqual(records[0], ["abab", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er"])
    }

    func testEmptyField() {
        let csv = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\","
        let encoding = String.Encoding.utf8
        let records = parse(csv: csv, encoding: encoding)
        XCTAssertEqual(records[0], ["abab", "", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
    }

    func testLastCR() {
        let csv = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\",\r"
        let encoding = String.Encoding.utf8
        let records = parse(csv: csv, encoding: encoding)
        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records[0], ["abab", "", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
    }

    func testLastCRLF() {
        let csv = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\",\r\n"
        let encoding = String.Encoding.utf8
        let records = parse(csv: csv, encoding: encoding)
        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records[0], ["abab", "", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
    }

    func testLastLF() {
        let csv = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\",\n"
        let encoding = String.Encoding.utf8
        let records = parse(csv: csv, encoding: encoding)
        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records[0], ["abab", "", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
    }

    func testLFInQuotationMarks() {
        let csv = "abab,,\"\rcdcd\n\",efef\r\nzxcv,asdf,\"qw\"\"er\",\n"
        let encoding = String.Encoding.utf8
        let records = parse(csv: csv, encoding: encoding)
        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records[0], ["abab", "", "\rcdcd\n", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
    }

    func testLineBreakLF() {
        let csv = "qwe,asd\nzxc,rty"
        let encoding = String.Encoding.utf8
        let records = parse(csv: csv, encoding: encoding)
        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records[0], ["qwe", "asd"])
        XCTAssertEqual(records[1], ["zxc", "rty"])
    }
    
    func testLineBreakCR() {
        let csv = "qwe,asd\rzxc,rty"
        let encoding = String.Encoding.utf8
        let records = parse(csv: csv, encoding: encoding)
        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records[0], ["qwe", "asd"])
        XCTAssertEqual(records[1], ["zxc", "rty"])
    }
    
    func testLineBreakCRLF() {
        let csv = "qwe,asd\r\nzxc,rty"
        let encoding = String.Encoding.utf8
        let records = parse(csv: csv, encoding: encoding)
        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records[0], ["qwe", "asd"])
        XCTAssertEqual(records[1], ["zxc", "rty"])
    }
    
    func testLineBreakLFLF() {
        let csv = "qwe,asd\n\nzxc,rty"
        let encoding = String.Encoding.utf8
        let records = parse(csv: csv, encoding: encoding)
        XCTAssertEqual(records.count, 3)
        XCTAssertEqual(records[0], ["qwe", "asd"])
        XCTAssertEqual(records[1], [""])
        XCTAssertEqual(records[2], ["zxc", "rty"])
    }

    func testLineBreakCRCR() {
        let csv = "qwe,asd\r\rzxc,rty"
        let encoding = String.Encoding.utf8
        let records = parse(csv: csv, encoding: encoding)
        XCTAssertEqual(records.count, 3)
        XCTAssertEqual(records[0], ["qwe", "asd"])
        XCTAssertEqual(records[1], [""])
        XCTAssertEqual(records[2], ["zxc", "rty"])
    }

    func testLineBreakCRLFCRLF() {
        let csv = "qwe,asd\r\n\r\nzxc,rty"
        let encoding = String.Encoding.utf8
        let records = parse(csv: csv, encoding: encoding)
        XCTAssertEqual(records.count, 3)
        XCTAssertEqual(records[0], ["qwe", "asd"])
        XCTAssertEqual(records[1], [""])
        XCTAssertEqual(records[2], ["zxc", "rty"])
    }

    func testEncodingWithoutBOM() {
        var index = 0
        let csv = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\","
        for encoding in allEncodings() {
            print("index: \(index)")
            let records = parse(csv: csv, encoding: encoding)
            XCTAssertEqual(records[0], ["abab", "", "cdcd", "efef"])
            XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
            index += 1
        }
    }

    func testUTF8WithBOM() {
        let csv = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\","
        let encoding = String.Encoding.utf8
        var mutableData = Data()
        mutableData.append(utf8BOM, count: utf8BOM.count)
        mutableData.append(csv.data(using: encoding)!)
        let records = parse(data: mutableData, encoding: encoding)
        XCTAssertEqual(records[0], ["abab", "", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
    }

    func testUTF16WithNativeEndianBOM() {
        let csv = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\","
        let encoding = String.Encoding.utf16
        let records = parse(csv: csv, encoding: encoding)
        XCTAssertEqual(records[0], ["abab", "", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
    }

    func testUTF16WithBigEndianBOM() {
        let csv = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\","
        let encoding = String.Encoding.utf16
        var mutableData = Data()
        mutableData.append(utf16BigEndianBOM, count: utf16BigEndianBOM.count)
        mutableData.append(csv.data(using: String.Encoding.utf16BigEndian)!)
        let records = parse(data: mutableData, encoding: encoding)
        XCTAssertEqual(records[0], ["abab", "", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
    }

    func testUTF16WithLittleEndianBOM() {
        let csv = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\","
        let encoding = String.Encoding.utf16
        var mutableData = Data()
        mutableData.append(utf16LittleEndianBOM, count: utf16LittleEndianBOM.count)
        mutableData.append(csv.data(using: String.Encoding.utf16LittleEndian)!)
        let records = parse(data: mutableData, encoding: encoding)
        XCTAssertEqual(records[0], ["abab", "", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
    }

    func testUTF32WithNativeEndianBOM() {
        let csv = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\","
        let encoding = String.Encoding.utf32
        let records = parse(csv: csv, encoding: encoding)
        XCTAssertEqual(records[0], ["abab", "", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
    }

    func testUTF32WithBigEndianBOM() {
        let csv = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\","
        let encoding = String.Encoding.utf32
        var mutableData = Data()
        mutableData.append(utf32BigEndianBOM, count: utf32BigEndianBOM.count)
        mutableData.append(csv.data(using: String.Encoding.utf32BigEndian)!)
        let records = parse(data: mutableData, encoding: encoding)
        XCTAssertEqual(records[0], ["abab", "", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
    }

    func testUTF32WithLittleEndianBOM() {
        let csv = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\","
        let encoding = String.Encoding.utf32
        var mutableData = Data()
        mutableData.append(utf32LittleEndianBOM, count: utf32LittleEndianBOM.count)
        mutableData.append(csv.data(using: String.Encoding.utf32LittleEndian)!)
        let records = parse(data: mutableData, encoding: encoding)
        XCTAssertEqual(records[0], ["abab", "", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
    }

    func allEncodings() -> [String.Encoding] {
        return [
            // multi-byte character encodings
            String.Encoding.shiftJIS,
            String.Encoding.japaneseEUC,
            String.Encoding.utf8,
            // wide character encodings
            String.Encoding.utf16BigEndian,
            String.Encoding.utf16LittleEndian,
            String.Encoding.utf32BigEndian,
            String.Encoding.utf32LittleEndian,
        ]
    }

    func parse(csv: String, encoding: String.Encoding) -> [[String]] {
        let data = csv.data(using: encoding)!
        return parse(data: data, encoding: encoding)
    }

    func parse(data: Data, encoding: String.Encoding) -> [[String]] {
        let stream = InputStream(data: data)
        let reader = try! CSV(stream: stream, encoding: encoding)
        var records = [[String]]()
        for row in reader {
            records.append(row)
        }
        return records
    }

    static var allTests : [(String, (CSVReaderTests) -> () throws -> Void)] {
        return [
            //("testExample1", testExample1),
        ]
    }

}
