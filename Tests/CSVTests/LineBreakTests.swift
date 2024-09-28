//
//  LineBreakTests.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/11.
//  Copyright © 2016 yaslab. All rights reserved.
//

import Testing
import CSV

struct LineBreakTests {
    @Test func testLF() throws {
        // Arrange
        let csv = "abab,cdcd,efef\nzxcv,asdf,qwer"

        // Act
        let records = try parse(csv: csv)

        // Assert
        try #require(records.count == 2)
        #expect(records[0] == ["abab", "cdcd", "efef"])
        #expect(records[1] == ["zxcv", "asdf", "qwer"])
    }

    @Test func testCRLF() throws {
        // Arrange
        let csv = "abab,cdcd,efef\r\nzxcv,asdf,qwer"

        // Act
        let records = try parse(csv: csv)

        // Assert
        try #require(records.count == 2)
        #expect(records[0] == ["abab", "cdcd", "efef"])
        #expect(records[1] == ["zxcv", "asdf", "qwer"])
    }

    @Test func testLastCR() throws {
        // Arrange
        let csv = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\",\r"

        // Act
        let records = try parse(csv: csv)

        // Assert
        try #require(records.count == 2)
        #expect(records[0] == ["abab", "", "cdcd", "efef"])
        #expect(records[1] == ["zxcv", "asdf", "qw\"er", ""])
    }

    @Test func testLastCRLF() throws {
        // Arrange
        let csv = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\",\r\n"

        // Act
        let records = try parse(csv: csv)

        // Assert
        try #require(records.count == 2)
        #expect(records[0] == ["abab", "", "cdcd", "efef"])
        #expect(records[1] == ["zxcv", "asdf", "qw\"er", ""])
    }

    @Test func testLastLF() throws {
        // Arrange
        let csv = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\",\n"

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

    @Test func testLineBreakLF() throws {
        // Arrange
        let csv = "qwe,asd\nzxc,rty"

        // Act
        let records = try parse(csv: csv)

        // Assert
        try #require(records.count == 2)
        #expect(records[0] == ["qwe", "asd"])
        #expect(records[1] == ["zxc", "rty"])
    }

    @Test func testLineBreakCR() throws {
        // Arrange
        let csv = "qwe,asd\rzxc,rty"

        // Act
        let records = try parse(csv: csv)

        // Assert
        try #require(records.count == 2)
        #expect(records[0] == ["qwe", "asd"])
        #expect(records[1] == ["zxc", "rty"])
    }

    @Test func testLineBreakCRLF() throws {
        // Arrange
        let csv = "qwe,asd\r\nzxc,rty"

        // Act
        let records = try parse(csv: csv)

        // Assert
        try #require(records.count == 2)
        #expect(records[0] == ["qwe", "asd"])
        #expect(records[1] == ["zxc", "rty"])
    }

    @Test func testLineBreakLFLF() throws {
        // Arrange
        let csv = "qwe,asd\n\nzxc,rty"

        // Act
        let records = try parse(csv: csv)

        // Assert
        try #require(records.count == 3)
        #expect(records[0] == ["qwe", "asd"])
        #expect(records[1] == [""])
        #expect(records[2] == ["zxc", "rty"])
    }

    @Test func testLineBreakCRCR() throws {
        // Arrange
        let csv = "qwe,asd\r\rzxc,rty"

        // Act
        let records = try parse(csv: csv)

        // Assert
        try #require(records.count == 3)
        #expect(records[0] == ["qwe", "asd"])
        #expect(records[1] == [""])
        #expect(records[2] == ["zxc", "rty"])
    }

    @Test func testLineBreakCRLFCRLF() throws {
        // Arrange
        let csv = "qwe,asd\r\n\r\nzxc,rty"

        // Act
        let records = try parse(csv: csv)

        // Assert
        try #require(records.count == 3)
        #expect(records[0] == ["qwe", "asd"])
        #expect(records[1] == [""])
        #expect(records[2] == ["zxc", "rty"])
    }

    private func parse(csv: String) throws -> [[String]] {
        let reader = CSVReader(string: csv)
        return try reader.map { try $0.get().columns }
    }
}
