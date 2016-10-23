//
//  CSV.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/11.
//  Copyright © 2016 yaslab. All rights reserved.
//

import Foundation

private let LF = UnicodeScalar(UInt8(0x0a))     // "\n"
private let CR = UnicodeScalar(UInt8(0x0d))     // "\r"
private let DQUOTE = UnicodeScalar(UInt8(0x22)) // "\""

/// No overview available.
public struct CSV {

    private var iterator: AnyIterator<UnicodeScalar>
    private let config: CSVConfiguration

    private var back: UnicodeScalar? = nil

    /// CSV header row. To set a value for this property,
    /// you set `true` to `hasHeaerRow` in initializer.
    public private(set) var headerRow: [String]? = nil

    internal init<T: IteratorProtocol>(
        iterator: T,
        config: CSVConfiguration
        ) throws where T.Element == UnicodeScalar {

        self.iterator = AnyIterator(iterator)
        self.config = config

        if config.hasHeaderRow {
            guard let headerRow = readRow() else {
                throw CSVError.cannotReadHeaderRow
            }
            self.headerRow = headerRow
        }
    }

    /// Create an instance with `InputStream`.
    ///
    /// - parameter stream: An `InputStream` object. If the stream is not open,
    ///                     initializer opens automatically.
    /// - parameter codecType: A `UnicodeCodec` type for `stream`.
    /// - parameter config: CSV configuration.
    public init<T: UnicodeCodec>(
        stream: InputStream,
        codecType: T.Type,
        config: CSVConfiguration = CSVConfiguration()
        ) throws where T.CodeUnit == UInt8 {

        let reader = try BinaryReader(stream: stream, endian: .unknown, closeOnDeinit: true)
        let iterator = UnicodeIterator(
            input: reader.makeUInt8Iterator(),
            inputEncodingType: codecType
        )
        try self.init(iterator: iterator, config: config)
    }

    /// Create an instance with `InputStream`.
    ///
    /// - parameter stream: An `InputStream` object. If the stream is not open,
    ///                     initializer opens automatically.
    /// - parameter codecType: A `UnicodeCodec` type for `stream`.
    /// - parameter endian: Endian to use when reading a stream. Default: `.big`.
    /// - parameter config: CSV configuration.
    public init<T: UnicodeCodec>(
        stream: InputStream,
        codecType: T.Type,
        endian: Endian = .big,
        config: CSVConfiguration = CSVConfiguration()
        ) throws where T.CodeUnit == UInt16 {

        let reader = try BinaryReader(stream: stream, endian: endian, closeOnDeinit: true)
        let iterator = UnicodeIterator(
            input: reader.makeUInt16Iterator(),
            inputEncodingType: codecType
        )
        try self.init(iterator: iterator, config: config)
    }

    /// Create an instance with `InputStream`.
    ///
    /// - parameter stream: An `InputStream` object. If the stream is not open,
    ///                     initializer opens automatically.
    /// - parameter codecType: A `UnicodeCodec` type for `stream`.
    /// - parameter endian: Endian to use when reading a stream. Default: `.big`.
    /// - parameter config: CSV configuration.
    public init<T: UnicodeCodec>(
        stream: InputStream,
        codecType: T.Type,
        endian: Endian = .big,
        config: CSVConfiguration = CSVConfiguration()
        ) throws where T.CodeUnit == UInt32 {

        let reader = try BinaryReader(stream: stream, endian: endian, closeOnDeinit: true)
        let iterator = UnicodeIterator(
            input: reader.makeUInt32Iterator(),
            inputEncodingType: codecType
        )
        try self.init(iterator: iterator, config: config)
    }

    // MARK: - Parse CSV

    internal mutating func readRow() -> [String]? {
        var c = moveNext()
        if c == nil {
            return nil
        }

        var row = [String]()
        var field: String
        var end: Bool
        while true {
            if config.trimFields {
                // Trim the leading spaces
                while c != nil && config.whitespaces.contains(c!) {
                    c = moveNext()
                }
            }

            if c == nil {
                (field, end) = ("", true)
            } else if c == DQUOTE {
                (field, end) = readField(quoted: true)
            } else {
                back = c
                (field, end) = readField(quoted: false)

                if config.trimFields {
                    // Trim the trailing spaces
                    field = field.trimmingCharacters(in: config.whitespaces)
                }
            }
            row.append(field)
            if end {
                break
            }
            c = moveNext()
        }

        return row
    }

