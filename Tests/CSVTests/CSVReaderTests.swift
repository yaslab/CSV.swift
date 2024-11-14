//
//  CSVReaderTests.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/11.
//  Copyright © 2016 yaslab. All rights reserved.
//

import CSV
import Foundation
import Testing

struct CSVReaderTests {
    @Test
    func testOneLine() throws {
        // Arrange
        let csv = "\"abc\",1,2"
        let reader = CSVReader(string: csv)

        // Act
        let rows = try reader.map { try $0.get().columns }

        // Assert
        try #require(rows.count == 1)
        #expect(rows[0] == ["abc", "1", "2"])
    }

    @Test
    func testTwoLines() throws {
        // Arrange
        let csv = "\"abc\",1,2\n\"cde\",3,4"
        let reader = CSVReader(string: csv)

        // Act
        let rows = try reader.map { try $0.get().columns }

        // Assert
        try #require(rows.count == 2)
        #expect(rows[0] == ["abc", "1", "2"])
        #expect(rows[1] == ["cde", "3", "4"])
    }

    @Test
    func testLastLineIsEmpty() throws {
        // Arrange
        let csv = "\"abc\",1,2\n\"cde\",3,4\n"
        let reader = CSVReader(string: csv)

        // Act
        let rows = try reader.map { try $0.get().columns }

        // Assert
        try #require(rows.count == 2)
        #expect(rows[0] == ["abc", "1", "2"])
        #expect(rows[1] == ["cde", "3", "4"])
    }

    @Test
    func testLastLineIsWhiteSpace() throws {
        // Arrange
        let csv = "\"abc\",1,2\n\"cde\",3,4\n "
        let reader = CSVReader(string: csv)

        // Act
        let rows = try reader.map { try $0.get().columns }

        // Assert
        try #require(rows.count == 3)
        #expect(rows[0] == ["abc", "1", "2"])
        #expect(rows[1] == ["cde", "3", "4"])
        #expect(rows[2] == [" "])
    }

    @Test
    func testMiddleLineIsEmpty() throws {
        // Arrange
        let csv = "\"abc\",1,2\n\n\"cde\",3,4"
        let reader = CSVReader(string: csv)

        // Act
        let rows = try reader.map { try $0.get().columns }

        // Assert
        try #require(rows.count == 3)
        #expect(rows[0] == ["abc", "1", "2"])
        #expect(rows[1] == [""])
        #expect(rows[2] == ["cde", "3", "4"])
    }

    @Test
    func testCommaInQuotationMarks() throws {
        // Arrange
        let csv = "abab,\"cd,cd\",efef"
        let reader = CSVReader(string: csv)

        // Act
        let rows = try reader.map { try $0.get().columns }

        // Assert
        try #require(rows.count == 1)
        #expect(rows[0] == ["abab", "cd,cd", "efef"])
    }

    @Test
    func testEscapedQuotationMark1() throws {
        // Arrange
        let csv = "abab,\"\"\"cdcd\",efef\r\nzxcv,asdf,qwer"
        let reader = CSVReader(string: csv)

        // Act
        let rows = try reader.map { try $0.get().columns }

        // Assert
        try #require(rows.count == 2)
        #expect(rows[0] == ["abab", "\"cdcd", "efef"])
        #expect(rows[1] == ["zxcv", "asdf", "qwer"])
    }

    @Test
    func testEscapedQuotationMark2() throws {
        // Arrange
        let csv = "abab,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\""
        let reader = CSVReader(string: csv)

        // Act
        let rows = try reader.map { try $0.get().columns }

        // Assert
        try #require(rows.count == 2)
        #expect(rows[0] == ["abab", "cdcd", "efef"])
        #expect(rows[1] == ["zxcv", "asdf", "qw\"er"])
    }

    @Test
    func testEmptyField() throws {
        // Arrange
        let csv = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\","
        let reader = CSVReader(string: csv)

        // Act
        let rows = try reader.map { try $0.get().columns }

        // Assert
        try #require(rows.count == 2)
        #expect(rows[0] == ["abab", "", "cdcd", "efef"])
        #expect(rows[1] == ["zxcv", "asdf", "qw\"er", ""])
    }

    @Test
    func testDoubleQuoteBeforeLineBreak1() throws {
        // Arrange
        let csv = "\"abc\",1,\"2\"\n\n\"cde\",3,\"4\""
        let reader = CSVReader(string: csv)

        // Act
        let rows = try reader.map { try $0.get().columns }

        // Assert
        try #require(rows.count == 3)
        #expect(rows[0] == ["abc", "1", "2"])
        #expect(rows[1] == [""])
        #expect(rows[2] == ["cde", "3", "4"])
    }

