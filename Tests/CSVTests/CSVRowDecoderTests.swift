//
//  CSVRowDecoderTests.swift
//  CSV
//
//  Created by Ian Grossberg on 2018/09/11.
//  Copyright © 2018 yaslab. All rights reserved.
//

import CSV
import Foundation
import Testing

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

struct CSVRowDecoderTests {

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

    @Test func testNoHeader() throws {
        let noHeaderStr = "あ,い1,\"う\",えお\n,,x,"
        let noHeaderCSV = CSVReader(string: noHeaderStr)
        let row = try Array(noHeaderCSV).first!.get()

        #expect {
            let decoder = CSVRowDecoder()
            let _ = try decoder.decode(SupportedDecodableExample.self, from: row)
        } throws: { error in
            // FIXME: Assert error
            return true
        }
    }

    @Test func testNumberOfFieldsIsSmall() throws {
        let csv = """
            stringKey,intKey,optionalStringKey,dateKey,enumKey
            string 0  0 first
            string,0,,0,first
            """
        let reader = CSVReader(string: csv, configuration: .csv(hasHeaderRow: true))

        #expect {
            let decoder = CSVRowDecoder()
            for result in reader {
                let row = try result.get()
                _ = try decoder.decode(SupportedDecodableExample.self, from: row)
                break
            }
        } throws: {
            guard let error = $0 as? DecodingError else {
                return false
            }
            guard case .valueNotFound(_, let context) = error else {
                return false
            }
            return context.codingPath.last!.stringValue == "intKey"
        }
    }

    @Test func testStringCodingKey() throws {
        let exampleRecords = SupportedDecodableExample.examples

        let header = SupportedDecodableExample.headerRow()
        let allRows = exampleRecords.reduce(into: header) { $0 += $1.toRow() }

        let reader = CSVReader(string: allRows, configuration: .csv(hasHeaderRow: true))

        var records = [SupportedDecodableExample]()

        let decoder = CSVRowDecoder()
        for result in reader {
            let row = try result.get()
            try records.append(decoder.decode(SupportedDecodableExample.self, from: row))
        }

        try #require(records.count == 2)
        #expect(records[0] == exampleRecords[0])
        #expect(records[1] == exampleRecords[1])
    }

    @Test func testConvertFromSnakeCase() throws {
        let csv = """
            first_column,SECOND_COLUMN
            first_value,SECOND_VALUE
            """

        struct SnakeCaseCsvRow: Codable, Equatable {
            let firstColumn: String
            let secondColumn: String
        }

        let reader = CSVReader(string: csv, configuration: .csv(hasHeaderRow: true))

        let decoder = CSVRowDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        var records = [SnakeCaseCsvRow]()

        for result in reader {
            let row = try result.get()
            try records.append(decoder.decode(SnakeCaseCsvRow.self, from: row))
        }

        try #require(records.count == 1)
        #expect(records[0] == SnakeCaseCsvRow(firstColumn: "first_value", secondColumn: "SECOND_VALUE"))
    }

    @Test func testConvertFromCustom() throws {
        let csv = """
            first Column,second Column
            first_value,second_value
            """

        struct CustomCsvRow: Codable, Equatable {
            let firstColumn: String
            let secondColumn: String
        }

        let reader = CSVReader(string: csv, configuration: .csv(hasHeaderRow: true))

        let decoder = CSVRowDecoder()
        decoder.keyDecodingStrategy = .custom({ $0.replacingOccurrences(of: " ", with: "") })

        var records = [CustomCsvRow]()

        for result in reader {
            let row = try result.get()
            try records.append(decoder.decode(CustomCsvRow.self, from: row))
        }

        try #require(records.count == 1)
        #expect(records[0] == CustomCsvRow(firstColumn: "first_value", secondColumn: "second_value"))
    }

    @Test func testEmptyStringDecodingFail() throws {
        let csv = """
            a,"b"
            ,""
            """

        struct EmptyStringCsvRow: Decodable {
            let a: String
            let b: String
        }

        let reader = CSVReader(string: csv, configuration: .csv(hasHeaderRow: true))

        let decoder = CSVRowDecoder()
        decoder.stringDecodingStrategy = .default

        var records = [EmptyStringCsvRow]()

        #expect {
            for result in reader {
                let row = try result.get()
                try records.append(decoder.decode(EmptyStringCsvRow.self, from: row))
            }
        } throws: { error in
            // FIXME: Assert error
            return true
        }
    }

    @Test func testEmptyStringDecodingSuccess() throws {
        let csv = """
            a,"b"
            ,""
            """

        struct EmptyStringCsvRow: Decodable {
            let a: String
            let b: String
        }

        let reader = CSVReader(string: csv, configuration: .csv(hasHeaderRow: true))

        let decoder = CSVRowDecoder()
        decoder.stringDecodingStrategy = .allowEmpty

        var records = [EmptyStringCsvRow]()

        for result in reader {
            let row = try result.get()
            try records.append(decoder.decode(EmptyStringCsvRow.self, from: row))
        }

        try #require(records.count == 1)
        #expect(records[0].a == "")
        #expect(records[0].b == "")
    }

    @Test func testTypeInvalidDateFormat() {
        let invalidFieldTypeStr = """
            dateKey,stringKey,optionalStringKey,intKey,ignored
            al;ksdjf;akjsdf,asldkj,,1234,
            """
        let reader = CSVReader(string: invalidFieldTypeStr, configuration: .csv(hasHeaderRow: true))

        #expect("Type Mismatch Error on unexpected field") {
            let decoder = CSVRowDecoder()
            for result in reader {
                let row = try result.get()
                _ = try decoder.decode(SupportedDecodableExample.self, from: row)
            }
        } throws: {
            guard let error = $0 as? DecodingError else {
                return false
            }
            switch error {
            case let DecodingError.typeMismatch(type, context):
                return type == Double.self
                    && context.codingPath[0].stringValue == "dateKey"
            default:
                return false
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

    @Test func testIntCodingKey() throws {
        let exampleRecords = IntKeyedDecodableExample.examples

        let allRows = IntKeyedDecodableExample.examples.reduce(into: "") { $0 += $1.toRow() }
        print(allRows)

        let headerCSV = CSVReader(string: allRows)

        var records = [IntKeyedDecodableExample]()

        let decoder = CSVRowDecoder()
        for result in headerCSV {
            let row = try result.get()
            try records.append(decoder.decode(IntKeyedDecodableExample.self, from: row))
        }

        try #require(records.count == 2)
        #expect(records[0] == exampleRecords[0])
        #expect(records[1] == exampleRecords[1])
    }

    @Test func testIntCodingKeyWhileIgnoringHeaders() throws {
        let exampleRecords = IntKeyedDecodableExample.examples

        let header = IntKeyedDecodableExample.headerRow()
        let allRows = exampleRecords.reduce(into: header) { $0 += $1.toRow() }

        let reader = CSVReader(string: allRows, configuration: .csv(hasHeaderRow: true))

        var records = [IntKeyedDecodableExample]()

        let decoder = CSVRowDecoder()
        for result in reader {
            let row = try result.get()
            try records.append(decoder.decode(IntKeyedDecodableExample.self, from: row))
        }

        try #require(records.count == 2)
        #expect(records[0] == exampleRecords[0])
        #expect(records[1] == exampleRecords[1])
    }

    @Test func testTypeMismatch() {
        let exampleRecords = SupportedDecodableExample.examples

        let invalidFieldTypeStr = """
            stringKey,optionalStringKey,intKey,ignored
            \(exampleRecords[0].stringKey),,this is a string where we expect an Int,
            \(exampleRecords[1].stringKey),\(exampleRecords[1].optionalStringKey!),\(exampleRecords[1].intKey),
            """
        let reader = CSVReader(string: invalidFieldTypeStr, configuration: .csv(hasHeaderRow: true))

        #expect("Type Mismatch Error on unexpected field") {
            let decoder = CSVRowDecoder()
            for result in reader {
                let row = try result.get()
                _ = try decoder.decode(IntKeyedDecodableExample.self, from: row)
            }
        } throws: {
            guard let error = $0 as? DecodingError else {
                return false
            }
            switch error {
            case let .typeMismatch(_, context):
                return context.codingPath[0].stringValue == "intKey"
            default:
                return false
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

    @Test func testUnsupportedDecodableField() {
        let exampleRecords = UnsupportedDecodableExample.examples

        let headerStr = """
            enumKey,optionalStringKey,intKey,ignored,dateKey
            \(exampleRecords[0].enumKey),"hiiiii",123445,,
            \(exampleRecords[1].enumKey),,54231,,
            \("third"),,54231,,
            """
        let reader = CSVReader(string: headerStr, configuration: .csv(hasHeaderRow: true))

        var records = [UnsupportedDecodableExample]()

        #expect {
            let decoder = CSVRowDecoder()
            for result in reader {
                let row = try result.get()
                try records.append(decoder.decode(UnsupportedDecodableExample.self, from: row))
            }
        } throws: {
            guard records.count == 2 else {
                return false
            }
            guard let decodingError = $0 as? DecodingError else {
                return false
            }
            switch decodingError {
            case let .dataCorrupted(context):
                return context.codingPath[0].stringValue == "enumKey"
            default:
                return false
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

    @Test func testDecodeInteger() throws {
        let csv = """
            intValue,int8Value,int16Value,int32Value,int64Value,uintValue,uint8Value,uint16Value,uint32Value,uint64Value
            0,123,4567,89012,345678901234567890,1,124,4568,89013,345678901234567891
            """

        let reader = CSVReader(string: csv, configuration: .csv(hasHeaderRow: true))

        let decoder = CSVRowDecoder()

        for result in reader {
            let row = try decoder.decode(IntegerDecodableExample.self, from: result.get())
            #expect(row.intValue == 0)
            #expect(row.int8Value == 123)
            #expect(row.int16Value == 4567)
            #expect(row.int32Value == 89012)
            #expect(row.int64Value == 345678901234567890)
            #expect(row.uintValue == 1)
            #expect(row.uint8Value == 124)
            #expect(row.uint16Value == 4568)
            #expect(row.uint32Value == 89013)
            #expect(row.uint64Value == 345678901234567891)
            break
        }
    }

    //===----------------------------------------------------------------------===//

    fileprivate struct FloatDecodableExample: Decodable {
        let floatValue: Float
        let doubleValue: Double
    }

    @Test func testDecodeFloat() throws {
        let csv = """
            floatValue,doubleValue
            123.456,7890.1234
            """

        let reader = CSVReader(string: csv, configuration: .csv(hasHeaderRow: true))

        for result in reader {
            let decoder = CSVRowDecoder()
            let row = try decoder.decode(FloatDecodableExample.self, from: result.get())
            #expect(row.floatValue == 123.456)
            #expect(row.doubleValue == 7890.1234)
            break
        }
    }

    //===----------------------------------------------------------------------===//

    fileprivate struct BoolDecodingStrategyExample: Decodable {
        let falseValue: Bool
        let trueValue: Bool
    }

    @Test func testBoolDecodingStrategy_default() throws {
        let csv = """
            falseValue,trueValue
            false,true
            """

        let reader = CSVReader(string: csv, configuration: .csv(hasHeaderRow: true))

        let decoder = CSVRowDecoder()
        decoder.boolDecodingStrategy = .default

        for result in reader {
            let row = try decoder.decode(BoolDecodingStrategyExample.self, from: result.get())
            #expect(row.falseValue == false)
            #expect(row.trueValue == true)
            break
        }
    }

    @Test func testBoolDecodingStrategy_custom() throws {
        let csv = """
            falseValue,trueValue
            0,1
            """

        let reader = CSVReader(string: csv, configuration: .csv(hasHeaderRow: true))

        let decoder = CSVRowDecoder()
        decoder.boolDecodingStrategy = .custom({ $0 != "0" })

        for result in reader {
            let row = try decoder.decode(BoolDecodingStrategyExample.self, from: result.get())
            #expect(row.falseValue == false)
            #expect(row.trueValue == true)
            break
        }
    }

    //===----------------------------------------------------------------------===//

    fileprivate struct DateDecodingStrategyExample: Decodable {
        let date: Date
    }

    @Test func testDateDecodingStrategy_deferredToDate() throws {
        let expected = Date()
        let csv = """
            date
            \(expected.timeIntervalSinceReferenceDate)
            """

        let reader = CSVReader(string: csv, configuration: .csv(hasHeaderRow: true))

        let decoder = CSVRowDecoder()
        decoder.dateDecodingStrategy = .deferredToDate

        for result in reader {
            let row = try decoder.decode(DateDecodingStrategyExample.self, from: result.get())
            #expect(row.date == expected)
            break
        }
    }

    @Test func testDateDecodingStrategy_secondsSince1970() throws {
        let expected = Date()
        let csv = """
            date
            \(expected.timeIntervalSince1970)
            """

        let reader = CSVReader(string: csv, configuration: .csv(hasHeaderRow: true))

        let decoder = CSVRowDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970

        for result in reader {
            let row = try decoder.decode(DateDecodingStrategyExample.self, from: result.get())
            #expect(row.date.timeIntervalSince1970 == expected.timeIntervalSince1970)
            break
        }
    }

    @Test func testDateDecodingStrategy_millisecondsSince1970() throws {
        let seconds: TimeInterval = 1542857696.0
        let csv = """
            date
            \(seconds * 1000.0)
            """

        let reader = CSVReader(string: csv, configuration: .csv(hasHeaderRow: true))

        let decoder = CSVRowDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970

        for result in reader {
            let row = try decoder.decode(DateDecodingStrategyExample.self, from: result.get())
            #expect(row.date.timeIntervalSince1970 == seconds)
            break
        }
    }

    @Test func testDateDecodingStrategy_iso8601() throws {
        let csv = """
            date
            2018-11-22T12:34:56+09:00
            """

        let reader = CSVReader(string: csv, configuration: .csv(hasHeaderRow: true))

        let decoder = CSVRowDecoder()
        decoder.dateDecodingStrategy = .iso8601

        for result in reader {
            let row = try decoder.decode(DateDecodingStrategyExample.self, from: result.get())
            #expect(row.date.timeIntervalSince1970 == 1542857696)
            break
        }
    }

    @Test func testDateDecodingStrategy_formatted() throws {
        let csv = """
            date
            2018/11/22
            """

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        formatter.dateFormat = "yyyy/MM/dd"

        let reader = CSVReader(string: csv, configuration: .csv(hasHeaderRow: true))

        let decoder = CSVRowDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)

        for result in reader {
            let row = try decoder.decode(DateDecodingStrategyExample.self, from: result.get())
            #expect(row.date.timeIntervalSince1970 == 1542812400)
            break
        }
    }

    @Test func testDateDecodingStrategy_custom() throws {
        let expected = Date()
        let csv = """
            date
            \(expected.timeIntervalSinceReferenceDate)
            """

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        formatter.dateFormat = "yyyy/MM/dd"

        let reader = CSVReader(string: csv, configuration: .csv(hasHeaderRow: true))

        let decoder = CSVRowDecoder()
        decoder.dateDecodingStrategy = .custom({ Date(timeIntervalSinceReferenceDate: Double($0)!) })

        for result in reader {
            let row = try decoder.decode(DateDecodingStrategyExample.self, from: result.get())
            #expect(row.date == expected)
            break
        }
    }

    //===----------------------------------------------------------------------===//

    fileprivate struct DataDecodingStrategyExample: Decodable {
        let data: Data
    }

    @Test func testDataDecodingStrategy_base64() throws {
        let expected = Data([0x56, 0x12, 0x00, 0x34, 0x1a, 0xfe])
        let csv = """
            data
            "\(expected.base64EncodedString())"
            """

        let reader = CSVReader(string: csv, configuration: .csv(hasHeaderRow: true))

        let decoder = CSVRowDecoder()
        decoder.dataDecodingStrategy = .base64

        for result in reader {
            let row = try decoder.decode(DataDecodingStrategyExample.self, from: result.get())
            #expect(row.data == expected)
            break
        }
    }

    @Test func testDataDecodingStrategy_custom() throws {
        let expected = Data([0x34, 0x1a, 0xfe, 0x56, 0x12, 0x00])
        let csv = """
            data
            "\(expected.map({ String(format: "%02x", $0) }).joined())"
            """

        let reader = CSVReader(string: csv, configuration: .csv(hasHeaderRow: true))

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
            #expect(row.data == expected)
            break
        }
    }

    //===----------------------------------------------------------------------===//

    fileprivate struct NilDecodingStrategyExample: Decodable {
        let string: String?
    }

    @Test func testNilDecodingStrategy_empty() throws {
        let csv = """
            string

            null
            """

        let reader = CSVReader(string: csv, configuration: .csv(hasHeaderRow: true))

        let decoder = CSVRowDecoder()
        decoder.nilDecodingStrategy = .empty

        var rows: [NilDecodingStrategyExample] = []
        for result in reader {
            let row = try decoder.decode(NilDecodingStrategyExample.self, from: result.get())
            rows.append(row)
        }

        try #require(rows.count == 2)
        #expect(rows[0].string == nil)
        #expect(rows[1].string == "null")
    }

    @Test func testNilDecodingStrategy_never() throws {
        let csv = """
            string

            null
            """

        let reader = CSVReader(string: csv, configuration: .csv(hasHeaderRow: true))

        let decoder = CSVRowDecoder()
        decoder.nilDecodingStrategy = .never

        var rows: [NilDecodingStrategyExample] = []
        for result in reader {
            let row = try decoder.decode(NilDecodingStrategyExample.self, from: result.get())
            rows.append(row)
        }

        try #require(rows.count == 2)
        #expect(rows[0].string == "")
        #expect(rows[1].string == "null")
    }

    @Test func testNilDecodingStrategy_custom() throws {
        let csv = """
            string

            null
            """

        let reader = CSVReader(string: csv, configuration: .csv(hasHeaderRow: true))

        let decoder = CSVRowDecoder()
        decoder.nilDecodingStrategy = .custom { $0 == "null" }

        var rows: [NilDecodingStrategyExample] = []
        for result in reader {
            let row = try decoder.decode(NilDecodingStrategyExample.self, from: result.get())
            rows.append(row)
        }

        try #require(rows.count == 2)
        #expect(rows[0].string == "")
        #expect(rows[1].string == nil)
    }

    @Test func testNilDecodingStrategy_error() {
        struct RowModel: Decodable {
            let a: Int
        }

        let csv = """
            a
            ""
            """

        #expect(throws: DecodingError.self) {
            let reader = CSVReader(string: csv, configuration: .csv(hasHeaderRow: true))

            let decoder = CSVRowDecoder()
            decoder.nilDecodingStrategy = .empty

            var rows: [RowModel] = []
            for result in reader {
                let row = try decoder.decode(RowModel.self, from: result.get())
                rows.append(row)
            }
        }
    }

    //===----------------------------------------------------------------------===//

    fileprivate struct FoundationDecodingExample: Decodable {
        let url: URL
        let decimal: Decimal
    }

    @Test func testFoundationDecoding() throws {
        let csv = """
            url,decimal
            "https://www.example.com/path?param=1",99999999999999999999.9999999999999999
            """

        let reader = CSVReader(string: csv, configuration: .csv(hasHeaderRow: true))

        let decoder = CSVRowDecoder()

        for result in reader {
            let row = try decoder.decode(FoundationDecodingExample.self, from: result.get())
            #expect(row.url.absoluteString == "https://www.example.com/path?param=1")
            #expect(row.decimal.description == "99999999999999999999.9999999999999999")
            break
        }
    }

}
