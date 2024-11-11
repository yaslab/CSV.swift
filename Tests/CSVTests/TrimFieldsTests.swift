//
//  TrimFieldsTests.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/10/18.
//  Copyright © 2016 yaslab. All rights reserved.
//

import CSV
import Foundation
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
        (
            csv: "\" abc \",\" def \",\" ghi \"",
            expected: [[" abc ", " def ", " ghi "]]
        ),
        (
            csv: " abc \n def ",
            expected: [["abc"], ["def"]]
        ),
        (
            csv: " \"abc \" \n \" def\" ",
            expected: [["abc "], [" def"]]
        ),
        (
            csv: "",
            expected: []
        ),
        (
            csv: " ",
            expected: [[""]]
        ),
        (
            csv: " , ",
            expected: [["", ""]]
        ),
        (
            csv: " , \n",
            expected: [["", ""]]
        ),
        (
            csv: " , \n ",
            expected: [["", ""], [""]]
        ),
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
