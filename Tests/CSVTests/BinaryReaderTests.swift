//
//  BinaryReaderTests.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2018/11/15.
//  Copyright © 2018 yaslab. All rights reserved.
//

import XCTest
@testable import CSV

class BinaryReaderTests: XCTestCase {

    static let allTests = [
        ("testReadUInt8WithSmallBuffer", testReadUInt8WithSmallBuffer),
        ("testReadUInt16BEWithSmallBuffer", testReadUInt16BEWithSmallBuffer),
        ("testReadUInt16LEWithSmallBuffer", testReadUInt16LEWithSmallBuffer),
        ("testReadUInt32BEWithSmallBuffer", testReadUInt32BEWithSmallBuffer),
        ("testReadUInt32LEWithSmallBuffer", testReadUInt32LEWithSmallBuffer)
    ]

    private func random(_ count: Int) -> [UInt8] {
        var array = [UInt8]()
        for _ in 0 ..< count {
            array.append(UInt8.random(in: .min ... .max))
        }
        return array
    }

    func testReadUInt8WithSmallBuffer() {
        let bytes = random(100)
        let stream = InputStream(data: Data(bytes: bytes))

        do {
            let reader = try BinaryReader(stream: stream, endian: .unknown, closeOnDeinit: true, bufferSize: 7)
            for expected in bytes {
                let actual = try reader.readUInt8()
                XCTAssertEqual(actual, expected)
            }
        } catch {
            XCTFail("\(error)")
        }
    }

    func testReadUInt16BEWithSmallBuffer() {
        let bytes = random(100)
        let stream = InputStream(data: Data(bytes: bytes))

        do {
            let reader = try BinaryReader(stream: stream, endian: .big, closeOnDeinit: true, bufferSize: 7)
            for i in stride(from: 0, to: bytes.count, by: 2) {
                let expected = (UInt16(bytes[i]) << 8) + UInt16(bytes[i + 1])
                let actual = try reader.readUInt16()
                XCTAssertEqual(actual, expected)
            }
        } catch {
            XCTFail("\(error)")
        }
    }

    func testReadUInt16LEWithSmallBuffer() {
        let bytes = random(100)
        let stream = InputStream(data: Data(bytes: bytes))

        do {
            let reader = try BinaryReader(stream: stream, endian: .little, closeOnDeinit: true, bufferSize: 7)
            for i in stride(from: 0, to: bytes.count, by: 2) {
                let expected = UInt16(bytes[i]) + (UInt16(bytes[i + 1]) << 8)
                let actual = try reader.readUInt16()
                XCTAssertEqual(actual, expected)
            }
        } catch {
            XCTFail("\(error)")
        }
    }

    func testReadUInt32BEWithSmallBuffer() {
        let bytes = random(100)
        let stream = InputStream(data: Data(bytes: bytes))

        do {
            let reader = try BinaryReader(stream: stream, endian: .big, closeOnDeinit: true, bufferSize: 7)
            for i in stride(from: 0, to: bytes.count, by: 4) {
                let expected =
                    (UInt32(bytes[i    ]) << 24) + (UInt32(bytes[i + 1]) << 16) +
                    (UInt32(bytes[i + 2]) <<  8) + (UInt32(bytes[i + 3])      )
                let actual = try reader.readUInt32()
                XCTAssertEqual(actual, expected)
            }
        } catch {
            XCTFail("\(error)")
        }
    }

    func testReadUInt32LEWithSmallBuffer() {
        let bytes = random(100)
        let stream = InputStream(data: Data(bytes: bytes))

        do {
            let reader = try BinaryReader(stream: stream, endian: .little, closeOnDeinit: true, bufferSize: 7)
            for i in stride(from: 0, to: bytes.count, by: 4) {
                let expected =
                    (UInt32(bytes[i    ])      ) + (UInt32(bytes[i + 1]) <<  8) +
                    (UInt32(bytes[i + 2]) << 16) + (UInt32(bytes[i + 3]) << 24)
                let actual = try reader.readUInt32()
                XCTAssertEqual(actual, expected)
            }
        } catch {
            XCTFail("\(error)")
        }
    }

}
