//
//  BinaryReaderTests.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2018/11/15.
//  Copyright © 2018 yaslab. All rights reserved.
//

import Foundation
import Testing

@testable import CSV

struct BinaryReaderTests {
    @Test(arguments: [0, 1, 9, 10, 11, 19, 20, 21])
    func read(count: Int) throws {
        // Arrange
        let bytes = Utils.random(count)

        let read = try Utils.withTempURL { url in
            try Data(bytes).write(to: url)
            let reader = BinaryReader(url: url, bufferSize: 10)

            // Act
            return try reader.map { try $0.get() }
        }

        // Assert
        #expect(read == bytes)
    }

    @Test(arguments: [-1, 0, 7, 8, 9])
    func bufferSize(size: Int) throws {
        // Arrange
        let bytes = Utils.random(10)

        try Utils.withTempURL { url in
            try Data(bytes).write(to: url)
            let reader = BinaryReader(url: url, bufferSize: size)

            // Act
            let it = reader.makeIterator()

            // Assert
            #expect(it.bufferSize == (size < 8 ? 8 : size))
        }
    }
}