    @Test
    func testDoubleQuoteBeforeLineBreak2() throws {
        // Arrange
        let csv = "\"abc\",1,\"2\"\r\n\"cde\",3,\"4\"\r"
        let reader = CSVReader(string: csv)

        // Act
        let rows = try reader.map { try $0.get().columns }

        // Assert
        try #require(rows.count == 2)
        #expect(rows[0] == ["abc", "1", "2"])
        #expect(rows[1] == ["cde", "3", "4"])
    }

    @Test
    func testCSVState1() throws {
        // Arrange
        let csv = "あ,い1,\"う\",えお\n,,x,"
        let data = try #require(csv.data(using: .utf8))
        let reader = CSVReader(data: data)

        // Act
        let rows = try reader.map { try $0.get().columns }

        // Assert
        try #require(rows.count == 2)
        #expect(rows[0] == ["あ", "い1", "う", "えお"])
        #expect(rows[1] == ["", "", "x", ""])
    }

    @Test
    func testSubscriptInt() throws {
        // Arrange
        let csv = "a,bb,ccc"
        let reader = CSVReader(string: csv)

        // Act
        let rows = try reader.map { try $0.get() }

        // Assert
        try #require(rows.count == 1)
        let row: CSVRow = rows[0]
        #expect(row[0] == "a")
        #expect(row[1] == "bb")
        #expect(row[2] == "ccc")
    }

    @Test
    func testHasHeaderRow1() throws {
        // Arrange
        let csv = "key1,key2\nvalue1,value2"
        var reader = CSVReader(string: csv)
        reader.configuration.hasHeaderRow = true

        // Act
        let rows = try reader.map { try $0.get() }

        // Assert
        try #require(rows.count == 1)
        let row: CSVRow = rows[0]
        #expect(row.header == ["key1", "key2"])
        #expect(row.columns == ["value1", "value2"])
    }

    @Test(arguments: [
        "key1,key2\n",
        "key1,key2",
    ])
    func testHasHeaderRow2(csv: String) throws {
        // Arrange
        var reader = CSVReader(string: csv)
        reader.configuration.hasHeaderRow = true

        // Act
        let rows = try reader.map { try $0.get() }

        // Assert
        #expect(rows.isEmpty)
    }

    @Test
    func testHasHeaderRow4() throws {
        // Arrange
        let csv = ""
        var reader = CSVReader(string: csv)
        reader.configuration.hasHeaderRow = true

        #expect {
            // Act
            try reader.map { try $0.get() }
        } throws: {
            // Assert
            guard let error = $0 as? CSVError else {
                return false
            }
            guard case .cannotReadHeaderRow = error else {
                return false
            }
            return true
        }
    }

    @Test
    func testSubscript1() throws {
        // Arrange
        let csv = "key1,key2\nvalue1,value2"
        var reader = CSVReader(string: csv)
        reader.configuration.hasHeaderRow = true

        // Act
        let rows = try reader.map { try $0.get() }

        // Assert
        try #require(rows.count == 1)
        let row: CSVRow = rows[0]
        #expect(row["key1"] == "value1")
        #expect(row["key2"] == "value2")
        #expect(row["key9"] == nil)
    }

    @Test
    func testSubscript2() throws {
        // Arrange
        let csv = "key1,key2\nvalue1"
        var reader = CSVReader(string: csv)
        reader.configuration.hasHeaderRow = true

        // Act
        let rows = try reader.map { try $0.get() }

        // Assert
        try #require(rows.count == 1)
        let row: CSVRow = rows[0]
        #expect(row["key1"] == "value1")
        #expect(row["key2"] == "")
        #expect(row["key9"] == nil)
    }

    @Test
    func testToArray() throws {
        // Arrange
        let csv = "1,2,3,4,5\n6,7,8,9,0"
        let reader = CSVReader(string: csv)

        do {
            // Act
            let rows = try reader.map { try $0.get().columns }

            // Assert
            try #require(rows.count == 2)
            #expect(rows[0] == ["1", "2", "3", "4", "5"])
            #expect(rows[1] == ["6", "7", "8", "9", "0"])
        }

        do {
            // Act
            let rows = try reader.map { try $0.get().columns }

            // Assert
            try #require(rows.count == 2)
            #expect(rows[0] == ["1", "2", "3", "4", "5"])
            #expect(rows[1] == ["6", "7", "8", "9", "0"])
        }
    }
}