    private mutating func readField(quoted: Bool) -> (String, Bool) {
        var field = ""

        while let c = moveNext() {
            if quoted {
                if c == DQUOTE {
                    var cNext = moveNext()

                    if config.trimFields {
                        // Trim the trailing spaces
                        while cNext != nil && config.whitespaces.contains(cNext!) {
                            cNext = moveNext()
                        }
                    }

                    if cNext == nil || cNext == CR || cNext == LF {
                        if cNext == CR {
                            let cNextNext = moveNext()
                            if cNextNext != LF {
                                back = cNextNext
                            }
                        }
                        // END ROW
                        return (field, true)
                    } else if cNext == config.delimiter {
                        // END FIELD
                        return (field, false)
                    } else if cNext == DQUOTE {
                        // ESC
                        field.append(String(DQUOTE))
                    } else {
                        // ERROR?
                        field.append(String(c))
                    }
                } else {
                    field.append(String(c))
                }
            } else {
                if c == CR || c == LF {
                    if c == CR {
                        let cNext = moveNext()
                        if cNext != LF {
                            back = cNext
                        }
                    }
                    // END ROW
                    return (field, true)
                } else if c == config.delimiter {
                    // END FIELD
                    return (field, false)
                } else {
                    field.append(String(c))
                }
            }
        }

        // END FILE
        return (field, true)
    }

    private mutating func moveNext() -> UnicodeScalar? {
        if back != nil {
            defer {
                back = nil
            }
            return back
        }
        return iterator.next()
    }

}

extension CSV {

    /// Unavailable.
    @available(*, unavailable, message: "Use init(stream:codecType:config:) instead")
    public init<T: UnicodeCodec>(
        stream: InputStream,
        codecType: T.Type,
        hasHeaderRow: Bool = defaultHasHeaderRow,
        trimFields: Bool = defaultTrimFields,
        delimiter: UnicodeScalar = defaultDelimiter
        ) throws where T.CodeUnit == UInt8 {

        let reader = try BinaryReader(stream: stream, endian: .unknown, closeOnDeinit: true)
        let iterator = UnicodeIterator(
            input: reader.makeUInt8Iterator(),
            inputEncodingType: codecType
        )
        let config = CSVConfiguration(
            hasHeaderRow: hasHeaderRow,
            trimFields: trimFields,
            delimiter: delimiter
        )
        try self.init(iterator: iterator, config: config)
    }

    /// Unavailable.
    @available(*, unavailable, message: "Use init(stream:codecType:endian:config:) instead")
    public init<T: UnicodeCodec>(
        stream: InputStream,
        codecType: T.Type,
        endian: Endian = .big,
        hasHeaderRow: Bool = defaultHasHeaderRow,
        trimFields: Bool = defaultTrimFields,
        delimiter: UnicodeScalar = defaultDelimiter
        ) throws where T.CodeUnit == UInt16 {

        let reader = try BinaryReader(stream: stream, endian: endian, closeOnDeinit: true)
        let iterator = UnicodeIterator(
            input: reader.makeUInt16Iterator(),
            inputEncodingType: codecType
        )
        let config = CSVConfiguration(
            hasHeaderRow: hasHeaderRow,
            trimFields: trimFields,
            delimiter: delimiter
        )
        try self.init(iterator: iterator, config: config)
    }

    /// Unavailable.
    @available(*, unavailable, message: "Use init(stream:codecType:endian:config:) instead")
    public init<T: UnicodeCodec>(
        stream: InputStream,
        codecType: T.Type,
        endian: Endian = .big,
        hasHeaderRow: Bool = defaultHasHeaderRow,
        trimFields: Bool = defaultTrimFields,
        delimiter: UnicodeScalar = defaultDelimiter
        ) throws where T.CodeUnit == UInt32 {

        let reader = try BinaryReader(stream: stream, endian: endian, closeOnDeinit: true)
        let iterator = UnicodeIterator(
            input: reader.makeUInt32Iterator(),
            inputEncodingType: codecType
        )
        let config = CSVConfiguration(
            hasHeaderRow: hasHeaderRow,
            trimFields: trimFields,
            delimiter: delimiter
        )
        try self.init(iterator: iterator, config: config)
    }

    /// Unavailable.
    @available(*, unavailable, message: "Use init(stream:config:) instead")
    public init(
        stream: InputStream,
        hasHeaderRow: Bool = defaultHasHeaderRow,
        trimFields: Bool = defaultTrimFields,
        delimiter: UnicodeScalar = defaultDelimiter) throws {

        let config = CSVConfiguration(
            hasHeaderRow: hasHeaderRow,
            trimFields: trimFields,
            delimiter: delimiter
        )
        try self.init(stream: stream, codecType: UTF8.self, config: config)
    }

    /// Unavailable.
    @available(*, unavailable, message: "Use init(string:config:) instead")
    public init(
        string: String,
        hasHeaderRow: Bool = defaultHasHeaderRow,
        trimFields: Bool = defaultTrimFields,
        delimiter: UnicodeScalar = defaultDelimiter) throws {

        let iterator = string.unicodeScalars.makeIterator()
        let config = CSVConfiguration(
            hasHeaderRow: hasHeaderRow,
            trimFields: trimFields,
            delimiter: delimiter
        )
        try self.init(iterator: iterator, config: config)
    }

    /// Unavailable
    @available(*, unavailable, message: "Use CSV.Row.subscript(String) instead")
    public subscript(key: String) -> String? {
        return nil
    }

}
