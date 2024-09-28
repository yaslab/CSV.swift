//
//  UnicodeTests.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/10/18.
//  Copyright © 2016 yaslab. All rights reserved.
//

import Testing
import CSV
import Foundation

struct UnicodeTests {
    @Test func utf8WithBOM() throws {
        // Arrange
        let csv = "abab,,cdcd,efef\r\nzxcv,asdf,\"qw\"\"er\","
        var data = Data([0xef, 0xbb, 0xbf])  // UTF-8 BOM
        data.append(contentsOf: csv.utf8)

        let rows = try withTempURL { url in
            try data.write(to: url)
            let reader = CSVReader(url: url)

            // Act
            return try reader.map { try $0.get().columns }
        }

        // Assert
        try #require(rows.count == 2)
        #expect(rows[0] == ["abab", "", "cdcd", "efef"])
        #expect(rows[1] == ["zxcv", "asdf", "qw\"er", ""])
    }
}
