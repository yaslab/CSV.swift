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
        let encoding = NSUTF8StringEncoding
        let records = parseCSV(csv, encoding: encoding)
        XCTAssertEqual(records[0], ["abab", "cdcd", "efef"])
    }

    func testQuoted() {
        let csv = "abab,\"cdcd\",efef"
        let encoding = NSUTF8StringEncoding
        let records = parseCSV(csv, encoding: encoding)
        XCTAssertEqual(records[0], ["abab", "cdcd", "efef"])
    }

    func testLF() {
        let csv = "abab,cdcd,efef\nzxcv,asdf,qwer"
        let encoding = NSUTF8StringEncoding
        let records = parseCSV(csv, encoding: encoding)
        XCTAssertEqual(records[0], ["abab", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qwer"])
    }

    func testCommaInQuotationMarks() {
        let csv = "abab,\"cd,cd\",efef"
        let encoding = NSUTF8StringEncoding
        let records = parseCSV(csv, encoding: encoding)
        XCTAssertEqual(records[0], ["abab", "cd,cd", "efef"])
    }

    func testCRLF() {
        let csv = "abab,cdcd,efef\r\nzxcv,asdf,qwer"
        let encoding = NSUTF8StringEncoding
        let records = parseCSV(csv, encoding: encoding)
        XCTAssertEqual(records[0], ["abab", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qwer"])
    }

    func testEscapedQuotationMark() {
        let csv = "abab,\"\"\"cdcd\",efef\r\nzxcv,asdf,qwer"
        let encoding = NSUTF8StringEncoding
        let records = parseCSV(csv, encoding: encoding)
        XCTAssertEqual(records[0], ["abab", "\"cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qwer"])
    }

    func testQuotationMark2() {
        let csv = "abab,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\""
        let encoding = NSUTF8StringEncoding
        let records = parseCSV(csv, encoding: encoding)
        XCTAssertEqual(records[0], ["abab", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er"])
    }

    func testEmptyField() {
        let csv = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\","
        let encoding = NSUTF8StringEncoding
        let records = parseCSV(csv, encoding: encoding)
        XCTAssertEqual(records[0], ["abab", "", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
    }

    func testLastCR() {
        let csv = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\",\r"
        let encoding = NSUTF8StringEncoding
        let records = parseCSV(csv, encoding: encoding)
        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records[0], ["abab", "", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
    }

    func testLastCRLF() {
        let csv = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\",\r\n"
        let encoding = NSUTF8StringEncoding
        let records = parseCSV(csv, encoding: encoding)
        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records[0], ["abab", "", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
    }

    func testLastLF() {
        let csv = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\",\n"
        let encoding = NSUTF8StringEncoding
        let records = parseCSV(csv, encoding: encoding)
        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records[0], ["abab", "", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
    }

    func testLFInQuotationMarks() {
        let csv = "abab,,\"\rcdcd\n\",efef\r\nzxcv,asdf,\"qw\"\"er\",\n"
        let encoding = NSUTF8StringEncoding
        let records = parseCSV(csv, encoding: encoding)
        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records[0], ["abab", "", "\rcdcd\n", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
    }

    func testLineBreakLF() {
        let csv = "qwe,asd\nzxc,rty"
        let encoding = NSUTF8StringEncoding
        let records = parseCSV(csv, encoding: encoding)
        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records[0], ["qwe", "asd"])
        XCTAssertEqual(records[1], ["zxc", "rty"])
    }
    
    func testLineBreakCR() {
        let csv = "qwe,asd\rzxc,rty"
        let encoding = NSUTF8StringEncoding
        let records = parseCSV(csv, encoding: encoding)
        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records[0], ["qwe", "asd"])
        XCTAssertEqual(records[1], ["zxc", "rty"])
    }
    
    func testLineBreakCRLF() {
        let csv = "qwe,asd\r\nzxc,rty"
        let encoding = NSUTF8StringEncoding
        let records = parseCSV(csv, encoding: encoding)
        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records[0], ["qwe", "asd"])
        XCTAssertEqual(records[1], ["zxc", "rty"])
    }
    
    func testLineBreakLFLF() {
        let csv = "qwe,asd\n\nzxc,rty"
        let encoding = NSUTF8StringEncoding
        let records = parseCSV(csv, encoding: encoding)
        XCTAssertEqual(records.count, 3)
        XCTAssertEqual(records[0], ["qwe", "asd"])
        XCTAssertEqual(records[1], [""])
        XCTAssertEqual(records[2], ["zxc", "rty"])
    }

    func testLineBreakCRCR() {
        let csv = "qwe,asd\r\rzxc,rty"
        let encoding = NSUTF8StringEncoding
        let records = parseCSV(csv, encoding: encoding)
        XCTAssertEqual(records.count, 3)
        XCTAssertEqual(records[0], ["qwe", "asd"])
        XCTAssertEqual(records[1], [""])
        XCTAssertEqual(records[2], ["zxc", "rty"])
    }

    func testLineBreakCRLFCRLF() {
        let csv = "qwe,asd\r\n\r\nzxc,rty"
        let encoding = NSUTF8StringEncoding
        let records = parseCSV(csv, encoding: encoding)
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
            let records = parseCSV(csv, encoding: encoding)
            XCTAssertEqual(records[0], ["abab", "", "cdcd", "efef"])
            XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
            index += 1
        }
    }

    func testUTF8WithBOM() {
        let csv = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\","
        let encoding = NSUTF8StringEncoding
        let mutableData = NSMutableData()
        mutableData.appendBytes(utf8BOM, length: utf8BOM.count)
        mutableData.appendData(csv.dataUsingEncoding(encoding)!)
        let records = parseData(mutableData, encoding: encoding)
        XCTAssertEqual(records[0], ["abab", "", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
    }

    func testUTF16WithNativeEndianBOM() {
        let csv = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\","
        let encoding = NSUTF16StringEncoding
        let records = parseCSV(csv, encoding: encoding)
        XCTAssertEqual(records[0], ["abab", "", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
    }

    func testUTF16WithBigEndianBOM() {
        let csv = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\","
        let encoding = NSUTF16StringEncoding
        let mutableData = NSMutableData()
        mutableData.appendBytes(utf16BigEndianBOM, length: utf16BigEndianBOM.count)
        mutableData.appendData(csv.dataUsingEncoding(NSUTF16BigEndianStringEncoding)!)
        let records = parseData(mutableData, encoding: encoding)
        XCTAssertEqual(records[0], ["abab", "", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
    }

    func testUTF16WithLittleEndianBOM() {
        let csv = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\","
        let encoding = NSUTF16StringEncoding
        let mutableData = NSMutableData()
        mutableData.appendBytes(utf16LittleEndianBOM, length: utf16LittleEndianBOM.count)
        mutableData.appendData(csv.dataUsingEncoding(NSUTF16LittleEndianStringEncoding)!)
        let records = parseData(mutableData, encoding: encoding)
        XCTAssertEqual(records[0], ["abab", "", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
    }

    func testUTF32WithNativeEndianBOM() {
        let csv = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\","
        let encoding = NSUTF32StringEncoding
        let records = parseCSV(csv, encoding: encoding)
        XCTAssertEqual(records[0], ["abab", "", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
    }

    func testUTF32WithBigEndianBOM() {
        let csv = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\","
        let encoding = NSUTF32StringEncoding
        let mutableData = NSMutableData()
        mutableData.appendBytes(utf32BigEndianBOM, length: utf32BigEndianBOM.count)
        mutableData.appendData(csv.dataUsingEncoding(NSUTF32BigEndianStringEncoding)!)
        let records = parseData(mutableData, encoding: encoding)
        XCTAssertEqual(records[0], ["abab", "", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
    }

    func testUTF32WithLittleEndianBOM() {
        let csv = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\","
        let encoding = NSUTF32StringEncoding
        let mutableData = NSMutableData()
        mutableData.appendBytes(utf32LittleEndianBOM, length: utf32LittleEndianBOM.count)
        mutableData.appendData(csv.dataUsingEncoding(NSUTF32LittleEndianStringEncoding)!)
        let records = parseData(mutableData, encoding: encoding)
        XCTAssertEqual(records[0], ["abab", "", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
    }

    func allEncodings() -> [NSStringEncoding] {
        return [
            // multi-byte character encodings
            NSShiftJISStringEncoding,
            NSJapaneseEUCStringEncoding,
            NSUTF8StringEncoding,
            // wide character encodings
            NSUTF16BigEndianStringEncoding,
            NSUTF16LittleEndianStringEncoding,
            NSUTF32BigEndianStringEncoding,
            NSUTF32LittleEndianStringEncoding,
        ]
    }

    func parseCSV(csv: String, encoding: NSStringEncoding) -> [[String]] {
        let data = csv.dataUsingEncoding(encoding)!
        return parseData(data, encoding: encoding)
    }

    func parseData(data: NSData, encoding: NSStringEncoding) -> [[String]] {
        let stream = NSInputStream(data: data)
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
