//
//  CSVRowDecoderTests.swift
//  CSV
//
//  Created by Ian Grossberg on 9/11/18.
//  Copyright © 2018 yaslab. All rights reserved.
//

import XCTest
@testable import CSV

enum Enum: String, Decodable {
    case first
    case second
}

protocol DecodableTest: Equatable {
    var intKey: Int { get }
    var stringKey: String { get }
    var optionalStringKey: String? { get }
    var dateKey: Date { get }
    var enumKey: Enum { get }
    
    func toRow() -> String
}

extension DecodableTest {
    func toRow() -> String {
        //return "\(self.stringKey),\(self.optionalStringKey ?? ""),\(self.intKey),,\"\(CSVReader.dateFormatter.string(from: self.dateKey))\",\(self.enumKey)\n"
        return "\(self.stringKey),\(self.optionalStringKey ?? ""),\(self.intKey),,\"\(self.dateKey.timeIntervalSinceReferenceDate)\",\(self.enumKey)\n"
    }
}

extension Equatable where Self: DecodableTest {
    static func ==(left: Self, right: Self) -> Bool {
        //let formatter = CSVReader.dateFormatter
        return left.intKey == right.intKey && left.stringKey == right.stringKey && left.optionalStringKey == right.optionalStringKey
            //&& left.dateKey.compare(right.dateKey) == ComparisonResult.orderedSame // TODO: find more accurate conversion method, cannot compare directly likely because we are losing precision when in csv
            //&& formatter.string(from: left.dateKey) == formatter.string(from: right.dateKey)
            && Int(left.dateKey.timeIntervalSince1970) == Int(right.dateKey.timeIntervalSince1970)
            && left.enumKey == right.enumKey
    }
}

class CSVReader_DecodableTests: XCTestCase {
    static let allTests = [
        ("testNoHeader", testNoHeader),
        ("testStringCodingKey", testStringCodingKey),
        ("testIntCodingKey", testIntCodingKey),
        ("testIntCodingKeyWhileIgnoringHeaders", testIntCodingKeyWhileIgnoringHeaders),
        ("testTypeMismatch", testTypeMismatch),
    ]
    

    
    struct SupportedDecodableExample: Decodable, DecodableTest {
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
    
    struct IntKeyedDecodableExample: Decodable, DecodableTest {
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
    
    func testNoHeader() {
        let noHeaderConfig = CSVReader.Configuration(hasHeaderRow: false,
                                                     trimFields: false,
                                                     delimiter: ",",
                                                     whitespaces: .whitespaces)
        let noHeaderIt = "あ,い1,\"う\",えお\n,,x,".unicodeScalars.makeIterator()
        let noHeaderCSV = try! CSVReader(iterator: noHeaderIt, configuration: noHeaderConfig)
        
        do {
            let _: SupportedDecodableExample? = try noHeaderCSV.readRow()
            XCTFail("Expect DecodingError.typeMismatch Error thrown")
        } catch {
        }
    }
    
    func testStringCodingKey() {
        let headerConfig = CSVReader.Configuration(hasHeaderRow: true,
                                                   trimFields: false,
                                                   delimiter: ",",
                                                   whitespaces: .whitespaces)
        let exampleRecords = SupportedDecodableExample.examples
        
        let header = "stringKey,optionalStringKey,intKey,ignored,dateKey,enumKey\n"
        let allRows = SupportedDecodableExample.examples.reduce(into: header) {  $0 += $1.toRow() }
        let rowIterator = allRows.unicodeScalars.makeIterator()
        
        let headerCSV = try! CSVReader(iterator: rowIterator, configuration: headerConfig)
        
        var records = [SupportedDecodableExample]()
        do {
            while let record: SupportedDecodableExample = try headerCSV.readRow() {
                records.append(record)
            }
        } catch {
            XCTFail("readRow<T>() threw error: \(error)")
        }
        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records[0], exampleRecords[0])
        XCTAssertEqual(records[1], exampleRecords[1])
    }
    
    func testIntCodingKey() {
        let headerConfig = CSVReader.Configuration(hasHeaderRow: false,
                                                   trimFields: false,
                                                   delimiter: ",",
                                                   whitespaces: .whitespaces)
        let exampleRecords = IntKeyedDecodableExample.examples
        
        let allRows = IntKeyedDecodableExample.examples.reduce(into: "") {  $0 += $1.toRow() }
        let rowIterator = allRows.unicodeScalars.makeIterator()
        
        let headerCSV = try! CSVReader(iterator: rowIterator, configuration: headerConfig)
        
        var records = [IntKeyedDecodableExample]()
        do {
            while let record: IntKeyedDecodableExample = try headerCSV.readRow() {
                records.append(record)
            }
        } catch {
            XCTFail("readRow<T>() threw error: \(error)")
        }
        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records[0], exampleRecords[0])
        XCTAssertEqual(records[1], exampleRecords[1])
    }
    
