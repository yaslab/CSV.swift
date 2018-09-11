//
//  CSVReader.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/11.
//  Copyright © 2016 yaslab. All rights reserved.
//

import Foundation

internal let LF: UnicodeScalar = "\n"
internal let CR: UnicodeScalar = "\r"
internal let DQUOTE: UnicodeScalar = "\""

internal let DQUOTE_STR: String = "\""
internal let DQUOTE2_STR: String = "\"\""

/// No overview available.
public class CSVReader {

    /// No overview available.
    public struct Configuration {

        /// `true` if the CSV has a header row, otherwise `false`. Default: `false`.
        public var hasHeaderRow: Bool
        /// No overview available.
        public var trimFields: Bool
        /// Default: `","`.
        public var delimiter: UnicodeScalar
        /// No overview available.
        public var whitespaces: CharacterSet

        /// No overview available.
        internal init(
            hasHeaderRow: Bool,
            trimFields: Bool,
            delimiter: UnicodeScalar,
            whitespaces: CharacterSet) {

            self.hasHeaderRow = hasHeaderRow
            self.trimFields = trimFields
            self.delimiter = delimiter

            var whitespaces = whitespaces
            _ = whitespaces.remove(delimiter)
            self.whitespaces = whitespaces
        }

    }

    fileprivate var iterator: AnyIterator<UnicodeScalar>
    public let configuration: Configuration
    public fileprivate (set) var error: Error?

    fileprivate var back: UnicodeScalar?
    fileprivate var fieldBuffer = String.UnicodeScalarView()

    fileprivate var currentRowIndex: Int = 0
    fileprivate var currentFieldIndex: Int = 0

    /// CSV header row. To set a value for this property,
    /// you set `true` to `headerRow` in initializer.
    public private (set) var headerRow: [String]?

    public fileprivate (set) var currentRow: [String]?

    internal init<T: IteratorProtocol>(
        iterator: T,
        configuration: Configuration
        ) throws where T.Element == UnicodeScalar {

        self.iterator = AnyIterator(iterator)
        self.configuration = configuration

        if configuration.hasHeaderRow {
            guard let headerRow = readRow() else {
                throw CSVError.cannotReadHeaderRow
            }
            self.headerRow = headerRow
        }
    }

}

extension CSVReader {

    public static let defaultHasHeaderRow: Bool = false
    public static let defaultTrimFields: Bool = false
    public static let defaultDelimiter: UnicodeScalar = ","
    public static let defaultWhitespaces: CharacterSet = .whitespaces

    /// Create an instance with `InputStream`.
    ///
    /// - parameter stream: An `InputStream` object. If the stream is not open,
    ///                     initializer opens automatically.
    /// - parameter codecType: A `UnicodeCodec` type for `stream`.
    /// - parameter hasHeaderRow: `true` if the CSV has a header row, otherwise `false`. Default: `false`.
    /// - parameter delimiter: Default: `","`.
    public convenience init<T: UnicodeCodec>(
        stream: InputStream,
        codecType: T.Type,
        hasHeaderRow: Bool = defaultHasHeaderRow,
        trimFields: Bool = defaultTrimFields,
        delimiter: UnicodeScalar = defaultDelimiter,
        whitespaces: CharacterSet = defaultWhitespaces
        ) throws where T.CodeUnit == UInt8 {

        let reader = try BinaryReader(stream: stream, endian: .unknown, closeOnDeinit: true)
        let input = reader.makeUInt8Iterator()
        let iterator = UnicodeIterator(input: input, inputEncodingType: codecType)
        let config = Configuration(hasHeaderRow: hasHeaderRow,
                                   trimFields: trimFields,
                                   delimiter: delimiter,
                                   whitespaces: whitespaces)
        try self.init(iterator: iterator, configuration: config)
        input.errorHandler = { [unowned self] in self.errorHandler(error: $0) }
        iterator.errorHandler = { [unowned self] in self.errorHandler(error: $0) }
    }

