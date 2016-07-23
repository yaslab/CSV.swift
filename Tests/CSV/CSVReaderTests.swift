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
        let records = parse(csv: csv)
        XCTAssertEqual(records[0], ["abab", "cdcd", "efef"])
    }

    func testQuoted() {
        let csv = "abab,\"cdcd\",efef"
        let records = parse(csv: csv)
        XCTAssertEqual(records[0], ["abab", "cdcd", "efef"])
    }

    func testLF() {
        let csv = "abab,cdcd,efef\nzxcv,asdf,qwer"
        let records = parse(csv: csv)
        XCTAssertEqual(records[0], ["abab", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qwer"])
    }

    func testCommaInQuotationMarks() {
        let csv = "abab,\"cd,cd\",efef"
        let records = parse(csv: csv)
        XCTAssertEqual(records[0], ["abab", "cd,cd", "efef"])
    }

    func testCRLF() {
        let csv = "abab,cdcd,efef\r\nzxcv,asdf,qwer"
        let records = parse(csv: csv)
        XCTAssertEqual(records[0], ["abab", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qwer"])
    }

    func testEscapedQuotationMark1() {
        let csv = "abab,\"\"\"cdcd\",efef\r\nzxcv,asdf,qwer"
        let records = parse(csv: csv)
        XCTAssertEqual(records[0], ["abab", "\"cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qwer"])
    }

    func testEscapedQuotationMark2() {
        let csv = "abab,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\""
        let records = parse(csv: csv)
        XCTAssertEqual(records[0], ["abab", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er"])
    }

    func testEmptyField() {
        let csv = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\","
        let records = parse(csv: csv)
        XCTAssertEqual(records[0], ["abab", "", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
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

//    func testEncodingWithoutBOM() {
//        var index = 0
//        let csv = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\","
//        for encoding in allEncodings() {
//            print("index: \(index)")
//            let records = parse(csv: csv, encoding: encoding)
//            XCTAssertEqual(records[0], ["abab", "", "cdcd", "efef"])
//            XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
//            index += 1
//        }
//    }

    func testUTF8WithBOM() {
        let csvString = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\","
        let encoding = NSUTF8StringEncoding
        var mutableData = NSMutableData()
        mutableData.appendBytes(utf8BOM, length: utf8BOM.count)
        mutableData.appendData(csvString.dataUsingEncoding(encoding)!)
        let stream = NSInputStream(data: mutableData)
        let csv = try! CSV(stream: stream, codecType: UTF8.self)
        let records = getRecords(csv: csv)
        XCTAssertEqual(records[0], ["abab", "", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
    }

    func testUTF16WithNativeEndianBOM() {
        let csvString = "abab,,cdcd,efef\r\nzxcv,😆asdf,\"qw\"\"er\","
        let encoding = NSUTF16StringEncoding
        var mutableData = NSMutableData()
        mutableData.appendData(csvString.dataUsingEncoding(encoding)!)
        let stream = NSInputStream(data: mutableData)
        let csv = try! CSV(stream: stream, codecType: UTF16.self, endian: .Unknown)
        let records = getRecords(csv: csv)
        XCTAssertEqual(records[0], ["abab", "", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "😆asdf", "qw\"er", ""])
    }

    func testUTF16WithBigEndianBOM() {
        let csvString = "abab,,cdcd,efef\r\n😆zxcv,asdf,\"qw\"\"er\","
        let encoding = NSUTF16BigEndianStringEncoding
        var mutableData = NSMutableData()
        mutableData.appendBytes(utf16BigEndianBOM, length: utf16BigEndianBOM.count)
        mutableData.appendData(csvString.dataUsingEncoding(encoding)!)
        let stream = NSInputStream(data: mutableData)
        let csv = try! CSV(stream: stream, codecType: UTF16.self, endian: .Big)
        let records = getRecords(csv: csv)
        XCTAssertEqual(records[0], ["abab", "", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["😆zxcv", "asdf", "qw\"er", ""])
    }

    func testUTF16WithLittleEndianBOM() {
        let csvString = "abab,,cdcd,efef\r\nzxcv😆,asdf,\"qw\"\"er\","
        let encoding = NSUTF16LittleEndianStringEncoding
        var mutableData = NSMutableData()
        mutableData.appendBytes(utf16LittleEndianBOM, length: utf16LittleEndianBOM.count)
        mutableData.appendData(csvString.dataUsingEncoding(encoding)!)
        let stream = NSInputStream(data: mutableData)
        let csv = try! CSV(stream: stream, codecType: UTF16.self, endian: .Little)
        let records = getRecords(csv: csv)
        XCTAssertEqual(records[0], ["abab", "", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv😆", "asdf", "qw\"er", ""])
    }

    func testUTF32WithNativeEndianBOM() {
        let csvString = "😆abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\","
        let encoding = NSUTF32StringEncoding
        var mutableData = NSMutableData()
        mutableData.appendData(csvString.dataUsingEncoding(encoding)!)
        let stream = NSInputStream(data: mutableData)
        let csv = try! CSV(stream: stream, codecType: UTF32.self, endian: .Unknown)
        let records = getRecords(csv: csv)
        XCTAssertEqual(records[0], ["😆abab", "", "cdcd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
    }

    func testUTF32WithBigEndianBOM() {
        let csvString = "abab,,cd😆cd,efef\r\nzxcv,asdf,\"qw\"\"er\","
        let encoding = NSUTF32BigEndianStringEncoding
        var mutableData = NSMutableData()
        mutableData.appendBytes(utf32BigEndianBOM, length: utf32BigEndianBOM.count)
        mutableData.appendData(csvString.dataUsingEncoding(encoding)!)
        let stream = NSInputStream(data: mutableData)
        let csv = try! CSV(stream: stream, codecType: UTF32.self, endian: .Big)
        let records = getRecords(csv: csv)
        XCTAssertEqual(records[0], ["abab", "", "cd😆cd", "efef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
    }

    func testUTF32WithLittleEndianBOM() {
        let csvString = "abab,,cdcd,ef😆ef\r\nzxcv,asdf,\"qw\"\"er\","
        let encoding = NSUTF32LittleEndianStringEncoding
        var mutableData = NSMutableData()
        mutableData.appendBytes(utf32LittleEndianBOM, length: utf32LittleEndianBOM.count)
        mutableData.appendData(csvString.dataUsingEncoding(encoding)!)
        let stream = NSInputStream(data: mutableData)
        let csv = try! CSV(stream: stream, codecType: UTF32.self, endian: .Little)
        let records = getRecords(csv: csv)
        XCTAssertEqual(records[0], ["abab", "", "cdcd", "ef😆ef"])
        XCTAssertEqual(records[1], ["zxcv", "asdf", "qw\"er", ""])
    }

//    func allEncodings() -> [String.Encoding] {
//        return [
//            // multi-byte character encodings
//            //String.Encoding.shiftJIS,
//            //String.Encoding.japaneseEUC,
//            String.Encoding.utf8,
//            // wide character encodings
//            String.Encoding.utf16BigEndian,
//            String.Encoding.utf16LittleEndian,
//            String.Encoding.utf32BigEndian,
//            String.Encoding.utf32LittleEndian,
//        ]
//    }
    
    func parse(csv csv: String) -> [[String]] {
        let reader = try! CSV(string: csv)
        var records = [[String]]()
        for row in reader {
            records.append(row)
        }
        return records
    }
    
    func getRecords(csv csv: CSV) -> [[String]] {
        var records = [[String]]()
        for row in csv {
            records.append(row)
        }
        return records
    }

//    func parse(csv: String, encoding: String.Encoding) -> [[String]] {
//        let data = csv.data(using: encoding)!
//        return parse(data: data, encoding: encoding)
//    }
//
//    func parse(data: Data, encoding: String.Encoding) -> [[String]] {
//        let stream = InputStream(data: data)
//        let reader = try! CSV(stream: stream, encoding: encoding)
//        var records = [[String]]()
//        for row in reader {
//            records.append(row)
//        }
//        return records
//    }

    static var allTests : [(String, (CSVReaderTests) -> () throws -> Void)] {
        return [
            //("testExample1", testExample1),
        ]
    }

}
