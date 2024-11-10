//
//  TrimFieldsTests.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/10/18.
//  Copyright © 2016 yaslab. All rights reserved.
//

import CSV
import Testing

struct TrimFieldsTests {
    // Arrange
    @Test(arguments: [
        "abc,def,ghi",
        " abc,  def,   ghi",
        "abc ,def  ,ghi   ",
        " abc ,  def  ,   ghi   ",
        "\"abc\",\"def\",\"ghi\"",
        " \"abc\",  \"def\",   \"ghi\"",
        "\"abc\" ,\"def\"  ,\"ghi\"   ",
        " \"abc\" ,  \"def\"  ,   \"ghi\"   ",
        "\tabc,\t\tdef\t,ghi\t",
    ])
    func trimOneRow(csv: String) throws {
        // Arrange
        let reader = CSVReader(string: csv, trimFields: true)

        // Act
        let rows = try reader.map { try $0.get().columns }

        // Assert
        try #require(rows.count == 1)
        #expect(rows[0] == ["abc", "def", "ghi"])
    }

    // Arrange
    @Test(arguments: [
        ("\" abc \",\" def \",\" ghi \"", [[" abc ", " def ", " ghi "]]),
        (" abc \n def ", [["abc"], ["def"]]),
        (" \"abc \" \n \" def\" ", [["abc "], [" def"]]),
        ("", []),
        (" ", [[""]]),
        (" , ", [["", ""]]),
        (" , \n", [["", ""]]),
        (" , \n ", [["", ""], [""]]),
    ])
    func trimTwoRows(argument: (csv: String, expected: [[String]])) throws {
        // Arrange
        let reader = CSVReader(string: argument.csv, trimFields: true)

        // Act
        let rows = try reader.map { try $0.get().columns }

        // Assert
        #expect(rows == argument.expected)
    }

    @Test func trimTSV() throws {
        // Arrange
        let tsv = " abc \t\tdef\t ghi "
        let reader = CSVReader(string: tsv, trimFields: true, delimiter: .horizontalTabulation)

        // Act
        let rows = try reader.map { try $0.get().columns }

        // Assert
        try #require(rows.count == 1)
        #expect(rows[0] == ["abc", "", "def", "ghi"])
    }
}
