//
//  CSVReaderConfiguration.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2024/07/16.
//  Copyright © 2024 yaslab. All rights reserved.
//

public struct CSVReaderConfiguration: Sendable {
    public var delimiter: UTF8.CodeUnit
    public var hasHeaderRow: Bool
    public var trimFields: Bool
    public var whitespaces: Set<UTF8.CodeUnit>
}

extension CSVReaderConfiguration {
    public static func csv(
        hasHeaderRow: Bool = false,
        trimFields: Bool = false,
        whitespaces: Set<UTF8.CodeUnit> = [.horizontalTabulation, .space, .noBreakSpace]
    ) -> CSVReaderConfiguration {
        return CSVReaderConfiguration(
            delimiter: .comma,
            hasHeaderRow: hasHeaderRow,
            trimFields: trimFields,
            whitespaces: whitespaces
        )
    }

    public static func tsv(
        hasHeaderRow: Bool = false,
        trimFields: Bool = false,
        whitespaces: Set<UTF8.CodeUnit> = [.horizontalTabulation, .space, .noBreakSpace]
    ) -> CSVReaderConfiguration {
        return CSVReaderConfiguration(
            delimiter: .horizontalTabulation,
            hasHeaderRow: hasHeaderRow,
            trimFields: trimFields,
            whitespaces: whitespaces
        )
    }

    public static func custom(
        delimiter: UTF8.CodeUnit,
        hasHeaderRow: Bool = false,
        trimFields: Bool = false,
        whitespaces: Set<UTF8.CodeUnit> = [.horizontalTabulation, .space, .noBreakSpace]
    ) -> CSVReaderConfiguration {
        return CSVReaderConfiguration(
            delimiter: delimiter,
            hasHeaderRow: hasHeaderRow,
            trimFields: trimFields,
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
            delimiter: delimiter,
            hasHeaderRow: hasHeaderRow,
            trimFields: trimFields,
            whitespaces: whitespaces
        )
    }
}
