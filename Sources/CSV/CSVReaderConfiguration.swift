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
}

extension CSVReaderConfiguration {
    public static func `default`(
        hasHeaderRow: Bool = false,
        trimFields: Bool = false,
        whitespaces: Set<UTF8.CodeUnit> = [.horizontalTabulation, .space, .noBreakSpace]
    ) -> CSVReaderConfiguration {
        return CSVReaderConfiguration(
            hasHeaderRow: hasHeaderRow,
            trimFields: trimFields,
            delimiter: .comma,
            whitespaces: whitespaces
        )
    }

    public static func tsv(
        hasHeaderRow: Bool = false,
        trimFields: Bool = false,
        whitespaces: Set<UTF8.CodeUnit> = [.horizontalTabulation, .space, .noBreakSpace]
    ) -> CSVReaderConfiguration {
        return CSVReaderConfiguration(
            hasHeaderRow: hasHeaderRow,
            trimFields: trimFields,
            delimiter: .horizontalTabulation,
            whitespaces: whitespaces
        )
    }
}

extension CSVReaderConfiguration {
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
