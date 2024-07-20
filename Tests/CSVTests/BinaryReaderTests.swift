//
//  BinaryReaderTests.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2018/11/15.
//  Copyright © 2018 yaslab. All rights reserved.
//

import Testing
import Foundation

@testable import CSV

struct BinaryReaderTests {
    private func random(_ count: Int) -> [UInt8] {
        var array = [UInt8]()
        for _ in 0 ..< count {
            array.append(UInt8.random(in: .min ... .max))
        }
        return array
    }

    @Test func testReadUInt8WithSmallBuffer() throws {
        try withTempURL { url in
            let bytes = [0xcc] + random(99)
            try Data(bytes).write(to: url)

            let reader = BinaryReader(url: url, bufferSize: 11)
            for (expected, result) in zip(bytes, reader) {
                let actual = try result.get()
                #expect(actual == expected)
            }
        }
    }

}
