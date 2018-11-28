//
//  CSVRowDecoderTests.swift
//  CSV
//
//  Created by Ian Grossberg on 9/11/18.
//  Copyright © 2018 yaslab. All rights reserved.
//

import XCTest
import CSV

//===----------------------------------------------------------------------===//
// Models
//===----------------------------------------------------------------------===//

fileprivate enum Enum: String, Decodable {
    case first
    case second
}

fileprivate protocol DecodableTest: Equatable {
    var intKey: Int { get }
    var stringKey: String { get }
    var optionalStringKey: String? { get }
    var dateKey: Date { get }
    var enumKey: Enum { get }

    static func headerRow() -> String
    func toRow() -> String
}

extension DecodableTest {
    fileprivate static func headerRow() -> String {
        return "stringKey,optionalStringKey,intKey,ignored,dateKey,enumKey\n"
    }
    fileprivate func toRow() -> String {
        var row = ""
        row += "\(self.stringKey),"
        row += "\(self.optionalStringKey ?? ""),"
        row += "\(self.intKey),"
        row += ","
        row += "\"\(self.dateKey.timeIntervalSinceReferenceDate)\","
        row += "\(self.enumKey.rawValue)"
        row += "\n"
        return row
    }
}

extension Equatable where Self: DecodableTest {
    fileprivate static func ==(left: Self, right: Self) -> Bool {
        return left.intKey == right.intKey
            && left.stringKey == right.stringKey
            && left.optionalStringKey == right.optionalStringKey
            && Int(left.dateKey.timeIntervalSince1970) == Int(right.dateKey.timeIntervalSince1970)
            && left.enumKey == right.enumKey
    }
}

//===----------------------------------------------------------------------===//
// CSVRowDecoderTests
//===----------------------------------------------------------------------===//

class CSVRowDecoderTests: XCTestCase {

    static let allTests = [
        ("testNoHeader", testNoHeader),
        ("testStringCodingKey", testStringCodingKey),
        ("testTypeInvalidDateFormat", testTypeInvalidDateFormat),
        ("testIntCodingKey", testIntCodingKey),
        ("testIntCodingKeyWhileIgnoringHeaders", testIntCodingKeyWhileIgnoringHeaders),
        ("testTypeMismatch", testTypeMismatch),
        ("testUnsupportedDecodableField", testUnsupportedDecodableField),
        ("testDecodeBoolean", testDecodeBoolean),
        ("testDecodeInteger", testDecodeInteger),
        ("testDecodeUnsignedInteger", testDecodeUnsignedInteger),
    ]

    //===----------------------------------------------------------------------===//

    fileprivate struct SupportedDecodableExample: Decodable, DecodableTest {
        let intKey: Int
        let stringKey: String
        let optionalStringKey: String?
        let dateKey: Date
        let enumKey: Enum

        static var examples: [SupportedDecodableExample] {
            return [
                SupportedDecodableExample(intKey: 12345, stringKey: "stringValue", optionalStringKey: nil, dateKey: Date(), enumKey: .first),
                SupportedDecodableExample(intKey: 54321, stringKey: "stringValue2", optionalStringKey: "withValue", dateKey: Date(timeInterval: 100, since: Date()), enumKey: .second)
            ]
        }
    }

    func testNoHeader() {
        let noHeaderStr = "あ,い1,\"う\",えお\n,,x,"
        let noHeaderCSV = try! CSVReader(string: noHeaderStr, hasHeaderRow: false)

        do {
            let decoder = CSVRowDecoder()
            let _ = try decoder.decode(SupportedDecodableExample.self, from: noHeaderCSV)
            XCTFail("Expect DecodingError.typeMismatch Error thrown")
        } catch {
            // Success
        }
    }

