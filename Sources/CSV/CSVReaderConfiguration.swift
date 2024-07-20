//
//  CSVReaderConfiguration.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2024/07/16.
//  Copyright © 2024 yaslab. All rights reserved.
//

import Foundation

public struct CSVReaderConfiguration: Sendable {
    public var hasHeaderRow: Bool
    public var trim: Bool
    public var delimiter: UTF8.CodeUnit
    public var whitespaces: Set<UTF8.CodeUnit>

    public init(
        hasHeaderRow: Bool = false,
        trim: Bool = false,
        delimiter: UTF8.CodeUnit = .comma,
        whitespaces: Set<UTF8.CodeUnit> = [.horizontalTabulation, .space, .noBreakSpace]
    ) {
        self.hasHeaderRow = hasHeaderRow
        self.trim = trim
        self.delimiter = delimiter
        self.whitespaces = whitespaces
    }

    func copy() -> CSVReaderConfiguration {
        var whitespaces = whitespaces
        if whitespaces.contains(delimiter) {
            whitespaces.remove(delimiter)
        }

        return CSVReaderConfiguration(
            hasHeaderRow: hasHeaderRow,
            trim: trim,
            delimiter: delimiter,
            whitespaces: whitespaces
        )
    }
}