    func testIntCodingKeyWhileIgnoringHeaders() {
        let headerConfig = CSVReader.Configuration(hasHeaderRow: true,
                                                   trimFields: false,
                                                   delimiter: ",",
                                                   whitespaces: .whitespaces)
        let exampleRecords = IntKeyedDecodableExample.examples
        
        let header = "stringKey,optionalStringKey,intKey,ignored,dateKey,enumKey\n"
        let allRows = IntKeyedDecodableExample.examples.reduce(into: header) {  $0 += $1.toRow() }
        let rowIterator = allRows.unicodeScalars.makeIterator()
        
        let headerCSV = try! CSVReader(iterator: rowIterator, configuration: headerConfig)
        
        var records = [IntKeyedDecodableExample]()
        do {
            while let record: IntKeyedDecodableExample = try headerCSV.readRow() {
                records.append(record)
            }
        } catch {
            XCTFail("readRow<T>() threw error: \(error)")
        }
        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records[0], exampleRecords[0])
        XCTAssertEqual(records[1], exampleRecords[1])
    }
    
    func testTypeMismatch() {
        let headerConfig = CSVReader.Configuration(hasHeaderRow: true,
                                                   trimFields: false,
                                                   delimiter: ",",
                                                   whitespaces: .whitespaces)
        let exampleRecords = SupportedDecodableExample.examples

        let invalidFieldTypeIt = """
            stringKey,optionalStringKey,intKey,ignored
            \(exampleRecords[0].stringKey),,this is a string where we expect an Int,
            \(exampleRecords[1].stringKey),\(exampleRecords[1].optionalStringKey!),\(exampleRecords[1].intKey),
            """.unicodeScalars.makeIterator()
        let invalidFieldTypeCSV = try! CSVReader(iterator: invalidFieldTypeIt, configuration: headerConfig)
        
        do {
            while let _: SupportedDecodableExample = try invalidFieldTypeCSV.readRow() {
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
                break
            default:
                XCTFail("Expect Type Mismatch Error thrown")
                return
            }
        }
    }
    
    func testTypeInvalidDateFormat() {
        let headerConfig = CSVReader.Configuration(hasHeaderRow: true,
                                                   trimFields: false,
                                                   delimiter: ",",
                                                   whitespaces: .whitespaces)
        let invalidFieldTypeIt = """
            dateKey,stringKey,optionalStringKey,intKey,ignored
            al;ksdjf;akjsdf,asldkj,,1234,
            """.unicodeScalars.makeIterator()
        let invalidFieldTypeCSV = try! CSVReader(iterator: invalidFieldTypeIt, configuration: headerConfig)
        
        do {
            while let _: SupportedDecodableExample = try invalidFieldTypeCSV.readRow() {
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
                break
            default:
                XCTFail("Expect DecodingError.dataCorrupted Error thrown, got \(error)")
                return
            }
        }
    }
    
    struct UnsupportedDecodableExample: Decodable, Equatable {
        let enumKey: Enum
        
        static func ==(left: UnsupportedDecodableExample, right: UnsupportedDecodableExample) -> Bool {
            return left.enumKey == right.enumKey
        }
        
        static var examples: [UnsupportedDecodableExample] {
            return [
                UnsupportedDecodableExample(enumKey: .first),
                UnsupportedDecodableExample(enumKey: .second)
            ]
        }
    }
    
    func testUnsupportedDecodableField() {
        let headerConfig = CSVReader.Configuration(hasHeaderRow: true,
                                                   trimFields: false,
                                                   delimiter: ",",
                                                   whitespaces: .whitespaces)
        let exampleRecords = UnsupportedDecodableExample.examples
        
        let headerIt = """
            enumKey,optionalStringKey,intKey,ignored,dateKey
            \(exampleRecords[0].enumKey),"hiiiii",123445,,
            \(exampleRecords[1].enumKey),,54231,,
            \("third"),,54231,,
            """.unicodeScalars.makeIterator()
        let headerCSV = try! CSVReader(iterator: headerIt, configuration: headerConfig)
        
        var records = [UnsupportedDecodableExample]()
        do {
            while let record: UnsupportedDecodableExample = try headerCSV.readRow() {
                records.append(record)
            }
            XCTFail("Expect Data Corrupted Error thrown")
        } catch {
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
                break
            default:
                XCTFail("Expect Data Corrupted Error thrown, instead we got \(decodingError)")
                return
            }
        }
    }

    struct BooleanDecodableExample: Decodable {
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

            let row = try reader.readRow() as BooleanDecodableExample?
            XCTAssertEqual(row!.falseValue, false)
            XCTAssertEqual(row!.trueValue, true)
        } catch {
            XCTFail("\(error)")
        }
    }

    struct IntegerDecodableExample: Decodable {
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

            let row = try reader.readRow() as IntegerDecodableExample?
            XCTAssertEqual(row!.intValue, 0)
            XCTAssertEqual(row!.int8Value, 123)
            XCTAssertEqual(row!.int16Value, 4567)
            XCTAssertEqual(row!.int32Value, 89012)
            XCTAssertEqual(row!.int64Value, 345678901234567890)
        } catch {
            XCTFail("\(error)")
        }
    }

    struct UnsignedIntegerDecodableExample: Decodable {
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

            let row = try reader.readRow() as UnsignedIntegerDecodableExample?
            XCTAssertEqual(row!.uintValue, 0)
            XCTAssertEqual(row!.uint8Value, 123)
            XCTAssertEqual(row!.uint16Value, 4567)
            XCTAssertEqual(row!.uint32Value, 89012)
            XCTAssertEqual(row!.uint64Value, 345678901234567890)
        } catch {
            XCTFail("\(error)")
        }
    }
}
