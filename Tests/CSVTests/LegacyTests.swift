//
//  LegacyTests.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2024/11/11.
//  Copyright © 2024年 yaslab. All rights reserved.
//

import CSV
import Foundation
import Testing

struct LegacyTests {
    @Test func testCSV() throws {
        // Note: deprecated

        // _ = try CSV(string: "")
    }

    @Test func testInit() throws {
        // Note: unavailable

        // let stream = InputStream()
        // _ = try CSVReader(stream: stream)
        // _ = try CSVReader(stream: stream, hasHeaderRow: false, trimFields: false, delimiter: ",", whitespaces: .whitespaces)
        // _ = try CSVReader(stream: stream, codecType: UTF8.self)
        // _ = try CSVReader(stream: stream, codecType: UTF8.self, hasHeaderRow: false, trimFields: false, delimiter: ",", whitespaces: .whitespaces)
        // _ = try CSVReader(stream: stream, codecType: UTF16.self)
        // _ = try CSVReader(stream: stream, codecType: UTF32.self)
    }

    @Test func testProperty() {
        // Note: unavailable

        // let reader = CSVReader(string: "")
        // _ = reader.headerRow
        // _ = reader.currentRow
        // _ = reader.error
        // _ = reader[""]
    }
}
