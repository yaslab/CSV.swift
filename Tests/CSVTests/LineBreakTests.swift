//
//  LineBreakTests.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/11.
//  Copyright © 2016 yaslab. All rights reserved.
//

import CSV
import Testing

struct LineBreakTests {
    // Arrange
    @Test(arguments: [
        "abab,cdcd,efef\nzxcv,asdf,qwer",  // LF
        "abab,cdcd,efef\rzxcv,asdf,qwer",  // CR
        "abab,cdcd,efef\r\nzxcv,asdf,qwer",  // CRLF
    ])
    func test(csv: String) throws {
        // Act
        let records = try parse(csv: csv)

        // Assert
        try #require(records.count == 2)
        #expect(records[0] == ["abab", "cdcd", "efef"])
        #expect(records[1] == ["zxcv", "asdf", "qwer"])
    }

    // Arrange
    @Test(arguments: [
        "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\",\n",  // LF
        "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\",\r",  // CR
        "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\",\r\n",  // CRLF
    ])
    func testLastEmptyRow(csv: String) throws {
        // Act
        let records = try parse(csv: csv)

        // Assert
        try #require(records.count == 2)
        #expect(records[0] == ["abab", "", "cdcd", "efef"])
        #expect(records[1] == ["zxcv", "asdf", "qw\"er", ""])
    }

    @Test func testLFInQuotationMarks() throws {
        // Arrange
        let csv = "abab,,\"\rcdcd\n\",efef\r\nzxcv,asdf,\"qw\"\"er\",\n"

        // Act
        let records = try parse(csv: csv)

        // Assert
        try #require(records.count == 2)
        #expect(records[0] == ["abab", "", "\rcdcd\n", "efef"])
        #expect(records[1] == ["zxcv", "asdf", "qw\"er", ""])
    }

    // Arrange
    @Test(arguments: [
        "qwe,asd\nzxc,rty",  // LF
        "qwe,asd\rzxc,rty",  // CR
        "qwe,asd\r\nzxc,rty",  // CRLF
    ])
    func testLineBreak(csv: String) throws {
        // Act
        let records = try parse(csv: csv)

        // Assert
        try #require(records.count == 2)
        #expect(records[0] == ["qwe", "asd"])
        #expect(records[1] == ["zxc", "rty"])
    }

    // Arrange
    @Test(arguments: [
        "qwe,asd\n\nzxc,rty",  // LFLF
        "qwe,asd\r\rzxc,rty",  // CRCR
        "qwe,asd\r\n\r\nzxc,rty",  // CRLFCRLF
    ])
    func testLineBreakEmptyRow(csv: String) throws {
        // Act
        let records = try parse(csv: csv)

        // Assert
        try #require(records.count == 3)
        #expect(records[0] == ["qwe", "asd"])
        #expect(records[1] == [""])
        #expect(records[2] == ["zxc", "rty"])
    }
}

extension LineBreakTests {
    private func parse(csv: String) throws -> [[String]] {
        let reader = CSVReader(string: csv)
        return try reader.map { try $0.get().columns }
    }
}