    func testStringCodingKey() {
        let exampleRecords = SupportedDecodableExample.examples

        let header = SupportedDecodableExample.headerRow()
        let allRows = exampleRecords.reduce(into: header) { $0 += $1.toRow() }

        let headerCSV = try! CSVReader(string: allRows, hasHeaderRow: true)

        var records = [SupportedDecodableExample]()
        do {
            let decoder = CSVRowDecoder()
            while headerCSV.next() != nil {
                try records.append(decoder.decode(SupportedDecodableExample.self, from: headerCSV))
            }
        } catch {
            XCTFail("decode<T>() threw error: \(error)")
            return
        }
        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records[0], exampleRecords[0])
        XCTAssertEqual(records[1], exampleRecords[1])
    }

    func testTypeInvalidDateFormat() {
        let invalidFieldTypeStr = """
            dateKey,stringKey,optionalStringKey,intKey,ignored
            al;ksdjf;akjsdf,asldkj,,1234,
            """
        let invalidFieldTypeCSV = try! CSVReader(string: invalidFieldTypeStr, hasHeaderRow: true)

        do {
            let decoder = CSVRowDecoder()
            while invalidFieldTypeCSV.next() != nil {
                _ = try decoder.decode(SupportedDecodableExample.self, from: invalidFieldTypeCSV)
            }
            XCTFail("Expect DecodingError.dataCorrupted Error thrown")
        } catch {
            guard let error = error as? DecodingError else {
                XCTFail("Expect DecodingError Error thrown")
                return
            }
            switch error {
            case let DecodingError.typeMismatch(type, context):
                XCTAssert(type == Double.self)
                XCTAssertEqual(context.codingPath[0].stringValue, "dateKey", "Type Mismatch Error on unexpected field")
            default:
                XCTFail("Expect DecodingError.dataCorrupted Error thrown, got \(error)")
            }
        }
    }

    //===----------------------------------------------------------------------===//

    fileprivate struct IntKeyedDecodableExample: Decodable, DecodableTest {
        private enum CodingKeys: Int, CodingKey {
            case stringKey = 0
            case optionalStringKey = 1
            case intKey = 2
            case dateKey = 4
            case enumKey = 5
        }

        let intKey: Int
        let stringKey: String
        let optionalStringKey: String?
        let dateKey: Date
        let enumKey: Enum

        static var examples: [IntKeyedDecodableExample] {
            return [
                IntKeyedDecodableExample(intKey: 12345, stringKey: "stringValue", optionalStringKey: nil, dateKey: Date(), enumKey: .first),
                IntKeyedDecodableExample(intKey: 54321, stringKey: "stringValue2", optionalStringKey: "withValue", dateKey: Date(timeInterval: 100, since: Date()), enumKey: .second)
            ]
        }
    }

    func testIntCodingKey() {
        let exampleRecords = IntKeyedDecodableExample.examples

        let allRows = IntKeyedDecodableExample.examples.reduce(into: "") { $0 += $1.toRow() }

        let headerCSV = try! CSVReader(string: allRows, hasHeaderRow: false)

        var records = [IntKeyedDecodableExample]()
        do {
            let decoder = CSVRowDecoder()
            while headerCSV.next() != nil {
                try records.append(decoder.decode(IntKeyedDecodableExample.self, from: headerCSV))
            }
        } catch {
            XCTFail("decode<T>() threw error: \(error)")
            return
        }
        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records[0], exampleRecords[0])
        XCTAssertEqual(records[1], exampleRecords[1])
    }

    func testIntCodingKeyWhileIgnoringHeaders() {
        let exampleRecords = IntKeyedDecodableExample.examples

        let header = IntKeyedDecodableExample.headerRow()
        let allRows = exampleRecords.reduce(into: header) { $0 += $1.toRow() }

        let headerCSV = try! CSVReader(string: allRows, hasHeaderRow: true)

        var records = [IntKeyedDecodableExample]()
        do {
            let decoder = CSVRowDecoder()
            while headerCSV.next() != nil {
                try records.append(decoder.decode(IntKeyedDecodableExample.self, from: headerCSV))
            }
        } catch {
            XCTFail("decode<T>() threw error: \(error)")
            return
        }
        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records[0], exampleRecords[0])
        XCTAssertEqual(records[1], exampleRecords[1])
    }

    func testTypeMismatch() {
        let exampleRecords = SupportedDecodableExample.examples

        let invalidFieldTypeStr = """
            stringKey,optionalStringKey,intKey,ignored
            \(exampleRecords[0].stringKey),,this is a string where we expect an Int,
            \(exampleRecords[1].stringKey),\(exampleRecords[1].optionalStringKey!),\(exampleRecords[1].intKey),
            """
        let invalidFieldTypeCSV = try! CSVReader(string: invalidFieldTypeStr, hasHeaderRow: true)

        do {
            let decoder = CSVRowDecoder()
            while invalidFieldTypeCSV.next() != nil {
                _ = try decoder.decode(IntKeyedDecodableExample.self, from: invalidFieldTypeCSV)
            }
            XCTFail("Expect DecodingError.typeMismatch Error thrown")
        } catch {
            guard let error = error as? DecodingError else {
                XCTFail("Expect DecodingError Error thrown")
                return
            }
            switch error {
            case let .typeMismatch(_, context):
                XCTAssertEqual(context.codingPath[0].stringValue, "intKey", "Type Mismatch Error on unexpected field")
            default:
                XCTFail("Expect Type Mismatch Error thrown")
            }
        }
    }

    //===----------------------------------------------------------------------===//

    fileprivate struct UnsupportedDecodableExample: Decodable, Equatable {
        let enumKey: Enum

        static var examples: [UnsupportedDecodableExample] {
            return [
                UnsupportedDecodableExample(enumKey: .first),
                UnsupportedDecodableExample(enumKey: .second)
            ]
        }
    }

    func testUnsupportedDecodableField() {
        let exampleRecords = UnsupportedDecodableExample.examples

        let headerStr = """
            enumKey,optionalStringKey,intKey,ignored,dateKey
            \(exampleRecords[0].enumKey),"hiiiii",123445,,
            \(exampleRecords[1].enumKey),,54231,,
            \("third"),,54231,,
            """
        let headerCSV = try! CSVReader(string: headerStr, hasHeaderRow: true)

        var records = [UnsupportedDecodableExample]()
        do {
            let decoder = CSVRowDecoder()
            while headerCSV.next() != nil {
                try records.append(decoder.decode(UnsupportedDecodableExample.self, from: headerCSV))
            }
            XCTFail("Expect Data Corrupted Error thrown")
        } catch {
            XCTAssertEqual(records.count, 2)
            guard let decodingError = error as? DecodingError else {
                XCTFail("Expect DecodingError Error thrown, instead we go \(error)")
                return
            }
            switch decodingError {
            case let .dataCorrupted(context):
                guard context.codingPath[0].stringValue == "enumKey" else {
                    XCTFail("Data Corrupted Error on unexpected field")
                    return
                }
            default:
                XCTFail("Expect Data Corrupted Error thrown, instead we got \(decodingError)")
            }
        }
    }

    //===----------------------------------------------------------------------===//

    fileprivate struct BooleanDecodableExample: Decodable {
        let falseValue: Bool
        let trueValue: Bool
    }

    func testDecodeBoolean() {
        let csv = """
            falseValue,trueValue
            false,true
            """
        do {
            let reader = try CSVReader(string: csv, hasHeaderRow: true)
            reader.next()

            let decoder = CSVRowDecoder()
            let row = try decoder.decode(BooleanDecodableExample.self, from: reader)
            XCTAssertEqual(row.falseValue, false)
            XCTAssertEqual(row.trueValue, true)
        } catch {
            XCTFail("\(error)")
        }
    }

    //===----------------------------------------------------------------------===//

    fileprivate struct IntegerDecodableExample: Decodable {
        let intValue: Int
        let int8Value: Int8
        let int16Value: Int16
        let int32Value: Int32
        let int64Value: Int64
    }

    func testDecodeInteger() {
        let csv = """
            intValue,int8Value,int16Value,int32Value,int64Value
            0,123,4567,89012,345678901234567890
            """
        do {
            let reader = try CSVReader(string: csv, hasHeaderRow: true)
            reader.next()

            let decoder = CSVRowDecoder()
            let row = try decoder.decode(IntegerDecodableExample.self, from: reader)
            XCTAssertEqual(row.intValue, 0)
            XCTAssertEqual(row.int8Value, 123)
            XCTAssertEqual(row.int16Value, 4567)
            XCTAssertEqual(row.int32Value, 89012)
            XCTAssertEqual(row.int64Value, 345678901234567890)
        } catch {
            XCTFail("\(error)")
        }
    }

    //===----------------------------------------------------------------------===//

    fileprivate struct UnsignedIntegerDecodableExample: Decodable {
        let uintValue: UInt
        let uint8Value: UInt8
        let uint16Value: UInt16
        let uint32Value: UInt32
        let uint64Value: UInt64
    }

    func testDecodeUnsignedInteger() {
        let csv = """
            uintValue,uint8Value,uint16Value,uint32Value,uint64Value
            0,123,4567,89012,345678901234567890
            """
        do {
            let reader = try CSVReader(string: csv, hasHeaderRow: true)
            reader.next()

            let decoder = CSVRowDecoder()
            let row = try decoder.decode(UnsignedIntegerDecodableExample.self, from: reader)
            XCTAssertEqual(row.uintValue, 0)
            XCTAssertEqual(row.uint8Value, 123)
            XCTAssertEqual(row.uint16Value, 4567)
            XCTAssertEqual(row.uint32Value, 89012)
            XCTAssertEqual(row.uint64Value, 345678901234567890)
        } catch {
            XCTFail("\(error)")
        }
    }

}
