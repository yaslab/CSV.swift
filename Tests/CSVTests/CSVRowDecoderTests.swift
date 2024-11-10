//
//  CSVRowDecoderTests.swift
//  CSV
//
//  Created by Ian Grossberg on 9/11/18.
//  Copyright © 2018 yaslab. All rights reserved.
//

import CSV
import XCTest

//===----------------------------------------------------------------------===//
// Models
//===----------------------------------------------------------------------===//

private enum Enum: String, Decodable {
    case first
    case second
}

private protocol DecodableTest: Equatable {
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
    fileprivate static func == (left: Self, right: Self) -> Bool {
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
                SupportedDecodableExample(intKey: 54321, stringKey: "stringValue2", optionalStringKey: "withValue", dateKey: Date(timeInterval: 100, since: Date()), enumKey: .second),
            ]
        }
    }

    func testNoHeader() throws {
        let noHeaderStr = "あ,い1,\"う\",えお\n,,x,"
        let noHeaderCSV = CSVReader(string: noHeaderStr)
        let row = try Array(noHeaderCSV).first!.get()

        do {
            let decoder = CSVRowDecoder()
            let _ = try decoder.decode(SupportedDecodableExample.self, from: row)
            XCTFail("Expect DecodingError.typeMismatch Error thrown")
        } catch {
            // Success
        }
    }

    func testNumberOfFieldsIsSmall() throws {
        let csv = """
            stringKey,intKey,optionalStringKey,dateKey,enumKey
            string 0  0 first
            string,0,,0,first
            """
        let reader = CSVReader(string: csv, hasHeaderRow: true)

        do {
            let decoder = CSVRowDecoder()
            for result in reader {
                let row = try result.get()
                _ = try decoder.decode(SupportedDecodableExample.self, from: row)
                break
            }
            XCTFail("decode<T>() did not threw error")
        } catch let DecodingError.valueNotFound(_, context) {
            // Success
            XCTAssertEqual("intKey", context.codingPath.last!.stringValue)
        } catch {
            XCTFail("The error thrown is not a DecodingError.valueNotFound")
        }
    }

    func testStringCodingKey() {
        let exampleRecords = SupportedDecodableExample.examples

        let header = SupportedDecodableExample.headerRow()
        let allRows = exampleRecords.reduce(into: header) { $0 += $1.toRow() }

        let headerCSV = CSVReader(string: allRows, hasHeaderRow: true)

        var records = [SupportedDecodableExample]()
        do {
            let decoder = CSVRowDecoder()
            for result in headerCSV {
                let row = try result.get()
                try records.append(decoder.decode(SupportedDecodableExample.self, from: row))
            }
        } catch {
            XCTFail("decode<T>() threw error: \(error)")
            return
        }
        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records[0], exampleRecords[0])
        XCTAssertEqual(records[1], exampleRecords[1])
    }

    func testConvertFromSnakeCase() {
        let csv = """
            first_column,SECOND_COLUMN
            first_value,SECOND_VALUE
            """

        struct SnakeCaseCsvRow: Codable, Equatable {
            let firstColumn: String
            let secondColumn: String
        }

        let reader = CSVReader(string: csv, hasHeaderRow: true)

        let decoder = CSVRowDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        var records = [SnakeCaseCsvRow]()

        do {
            for result in reader {
                let row = try result.get()
                try records.append(decoder.decode(SnakeCaseCsvRow.self, from: row))
            }
        } catch {
            XCTFail("decode<T>() threw error: \(error)")
            return
        }
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records[0], SnakeCaseCsvRow(firstColumn: "first_value", secondColumn: "SECOND_VALUE"))
    }

    func testConvertFromCustom() {
        let csv = """
            first Column,second Column
            first_value,second_value
            """

        struct CustomCsvRow: Codable, Equatable {
            let firstColumn: String
            let secondColumn: String
        }

        let reader = CSVReader(string: csv, hasHeaderRow: true)

        let decoder = CSVRowDecoder()
        decoder.keyDecodingStrategy = .custom({ $0.replacingOccurrences(of: " ", with: "") })

        var records = [CustomCsvRow]()

        do {
            for result in reader {
                let row = try result.get()
                try records.append(decoder.decode(CustomCsvRow.self, from: row))
            }
        } catch {
            XCTFail("decode<T>() threw error: \(error)")
            return
        }
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records[0], CustomCsvRow(firstColumn: "first_value", secondColumn: "second_value"))
    }

    func testEmptyStringDecodingFail() throws {
        let csv = """
            a,"b"
            ,""
            """

        struct EmptyStringCsvRow: Decodable {
            let a: String
            let b: String
        }

        let reader = CSVReader(string: csv, hasHeaderRow: true)
        let decoder = CSVRowDecoder()
        decoder.stringDecodingStrategy = .default

        var records = [EmptyStringCsvRow]()

        do {
            for result in reader {
                let row = try result.get()
                try records.append(decoder.decode(EmptyStringCsvRow.self, from: row))
            }
            XCTFail("decode<T>() did not throw")
        } catch {}
        XCTAssertEqual(records.count, 0)
    }

    func testEmptyStringDecodingSuccess() throws {
        let csv = """
            a,"b"
            ,""
            """

        struct EmptyStringCsvRow: Decodable {
            let a: String
            let b: String
        }

        let reader = CSVReader(string: csv, hasHeaderRow: true)
        let decoder = CSVRowDecoder()
        decoder.stringDecodingStrategy = .allowEmpty

        var records = [EmptyStringCsvRow]()

        do {
            for result in reader {
                let row = try result.get()
                try records.append(decoder.decode(EmptyStringCsvRow.self, from: row))
            }
        } catch {
            XCTFail("decode<T>() threw error: \(error)")
            return
        }
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records[0].a, "")
        XCTAssertEqual(records[0].b, "")
    }

    func testTypeInvalidDateFormat() {
        let invalidFieldTypeStr = """
            dateKey,stringKey,optionalStringKey,intKey,ignored
            al;ksdjf;akjsdf,asldkj,,1234,
            """
        let invalidFieldTypeCSV = CSVReader(string: invalidFieldTypeStr, hasHeaderRow: true)

        do {
            let decoder = CSVRowDecoder()
            for result in invalidFieldTypeCSV {
                let row = try result.get()
                _ = try decoder.decode(SupportedDecodableExample.self, from: row)
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
                IntKeyedDecodableExample(intKey: 54321, stringKey: "stringValue2", optionalStringKey: "withValue", dateKey: Date(timeInterval: 100, since: Date()), enumKey: .second),
            ]
        }
    }

    func testIntCodingKey() {
        let exampleRecords = IntKeyedDecodableExample.examples

        let allRows = IntKeyedDecodableExample.examples.reduce(into: "") { $0 += $1.toRow() }
        print(allRows)

        let headerCSV = CSVReader(string: allRows)

        var records = [IntKeyedDecodableExample]()
        do {
            let decoder = CSVRowDecoder()
            for result in headerCSV {
                let row = try result.get()
                try records.append(decoder.decode(IntKeyedDecodableExample.self, from: row))
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

        let headerCSV = CSVReader(string: allRows, hasHeaderRow: true)

        var records = [IntKeyedDecodableExample]()
        do {
            let decoder = CSVRowDecoder()
            for result in headerCSV {
                let row = try result.get()
                try records.append(decoder.decode(IntKeyedDecodableExample.self, from: row))
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
        let invalidFieldTypeCSV = CSVReader(string: invalidFieldTypeStr, hasHeaderRow: true)

        do {
            let decoder = CSVRowDecoder()
            for result in invalidFieldTypeCSV {
                let row = try result.get()
                _ = try decoder.decode(IntKeyedDecodableExample.self, from: row)
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
                UnsupportedDecodableExample(enumKey: .second),
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
        let headerCSV = CSVReader(string: headerStr, hasHeaderRow: true)

        var records = [UnsupportedDecodableExample]()
        do {
            let decoder = CSVRowDecoder()
            for result in headerCSV {
                let row = try result.get()
                try records.append(decoder.decode(UnsupportedDecodableExample.self, from: row))
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

    fileprivate struct IntegerDecodableExample: Decodable {
        let intValue: Int
        let int8Value: Int8
        let int16Value: Int16
        let int32Value: Int32
        let int64Value: Int64
        let uintValue: UInt
        let uint8Value: UInt8
        let uint16Value: UInt16
        let uint32Value: UInt32
        let uint64Value: UInt64
    }

    func testDecodeInteger() {
        let csv = """
            intValue,int8Value,int16Value,int32Value,int64Value,uintValue,uint8Value,uint16Value,uint32Value,uint64Value
            0,123,4567,89012,345678901234567890,1,124,4568,89013,345678901234567891
            """
        do {
            let reader = CSVReader(string: csv, hasHeaderRow: true)

            let decoder = CSVRowDecoder()

            for result in reader {
                let row = try decoder.decode(IntegerDecodableExample.self, from: result.get())
                XCTAssertEqual(row.intValue, 0)
                XCTAssertEqual(row.int8Value, 123)
                XCTAssertEqual(row.int16Value, 4567)
                XCTAssertEqual(row.int32Value, 89012)
                XCTAssertEqual(row.int64Value, 345678901234567890)
                XCTAssertEqual(row.uintValue, 1)
                XCTAssertEqual(row.uint8Value, 124)
                XCTAssertEqual(row.uint16Value, 4568)
                XCTAssertEqual(row.uint32Value, 89013)
                XCTAssertEqual(row.uint64Value, 345678901234567891)
                break
            }
        } catch {
            XCTFail("\(error)")
        }
    }

    //===----------------------------------------------------------------------===//

    fileprivate struct FloatDecodableExample: Decodable {
        let floatValue: Float
        let doubleValue: Double
    }

    func testDecodeFloat() {
        let csv = """
            floatValue,doubleValue
            123.456,7890.1234
            """
        do {
            let reader = CSVReader(string: csv, hasHeaderRow: true)

            for result in reader {
                let decoder = CSVRowDecoder()
                let row = try decoder.decode(FloatDecodableExample.self, from: result.get())
                XCTAssertEqual(row.floatValue, 123.456)
                XCTAssertEqual(row.doubleValue, 7890.1234)
                break
            }
        } catch {
            XCTFail("\(error)")
        }
    }

    //===----------------------------------------------------------------------===//

    fileprivate struct BoolDecodingStrategyExample: Decodable {
        let falseValue: Bool
        let trueValue: Bool
    }

    func testBoolDecodingStrategy_default() {
        let csv = """
            falseValue,trueValue
            false,true
            """
        do {
            let reader = CSVReader(string: csv, hasHeaderRow: true)

            let decoder = CSVRowDecoder()
            decoder.boolDecodingStrategy = .default

            for result in reader {
                let row = try decoder.decode(BoolDecodingStrategyExample.self, from: result.get())
                XCTAssertEqual(row.falseValue, false)
                XCTAssertEqual(row.trueValue, true)
                break
            }
        } catch {
            XCTFail("\(error)")
        }
    }

    func testBoolDecodingStrategy_custom() {
        let csv = """
            falseValue,trueValue
            0,1
            """
        do {
            let reader = CSVReader(string: csv, hasHeaderRow: true)

            let decoder = CSVRowDecoder()
            decoder.boolDecodingStrategy = .custom({ $0 != "0" })

            for result in reader {
                let row = try decoder.decode(BoolDecodingStrategyExample.self, from: result.get())
                XCTAssertEqual(row.falseValue, false)
                XCTAssertEqual(row.trueValue, true)
                break
            }
        } catch {
            XCTFail("\(error)")
        }
    }

    //===----------------------------------------------------------------------===//

    fileprivate struct DateDecodingStrategyExample: Decodable {
        let date: Date
    }

    func testDateDecodingStrategy_deferredToDate() {
        let expected = Date()
        let csv = """
            date
            \(expected.timeIntervalSinceReferenceDate)
            """
        do {
            let reader = CSVReader(string: csv, hasHeaderRow: true)

            let decoder = CSVRowDecoder()
            decoder.dateDecodingStrategy = .deferredToDate

            for result in reader {
                let row = try decoder.decode(DateDecodingStrategyExample.self, from: result.get())
                XCTAssertEqual(row.date, expected)
                break
            }
        } catch {
            XCTFail("\(error)")
        }
    }

    func testDateDecodingStrategy_secondsSince1970() {
        let expected = Date()
        let csv = """
            date
            \(expected.timeIntervalSince1970)
            """
        do {
            let reader = CSVReader(string: csv, hasHeaderRow: true)

            let decoder = CSVRowDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970

            for result in reader {
                let row = try decoder.decode(DateDecodingStrategyExample.self, from: result.get())
                XCTAssertEqual(row.date.timeIntervalSince1970, expected.timeIntervalSince1970)
                break
            }
        } catch {
            XCTFail("\(error)")
        }
    }

    func testDateDecodingStrategy_millisecondsSince1970() {
        let seconds: TimeInterval = 1542857696.0
        let csv = """
            date
            \(seconds * 1000.0)
            """
        do {
            let reader = CSVReader(string: csv, hasHeaderRow: true)

            let decoder = CSVRowDecoder()
            decoder.dateDecodingStrategy = .millisecondsSince1970

            for result in reader {
                let row = try decoder.decode(DateDecodingStrategyExample.self, from: result.get())
                XCTAssertEqual(row.date.timeIntervalSince1970, seconds)
                break
            }
        } catch {
            XCTFail("\(error)")
        }
    }

    @available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
    func testDateDecodingStrategy_iso8601() {
        let csv = """
            date
            2018-11-22T12:34:56+09:00
            """
        do {
            let reader = CSVReader(string: csv, hasHeaderRow: true)

            let decoder = CSVRowDecoder()
            decoder.dateDecodingStrategy = .iso8601

            for result in reader {
                let row = try decoder.decode(DateDecodingStrategyExample.self, from: result.get())
                XCTAssertEqual(row.date.timeIntervalSince1970, 1542857696)
                break
            }
        } catch {
            XCTFail("\(error)")
        }
    }

    func testDateDecodingStrategy_formatted() {
        let csv = """
            date
            2018/11/22
            """
        do {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
            formatter.dateFormat = "yyyy/MM/dd"

            let reader = CSVReader(string: csv, hasHeaderRow: true)

            let decoder = CSVRowDecoder()
            decoder.dateDecodingStrategy = .formatted(formatter)

            for result in reader {
                let row = try decoder.decode(DateDecodingStrategyExample.self, from: result.get())
                XCTAssertEqual(row.date.timeIntervalSince1970, 1542812400)
                break
            }
        } catch {
            XCTFail("\(error)")
        }
    }

    func testDateDecodingStrategy_custom() {
        let expected = Date()
        let csv = """
            date
            \(expected.timeIntervalSinceReferenceDate)
            """
        do {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
            formatter.dateFormat = "yyyy/MM/dd"

            let reader = CSVReader(string: csv, hasHeaderRow: true)

            let decoder = CSVRowDecoder()
            decoder.dateDecodingStrategy = .custom({ Date(timeIntervalSinceReferenceDate: Double($0)!) })

            for result in reader {
                let row = try decoder.decode(DateDecodingStrategyExample.self, from: result.get())
                XCTAssertEqual(row.date, expected)
                break
            }
        } catch {
            XCTFail("\(error)")
        }
    }

    //===----------------------------------------------------------------------===//

    fileprivate struct DataDecodingStrategyExample: Decodable {
        let data: Data
    }

    func testDataDecodingStrategy_base64() {
        let expected = Data([0x56, 0x12, 0x00, 0x34, 0x1a, 0xfe])
        let csv = """
            data
            "\(expected.base64EncodedString())"
            """
        do {
            let reader = CSVReader(string: csv, hasHeaderRow: true)

            let decoder = CSVRowDecoder()
            decoder.dataDecodingStrategy = .base64

            for result in reader {
                let row = try decoder.decode(DataDecodingStrategyExample.self, from: result.get())
                XCTAssertEqual(row.data, expected)
                break
            }
        } catch {
            XCTFail("\(error)")
        }
    }

    func testDataDecodingStrategy_custom() {
        let expected = Data([0x34, 0x1a, 0xfe, 0x56, 0x12, 0x00])
        let csv = """
            data
            "\(expected.map({ String(format: "%02x", $0) }).joined())"
            """
        do {
            let reader = CSVReader(string: csv, hasHeaderRow: true)

            let decoder = CSVRowDecoder()
            decoder.dataDecodingStrategy = .custom { value in
                var bytes = [UInt8]()
                for i in stride(from: 0, to: value.count, by: 2) {
                    let start = value.index(value.startIndex, offsetBy: i)
                    let end = value.index(value.startIndex, offsetBy: i + 1)
                    bytes.append(UInt8(value[start ... end], radix: 16)!)
                }
                return Data(bytes)
            }

            for result in reader {
                let row = try decoder.decode(DataDecodingStrategyExample.self, from: result.get())
                XCTAssertEqual(row.data, expected)
                break
            }
        } catch {
            XCTFail("\(error)")
        }
    }

    //===----------------------------------------------------------------------===//

    fileprivate struct NilDecodingStrategyExample: Decodable {
        let string: String?
    }

    func testNilDecodingStrategy_empty() {
        let csv = """
            string

            null
            """

        do {
            let reader = CSVReader(string: csv, hasHeaderRow: true)

            let decoder = CSVRowDecoder()
            decoder.nilDecodingStrategy = .empty

            var rows: [NilDecodingStrategyExample] = []
            for result in reader {
                let row = try decoder.decode(NilDecodingStrategyExample.self, from: result.get())
                rows.append(row)
            }

            XCTAssertEqual(rows.count, 2)
            XCTAssertNil(rows[0].string)
            XCTAssertEqual(rows[1].string, "null")
        } catch {
            XCTFail("\(error)")
        }
    }

    func testNilDecodingStrategy_never() {
        let csv = """
            string

            null
            """

        do {
            let reader = CSVReader(string: csv, hasHeaderRow: true)

            let decoder = CSVRowDecoder()
            decoder.nilDecodingStrategy = .never

            var rows: [NilDecodingStrategyExample] = []
            for result in reader {
                let row = try decoder.decode(NilDecodingStrategyExample.self, from: result.get())
                rows.append(row)
            }

            XCTAssertEqual(rows.count, 2)
            XCTAssertEqual(rows[0].string, "")
            XCTAssertEqual(rows[1].string, "null")
        } catch {
            XCTFail("\(error)")
        }
    }

    func testNilDecodingStrategy_custom() {
        let csv = """
            string

            null
            """

        do {
            let reader = CSVReader(string: csv, hasHeaderRow: true)

            let decoder = CSVRowDecoder()
            decoder.nilDecodingStrategy = .custom { $0 == "null" }

            var rows: [NilDecodingStrategyExample] = []
            for result in reader {
                let row = try decoder.decode(NilDecodingStrategyExample.self, from: result.get())
                rows.append(row)
            }

            XCTAssertEqual(rows.count, 2)
            XCTAssertEqual(rows[0].string, "")
            XCTAssertNil(rows[1].string)
        } catch {
            XCTFail("\(error)")
        }
    }

    func testNilDecodingStrategy_error() {
        struct RowModel: Decodable {
            let a: Int
        }

        let csv = """
            a
            ""
            """

        do {
            let reader = CSVReader(string: csv, hasHeaderRow: true)

            let decoder = CSVRowDecoder()
            decoder.nilDecodingStrategy = .empty

            var rows: [RowModel] = []
            for result in reader {
                let row = try decoder.decode(RowModel.self, from: result.get())
                rows.append(row)
            }

            XCTFail("decode<T>() did not throw")
        } catch {
            XCTAssertTrue(error is DecodingError)
        }
    }

    //===----------------------------------------------------------------------===//

    fileprivate struct FoundationDecodingExample: Decodable {
        let url: URL
        let decimal: Decimal
    }

    func testFoundationDecoding() {
        let csv = """
            url,decimal
            "https://www.example.com/path?param=1",99999999999999999999.9999999999999999
            """
        do {
            let reader = CSVReader(string: csv, hasHeaderRow: true)

            let decoder = CSVRowDecoder()

            for result in reader {
                let row = try decoder.decode(FoundationDecodingExample.self, from: result.get())
                XCTAssertEqual(row.url.absoluteString, "https://www.example.com/path?param=1")
                XCTAssertEqual(row.decimal.description, "99999999999999999999.9999999999999999")
                break
            }
        } catch {
            XCTFail("\(error)")
        }
    }

}
