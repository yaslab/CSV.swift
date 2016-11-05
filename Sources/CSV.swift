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
public class CSV {

    private var iterator: AnyIterator<UnicodeScalar>
    private let config: CSVConfiguration

    private var back: UnicodeScalar? = nil
    private var fieldBuffer = String.UnicodeScalarView()

    private var currentRowIndex: Int = 0
    private var currentFieldIndex: Int = 0

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
    public convenience init<T: UnicodeCodec>(
        stream: InputStream,
        codecType: T.Type,
        config: CSVConfiguration = CSVConfiguration()
        ) throws where T.CodeUnit == UInt8 {

        let reader = try BinaryReader(stream: stream, endian: .unknown, closeOnDeinit: true)
        let input = reader.makeUInt8Iterator()
        let iterator = UnicodeIterator(input: input, inputEncodingType: codecType)
        try self.init(iterator: iterator, config: config)
        input.errorHandler = { [unowned self] in self.errorHandler(error: $0) }
        iterator.errorHandler = { [unowned self] in self.errorHandler(error: $0) }
    }

    /// Create an instance with `InputStream`.
    ///
    /// - parameter stream: An `InputStream` object. If the stream is not open,
    ///                     initializer opens automatically.
    /// - parameter codecType: A `UnicodeCodec` type for `stream`.
    /// - parameter endian: Endian to use when reading a stream. Default: `.big`.
    /// - parameter config: CSV configuration.
    public convenience init<T: UnicodeCodec>(
        stream: InputStream,
        codecType: T.Type,
        endian: Endian = .big,
        config: CSVConfiguration = CSVConfiguration()
        ) throws where T.CodeUnit == UInt16 {

        let reader = try BinaryReader(stream: stream, endian: endian, closeOnDeinit: true)
        let input = reader.makeUInt16Iterator()
        let iterator = UnicodeIterator(input: input, inputEncodingType: codecType)
        try self.init(iterator: iterator, config: config)
        input.errorHandler = { [unowned self] in self.errorHandler(error: $0) }
        iterator.errorHandler = { [unowned self] in self.errorHandler(error: $0) }
    }

    /// Create an instance with `InputStream`.
    ///
    /// - parameter stream: An `InputStream` object. If the stream is not open,
    ///                     initializer opens automatically.
    /// - parameter codecType: A `UnicodeCodec` type for `stream`.
    /// - parameter endian: Endian to use when reading a stream. Default: `.big`.
    /// - parameter config: CSV configuration.
    public convenience init<T: UnicodeCodec>(
        stream: InputStream,
        codecType: T.Type,
        endian: Endian = .big,
        config: CSVConfiguration = CSVConfiguration()
        ) throws where T.CodeUnit == UInt32 {

        let reader = try BinaryReader(stream: stream, endian: endian, closeOnDeinit: true)
        let input = reader.makeUInt32Iterator()
        let iterator = UnicodeIterator(input: input, inputEncodingType: codecType)
        try self.init(iterator: iterator, config: config)
        input.errorHandler = { [unowned self] in self.errorHandler(error: $0) }
        iterator.errorHandler = { [unowned self] in self.errorHandler(error: $0) }
    }

    // MARK: - Parse CSV

    internal func readRow() -> [String]? {
        currentFieldIndex = 0

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

            currentFieldIndex += 1

            c = moveNext()
        }

        currentRowIndex += 1

        return row
    }

    private func readField(quoted: Bool) -> (String, Bool) {
        fieldBuffer.removeAll(keepingCapacity: true)

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
                        return (String(fieldBuffer), true)
                    } else if cNext == config.delimiter {
                        // END FIELD
                        return (String(fieldBuffer), false)
                    } else if cNext == DQUOTE {
                        // ESC
                        fieldBuffer.append(DQUOTE)
                    } else {
                        // ERROR?
                        fieldBuffer.append(c)
                    }
                } else {
                    fieldBuffer.append(c)
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
                    return (String(fieldBuffer), true)
                } else if c == config.delimiter {
                    // END FIELD
                    return (String(fieldBuffer), false)
                } else {
                    fieldBuffer.append(c)
                }
            }
        }

        // END FILE
        return (String(fieldBuffer), true)
    }

    private func moveNext() -> UnicodeScalar? {
        if back != nil {
            defer {
                back = nil
            }
            return back
        }
        return iterator.next()
    }

    private func errorHandler(error: Error) {
        config.errorHandler?(error, currentRowIndex, currentFieldIndex)
    }

    // MARK: - deprecated

    /// Unavailable.
    @available(*, unavailable, message: "Use init(stream:codecType:config:) instead")
    public convenience init<T: UnicodeCodec>(
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
    public convenience init<T: UnicodeCodec>(
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
    public convenience init<T: UnicodeCodec>(
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
    public convenience init(
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
    public convenience init(
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
