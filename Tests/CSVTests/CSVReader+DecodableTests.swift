//
//  CSVReader+DecodableTests.swift
//  CSV
//
//  Created by Ian Grossberg on 9/11/18.
//  Copyright © 2018 yaslab. All rights reserved.
//

import XCTest
@testable import CSV

class CSVReader_DecodableTests: XCTestCase {
    static let allTests = [
        ("testNoHeader", testNoHeader),
        ("testBasic", testBasic),
        ("testTypeMismatch", testTypeMismatch),
    ]
    
    struct SupportedDecodableExample: Decodable, Equatable {
        let intKey: Int
        let stringKey: String
        let optionalStringKey: String?
        let dateKey: Date
        
        static func ==(left: SupportedDecodableExample, right: SupportedDecodableExample) -> Bool {
            let formatter = CSVReader.dateFormatter
            return left.intKey == right.intKey && left.stringKey == right.stringKey && left.optionalStringKey == right.optionalStringKey
                //&& left.dateKey.compare(right.dateKey) == ComparisonResult.orderedSame // TODO: find more accurate conversion method, cannot compare directly likely because we are losing precision when in csv
                && formatter.string(from: left.dateKey) == formatter.string(from: right.dateKey)
        }
        
        static var examples: [SupportedDecodableExample] {
            return [
                SupportedDecodableExample(intKey: 12345, stringKey: "stringValue", optionalStringKey: nil, dateKey: Date()),
                SupportedDecodableExample(intKey: 54321, stringKey: "stringValue2", optionalStringKey: "withValue", dateKey: Date(timeInterval: 100, since: Date()))
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
    
    func testBasic() {
        let headerConfig = CSVReader.Configuration(hasHeaderRow: true,
                                                   trimFields: false,
                                                   delimiter: ",",
                                                   whitespaces: .whitespaces)
        let exampleRecords = SupportedDecodableExample.examples
        let dateFormatter = CSVReader.dateFormatter
        
        let headerIt = """
            stringKey,optionalStringKey,intKey,ignored,dateKey
            \(exampleRecords[0].stringKey),,\(exampleRecords[0].intKey),,\"\(dateFormatter.string(from: exampleRecords[0].dateKey))\"
            \(exampleRecords[1].stringKey),\(exampleRecords[1].optionalStringKey!),\(exampleRecords[1].intKey),,\"\(dateFormatter.string(from: exampleRecords[1].dateKey))\"
            """.unicodeScalars.makeIterator()
        let headerCSV = try! CSVReader(iterator: headerIt, configuration: headerConfig)
        
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
            case let .dataCorrupted(context):
                XCTAssertEqual(context.codingPath[0].stringValue, "dateKey", "Type Mismatch Error on unexpected field")
                break
            default:
                XCTFail("Expect DecodingError.dataCorrupted Error thrown, got \(error)")
                return
            }
        }
    }
    
    struct UnsupportedDecodableExample: Decodable, Equatable {
        enum UndecodableEnum: Int, Decodable {
            case first
            case second
        }
        let enumKey: UndecodableEnum
        
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
            """.unicodeScalars.makeIterator()
        let headerCSV = try! CSVReader(iterator: headerIt, configuration: headerConfig)
        
        var records = [UnsupportedDecodableExample]()
        do {
            while let record: UnsupportedDecodableExample = try headerCSV.readRow() {
                records.append(record)
            }
            XCTFail("Expect Data Corrupted Error thrown")
        } catch {
            guard let error = error as? DecodingError else {
                XCTFail("Expect DecodingError Error thrown")
                return
            }
            switch error {
            case let .dataCorrupted(context):
                guard context.codingPath[0].stringValue == "enumKey" else {
                    XCTFail("Data Corrupted Error on unexpected field")
                    return
                }
                break
            default:
                XCTFail("Expect Data Corrupted Error thrown")
                return
            }
        }
    }
}