    /// Create an instance with `InputStream`.
    ///
    /// - parameter stream: An `InputStream` object. If the stream is not open,
    ///                     initializer opens automatically.
    /// - parameter codecType: A `UnicodeCodec` type for `stream`.
    /// - parameter endian: Endian to use when reading a stream. Default: `.big`.
    /// - parameter hasHeaderRow: `true` if the CSV has a header row, otherwise `false`. Default: `false`.
    /// - parameter delimiter: Default: `","`.
    public convenience init<T: UnicodeCodec>(
        stream: InputStream,
        codecType: T.Type,
        endian: Endian = .big,
        hasHeaderRow: Bool = defaultHasHeaderRow,
        trimFields: Bool = defaultTrimFields,
        delimiter: UnicodeScalar = defaultDelimiter,
        whitespaces: CharacterSet = defaultWhitespaces
        ) throws where T.CodeUnit == UInt16 {

        let reader = try BinaryReader(stream: stream, endian: endian, closeOnDeinit: true)
        let input = reader.makeUInt16Iterator()
        let iterator = UnicodeIterator(input: input, inputEncodingType: codecType)
        let config = Configuration(hasHeaderRow: hasHeaderRow,
                                   trimFields: trimFields,
                                   delimiter: delimiter,
                                   whitespaces: whitespaces)
        try self.init(iterator: iterator, configuration: config)
        input.errorHandler = { [unowned self] in self.errorHandler(error: $0) }
        iterator.errorHandler = { [unowned self] in self.errorHandler(error: $0) }
    }

    /// Create an instance with `InputStream`.
    ///
    /// - parameter stream: An `InputStream` object. If the stream is not open,
    ///                     initializer opens automatically.
    /// - parameter codecType: A `UnicodeCodec` type for `stream`.
    /// - parameter endian: Endian to use when reading a stream. Default: `.big`.
    /// - parameter hasHeaderRow: `true` if the CSV has a header row, otherwise `false`. Default: `false`.
    /// - parameter delimiter: Default: `","`.
    public convenience init<T: UnicodeCodec>(
        stream: InputStream,
        codecType: T.Type,
        endian: Endian = .big,
        hasHeaderRow: Bool = defaultHasHeaderRow,
        trimFields: Bool = defaultTrimFields,
        delimiter: UnicodeScalar = defaultDelimiter,
        whitespaces: CharacterSet = defaultWhitespaces
        ) throws where T.CodeUnit == UInt32 {

        let reader = try BinaryReader(stream: stream, endian: endian, closeOnDeinit: true)
        let input = reader.makeUInt32Iterator()
        let iterator = UnicodeIterator(input: input, inputEncodingType: codecType)
        let config = Configuration(hasHeaderRow: hasHeaderRow,
                                   trimFields: trimFields,
                                   delimiter: delimiter,
                                   whitespaces: whitespaces)
        try self.init(iterator: iterator, configuration: config)
        input.errorHandler = { [unowned self] in self.errorHandler(error: $0) }
        iterator.errorHandler = { [unowned self] in self.errorHandler(error: $0) }
    }

    /// Create an instance with `InputStream`.
    ///
    /// - parameter stream: An `InputStream` object. If the stream is not open,
    ///                     initializer opens automatically.
    /// - parameter hasHeaderRow: `true` if the CSV has a header row, otherwise `false`. Default: `false`.
    /// - parameter delimiter: Default: `","`.
    public convenience init(
        stream: InputStream,
        hasHeaderRow: Bool = defaultHasHeaderRow,
        trimFields: Bool = defaultTrimFields,
        delimiter: UnicodeScalar = defaultDelimiter,
        whitespaces: CharacterSet = defaultWhitespaces
        ) throws {

        try self.init(
            stream: stream,
            codecType: UTF8.self,
            hasHeaderRow: hasHeaderRow,
            trimFields: trimFields,
            delimiter: delimiter,
            whitespaces: whitespaces)
    }

