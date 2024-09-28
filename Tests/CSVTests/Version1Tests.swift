//
//  Version1Tests.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2017/06/18.
//  Copyright © 2017 yaslab. All rights reserved.
//

import CSV
import Foundation
import XCTest

class Version1Tests: XCTestCase {

    // func testV1() {
    //     let str = "a,b,c\n1,2,3"
    //     let data8 = str.data(using: .utf8)!
    //     let data16 = str.data(using: .utf16BigEndian)!
    //     let data32 = str.data(using: .utf32BigEndian)!

    //     let headerRow = ["a", "b", "c"]
    //     let row = ["1", "2", "3"]

    //     do {
    //         let stream = InputStream(data: data8)
    //         let csv = try CSVReader(stream: stream,
    //                           codecType: UTF8.self,
    //                           hasHeaderRow: true,
    //                           trimFields: false,
    //                           delimiter: ",")
    //         XCTAssertEqual(csv.headerRow!, headerRow)
    //         XCTAssertEqual(csv.next()!, row)
    //         XCTAssertEqual(csv["a"], row[0])
    //     } catch {
    //         fatalError()
    //     }

    //     do {
    //         let stream = InputStream(data: data16)
    //         let csv = try CSVReader(stream: stream,
    //                           codecType: UTF16.self,
    //                           endian: .big,
    //                           hasHeaderRow: true,
    //                           trimFields: false,
    //                           delimiter: ",")
    //         XCTAssertEqual(csv.headerRow!, headerRow)
    //         XCTAssertEqual(csv.next()!, row)
    //         XCTAssertEqual(csv["a"], row[0])
    //     } catch {
    //         fatalError()
    //     }

    //     do {
    //         let stream = InputStream(data: data32)
    //         let csv = try CSVReader(stream: stream,
    //                           codecType: UTF32.self,
    //                           endian: .big,
    //                           hasHeaderRow: true,
    //                           trimFields: false,
    //                           delimiter: ",")
    //         XCTAssertEqual(csv.headerRow!, headerRow)
    //         XCTAssertEqual(csv.next()!, row)
    //         XCTAssertEqual(csv["a"], row[0])
    //     } catch {
    //         fatalError()
    //     }

    //     do {
    //         let stream = InputStream(data: data8)
    //         let csv = try CSVReader(stream: stream,
    //                           hasHeaderRow: true,
    //                           trimFields: false,
    //                           delimiter: ",")
    //         XCTAssertEqual(csv.headerRow!, headerRow)
    //         XCTAssertEqual(csv.next()!, row)
    //         XCTAssertEqual(csv["a"], row[0])
    //     } catch {
    //         fatalError()
    //     }

    //     do {
    //         let csv = try CSVReader(string: str,
    //                           hasHeaderRow: true,
    //                           trimFields: false,
    //                           delimiter: ",")
    //         XCTAssertEqual(csv.headerRow!, headerRow)
    //         XCTAssertEqual(csv.next()!, row)
    //         XCTAssertEqual(csv["a"], row[0])
    //     } catch {
    //         fatalError()
    //     }

    //     _ = CSVError.cannotOpenFile
    //     _ = CSVError.cannotReadFile
    //     _ = CSVError.streamErrorHasOccurred(error: NSError(domain: "", code: 0, userInfo: nil))
    //     _ = CSVError.cannotReadHeaderRow
    //     _ = CSVError.stringEncodingMismatch
    //     _ = CSVError.stringEndianMismatch

    //     _ = Endian.big
    //     _ = Endian.little
    //     _ = Endian.unknown
    // }

}
