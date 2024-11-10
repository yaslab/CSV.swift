//
//  CSVReaderConfiguration.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2024/07/16.
//  Copyright © 2024 yaslab. All rights reserved.
//

public struct CSVReaderConfiguration: Sendable {
    public var hasHeaderRow: Bool
    public var trimFields: Bool
    public var delimiter: UTF8.CodeUnit
    public var whitespaces: Set<UTF8.CodeUnit>

    func copy() -> CSVReaderConfiguration {
        var whitespaces = whitespaces
        if whitespaces.contains(delimiter) {
            whitespaces.remove(delimiter)
        }

        return CSVReaderConfiguration(
            hasHeaderRow: hasHeaderRow,
            trimFields: trimFields,
            delimiter: delimiter,
            whitespaces: whitespaces
        )
    }
}