    /// Create an instance with CSV string.
    ///
    /// - parameter string: An CSV string.
    /// - parameter hasHeaderRow: `true` if the CSV has a header row, otherwise `false`. Default: `false`.
    /// - parameter delimiter: Default: `","`.
    public convenience init(
        string: String,
        hasHeaderRow: Bool = defaultHasHeaderRow,
        trimFields: Bool = defaultTrimFields,
        delimiter: UnicodeScalar = defaultDelimiter,
        whitespaces: CharacterSet = defaultWhitespaces
        ) throws {

        let iterator = string.unicodeScalars.makeIterator()
        let config = Configuration(hasHeaderRow: hasHeaderRow,
                                   trimFields: trimFields,
                                   delimiter: delimiter,
                                   whitespaces: whitespaces)
        try self.init(iterator: iterator, configuration: config)
    }

    private func errorHandler(error: Error) {
        //configuration.fileInputErrorHandler?(error, currentRowIndex, currentFieldIndex)
        self.error = error
    }

}

// MARK: - Parse CSV

extension CSVReader {

    fileprivate func readRow() -> [String]? {
        currentFieldIndex = 0

        var c = moveNext()
        if c == nil {
            return nil
        }

        var row = [String]()
        var field: String
        var end: Bool
        while true {
            if configuration.trimFields {
                // Trim the leading spaces
                while c != nil && configuration.whitespaces.contains(c!) {
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

                if configuration.trimFields {
                    // Trim the trailing spaces
                    field = field.trimmingCharacters(in: configuration.whitespaces)
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

        currentRow = row
        return row
    }

    private func readField(quoted: Bool) -> (String, Bool) {
        fieldBuffer.removeAll(keepingCapacity: true)

        while let c = moveNext() {
            if quoted {
                if c == DQUOTE {
                    var cNext = moveNext()

                    if configuration.trimFields {
                        // Trim the trailing spaces
                        while cNext != nil && configuration.whitespaces.contains(cNext!) {
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
                    } else if cNext == configuration.delimiter {
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
                } else if c == configuration.delimiter {
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

}

//extension CSVReader {
//
//    public func enumerateRows(_ block: ((CSVReader, inout Bool) throws -> Void)) throws {
//        var stop = false
//        while next() != nil {
//            try block(self, &stop)
//            if stop {
//                break
//            }
//        }
//        if let error = error {
//            throw error
//        }
//    }
//
//}

extension CSVReader: IteratorProtocol {

    @discardableResult
    public func next() -> [String]? {
        return readRow()
    }

}

extension CSVReader {

    public subscript(key: String) -> String? {
        guard let header = headerRow else {
            fatalError("CSVReader.headerRow must not be nil")
        }
        guard let index = header.index(of: key) else {
            return nil
        }
        guard let row = currentRow else {
            fatalError("CSVReader.currentRow must not be nil")
        }
        if index >= row.count {
            return nil
        }
        return row[index]
    }
}

extension CSVReader {
    
    private class CSVRowDecoder: Decoder {
        let codingPath: [CodingKey]
        
        let valuesByColumn: [String: String]
        
        let userInfo: [CodingUserInfoKey : Any]
        
        init(codingPath: [CodingKey], valuesByColumn: [String: String], userInfo: [CodingUserInfoKey : Any] = [:]) {
            self.codingPath = codingPath
            self.valuesByColumn = valuesByColumn
            self.userInfo = userInfo
        }
        
        func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
            let container = CSVKeyedDecodingContainer<Key>(referencing: self)
            return KeyedDecodingContainer(container)
        }
        
        func unkeyedContainer() throws -> UnkeyedDecodingContainer {
            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self,
                                              DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Cannot get unkeyed decoding container -- found null value instead."))
        }
        
        func singleValueContainer() throws -> SingleValueDecodingContainer {
            throw DecodingError.typeMismatch(SingleValueDecodingContainer.self,
                                             DecodingError.Context(codingPath: self.codingPath,
                                                                   debugDescription: "Cannot get single value decoding container -- found keyed container instead."))
        }
    }
    
    private class CSVKeyedDecodingContainer<K : CodingKey> : KeyedDecodingContainerProtocol {
        typealias Key = K
        
        let decoder: CSVRowDecoder
        
        var codingPath: [CodingKey] {
            return self.decoder.codingPath
        }
        
        var allKeys: [K] {
            return self.decoder.valuesByColumn.keys.compactMap { K(stringValue: $0) }
        }
        
        var valuesByColumn: [String: String] {
            return self.decoder.valuesByColumn
        }
        
        func valueFor(column: CodingKey) -> String? {
            return self.valuesByColumn[column.stringValue]
        }
        
        init(referencing decoder: CSVRowDecoder) {
            self.decoder = decoder
        }
        
        func contains(_ key: K) -> Bool {
            return self.valueFor(column: key) != nil
        }
        
        func decodeNil(forKey key: K) throws -> Bool {
            guard let value = self.valueFor(column: key) else {
                return true
            }
            
            if value.count == 0 {
                return true
            }
            
            return false
        }
        
        // TODO: support DecodingError.keyNotFound
        // TODO: support DecodingError.valueNotFound
        func decode(_ type: Bool.Type, forKey key: K) throws -> Bool {
            guard let result = self.valueFor(column: key).flatMap({ Bool($0) }) else {
                throw DecodingError.typeMismatch(type,
                                                 DecodingError.Context(codingPath: codingPath, debugDescription: "decode(...) value '\(self.valueFor(column: key) ?? "nil")'"))
            }
            return result
        }
        
        func decode(_ type: String.Type, forKey key: K) throws -> String {
            guard let result = self.valueFor(column: key).flatMap({ String($0) }) else {
                throw DecodingError.typeMismatch(type,
                                                 DecodingError.Context(codingPath: codingPath, debugDescription: "decode(...) value '\(self.valueFor(column: key) ?? "nil")'"))
            }
            return result
        }
        
        func decode(_ type: Double.Type, forKey key: K) throws -> Double {
            guard let result = self.valueFor(column: key).flatMap({ Double($0) }) else {
                throw DecodingError.typeMismatch(type,
                                                 DecodingError.Context(codingPath: codingPath, debugDescription: "decode(...) value '\(self.valueFor(column: key) ?? "nil")'"))
            }
            return result
        }
        
        func decode(_ type: Float.Type, forKey key: K) throws -> Float {
            guard let result = self.valueFor(column: key).flatMap({ Float($0) }) else {
                throw DecodingError.typeMismatch(type,
                                                 DecodingError.Context(codingPath: codingPath, debugDescription: "decode(...) value '\(self.valueFor(column: key) ?? "nil")'"))
            }
            return result
        }
        
        func decode(_ type: Int.Type, forKey key: K) throws -> Int {
            guard let result = self.valueFor(column: key).flatMap({ Int($0) }) else {
                throw DecodingError.typeMismatch(type,
                                                 DecodingError.Context(codingPath: codingPath, debugDescription: "decode(...) value '\(self.valueFor(column: key) ?? "nil")'"))
            }
            return result
        }
        
        func decode(_ type: Int8.Type, forKey key: K) throws -> Int8 {
            guard let result = self.valueFor(column: key).flatMap({ Int8($0) }) else {
                throw DecodingError.typeMismatch(type,
                                                 DecodingError.Context(codingPath: codingPath, debugDescription: "decode(...) value '\(self.valueFor(column: key) ?? "nil")'"))
            }
            return result
        }
        
        func decode(_ type: Int16.Type, forKey key: K) throws -> Int16 {
            guard let result = self.valueFor(column: key).flatMap({ Int16($0) }) else {
                throw DecodingError.typeMismatch(type,
                                                 DecodingError.Context(codingPath: codingPath, debugDescription: "decode(...) value '\(self.valueFor(column: key) ?? "nil")'"))
            }
            return result

        }
        
        func decode(_ type: Int32.Type, forKey key: K) throws -> Int32 {
            guard let result = self.valueFor(column: key).flatMap({ Int32($0) }) else {
                throw DecodingError.typeMismatch(type,
                                                 DecodingError.Context(codingPath: codingPath, debugDescription: "decode(...) value '\(self.valueFor(column: key) ?? "nil")'"))
            }
            return result

        }
        
        func decode(_ type: Int64.Type, forKey key: K) throws -> Int64 {
            guard let result = self.valueFor(column: key).flatMap({ Int64($0) }) else {
                throw DecodingError.typeMismatch(type,
                                                 DecodingError.Context(codingPath: codingPath, debugDescription: "decode(...) value '\(self.valueFor(column: key) ?? "nil")'"))
            }
            return result

        }
        
        func decode(_ type: UInt.Type, forKey key: K) throws -> UInt {
            guard let result = self.valueFor(column: key).flatMap({ UInt($0) }) else {
                throw DecodingError.typeMismatch(type,
                                                 DecodingError.Context(codingPath: codingPath, debugDescription: "decode(...) value '\(self.valueFor(column: key) ?? "nil")'"))
            }
            return result

        }
        
        func decode(_ type: UInt8.Type, forKey key: K) throws -> UInt8 {
            guard let result = self.valueFor(column: key).flatMap({ UInt8($0) }) else {
                throw DecodingError.typeMismatch(type,
                                                 DecodingError.Context(codingPath: codingPath, debugDescription: "decode(...) value '\(self.valueFor(column: key) ?? "nil")'"))
            }
            return result

        }
        
        func decode(_ type: UInt16.Type, forKey key: K) throws -> UInt16 {
            guard let result = self.valueFor(column: key).flatMap({ UInt16($0) }) else {
                throw DecodingError.typeMismatch(type,
                                                 DecodingError.Context(codingPath: codingPath, debugDescription: "decode(...) value '\(self.valueFor(column: key) ?? "nil")'"))
            }
            return result

        }
        
        func decode(_ type: UInt32.Type, forKey key: K) throws -> UInt32 {
            guard let result = self.valueFor(column: key).flatMap({ UInt32($0) }) else {
                throw DecodingError.typeMismatch(type,
                                                 DecodingError.Context(codingPath: codingPath, debugDescription: "decode(...) value '\(self.valueFor(column: key) ?? "nil")'"))
            }
            return result

        }
        
        func decode(_ type: UInt64.Type, forKey key: K) throws -> UInt64 {
            guard let result = self.valueFor(column: key).flatMap({ UInt64($0) }) else {
                throw DecodingError.typeMismatch(type,
                                                 DecodingError.Context(codingPath: codingPath, debugDescription: "decode(...) value '\(self.valueFor(column: key) ?? "nil")'"))
            }
            return result

        }
        
        func decode<T>(_ type: T.Type, forKey key: K) throws -> T where T : Decodable {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: codingPath,
                                      debugDescription: "CSV does not support nested values")
            )
        }
        
        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: K) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: codingPath,
                                      debugDescription: "CSV does not support nested values")
            )
        }
        
        func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: codingPath,
                                      debugDescription: "CSV does not support nested values")
            )
        }
        
        func superDecoder() throws -> Decoder {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: codingPath,
                                      debugDescription: "CSV does not support nested values")
            )
        }
        
        func superDecoder(forKey key: K) throws -> Decoder {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: codingPath,
                                      debugDescription: "CSV does not support nested values")
            )
        }
        
        
    }
    

    public func readRow<T>() throws -> T? where T: Decodable {
        guard let headerRow = self.headerRow else {
            throw DecodingError.typeMismatch(T.self,
                                             DecodingError.Context(codingPath: [],
                                                                   debugDescription: "readRow(): Header row required to map to Decodable")
            )
        }
        
        guard let valuesRow = self.readRow() else {
            return nil
        }
        
        let valuesForColumns = Dictionary(uniqueKeysWithValues: zip(headerRow, valuesRow))

        let decoder = CSVRowDecoder(codingPath: [], valuesByColumn: valuesForColumns)
        return try T(from: decoder)
    }
}
