//
//  CSVConfiguration.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/10/22.
//  Copyright © 2016 yaslab. All rights reserved.
//

import Foundation

internal let defaultHasHeaderRow = false
internal let defaultTrimFields = false
internal let defaultDelimiter = UnicodeScalar(UInt8(0x2c)) // ","
internal let defaultWhitespaces = CharacterSet.whitespaces

// TODO: Documentation
/// No overview available.
public struct CSVConfiguration {

    /// `true` if the CSV has a header row, otherwise `false`. Default: `false`.
    public let hasHeaderRow: Bool
    /// No overview available.
    public let trimFields: Bool
    /// Default: `","`.
    public let delimiter: UnicodeScalar
    /// No overview available.
    public let whitespaces: CharacterSet

    /// No overview available.
    public init(
        hasHeaderRow: Bool = defaultHasHeaderRow,
        trimFields: Bool = defaultTrimFields,
        delimiter: UnicodeScalar = defaultDelimiter,
        whitespaces: CharacterSet = defaultWhitespaces) {

        self.hasHeaderRow = hasHeaderRow
        self.trimFields = trimFields
        self.delimiter = delimiter

        var whitespaces = whitespaces
        _ = whitespaces.remove(delimiter)
        self.whitespaces = whitespaces
    }

}
