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

internal let defaultHasHeaderRecord = false
internal let defaultTrimFields = false
internal let defaultDelimiter: UnicodeScalar = ","
internal let defaultWhitespaces = CharacterSet.whitespaces

/// No overview available.
public class CSVReader {
    
    /// No overview available.
    public struct Configuration {
        
        public var fileInputErrorHandler: ((Error, Int, Int) -> Void)? = nil
        
        /// `true` if the CSV has a header record, otherwise `false`. Default: `false`.
        public var hasHeaderRecord: Bool
        /// No overview available.
        public var trimFields: Bool
        /// Default: `","`.
        public var delimiter: UnicodeScalar
        /// No overview available.
        public var whitespaces: CharacterSet
        
        /// No overview available.
        public init(
            hasHeaderRecord: Bool = defaultHasHeaderRecord,
            trimFields: Bool = defaultTrimFields,
            delimiter: UnicodeScalar = defaultDelimiter,
            whitespaces: CharacterSet = defaultWhitespaces) {
            
            self.hasHeaderRecord = hasHeaderRecord
            self.trimFields = trimFields
            self.delimiter = delimiter
            
            var whitespaces = whitespaces
            _ = whitespaces.remove(delimiter)
            self.whitespaces = whitespaces
        }
        
    }

    fileprivate var iterator: AnyIterator<UnicodeScalar>
    //public let stream: InputStream?
    public let configuration: Configuration

    fileprivate var back: UnicodeScalar? = nil
    fileprivate var fieldBuffer = String.UnicodeScalarView()

    fileprivate var currentRecordIndex: Int = 0
    fileprivate var currentFieldIndex: Int = 0

    /// CSV header record. To set a value for this property,
    /// you set `true` to `headerRecord` in initializer.
    public private (set) var headerRecord: [String]? = nil

    public fileprivate (set) var currentRecord: [String]? = nil
    
    internal init<T: IteratorProtocol>(
        iterator: T,
        configuration: Configuration
        ) throws where T.Element == UnicodeScalar {

        self.iterator = AnyIterator(iterator)
        self.configuration = configuration

        if configuration.hasHeaderRecord {
            guard let headerRecord = readRecord() else {
                throw CSVError.cannotReadHeaderRecord
            }
            self.headerRecord = headerRecord
        }
    }

}

extension CSVReader {
    
    /// Create an instance with `InputStream`.
    ///
    /// - parameter stream: An `InputStream` object. If the stream is not open,
    ///                     initializer opens automatically.
    /// - parameter codecType: A `UnicodeCodec` type for `stream`.
    /// - parameter config: CSV configuration.
    public convenience init<T: UnicodeCodec>(
        stream: InputStream,
        codecType: T.Type,
        configuration: Configuration = Configuration()
        ) throws where T.CodeUnit == UInt8 {

        let reader = try BinaryReader(stream: stream, endian: .unknown, closeOnDeinit: true)
        let input = reader.makeUInt8Iterator()
        let iterator = UnicodeIterator(input: input, inputEncodingType: codecType)
        try self.init(iterator: iterator, configuration: configuration)
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
        configuration: Configuration = Configuration()
        ) throws where T.CodeUnit == UInt16 {

        let reader = try BinaryReader(stream: stream, endian: endian, closeOnDeinit: true)
        let input = reader.makeUInt16Iterator()
        let iterator = UnicodeIterator(input: input, inputEncodingType: codecType)
        try self.init(iterator: iterator, configuration: configuration)
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
        configuration: Configuration = Configuration()
        ) throws where T.CodeUnit == UInt32 {

        let reader = try BinaryReader(stream: stream, endian: endian, closeOnDeinit: true)
        let input = reader.makeUInt32Iterator()
        let iterator = UnicodeIterator(input: input, inputEncodingType: codecType)
        try self.init(iterator: iterator, configuration: configuration)
        input.errorHandler = { [unowned self] in self.errorHandler(error: $0) }
        iterator.errorHandler = { [unowned self] in self.errorHandler(error: $0) }
    }
    
    /// Create an instance with `InputStream`.
    ///
    /// - parameter stream: An `InputStream` object. If the stream is not open,
    ///                     initializer opens automatically.
    /// - parameter config: CSV configuration.
    public convenience init(
        stream: InputStream,
        configuration: Configuration = Configuration()) throws {
        
        try self.init(stream: stream, codecType: UTF8.self, configuration: configuration)
    }
    
    /// Create an instance with CSV string.
    ///
    /// - parameter string: An CSV string.
    /// - parameter config: CSV configuration.
    public convenience init(
        string: String,
        configuration: Configuration = Configuration()) throws {
        
        let iterator = string.unicodeScalars.makeIterator()
        try self.init(iterator: iterator, configuration: configuration)
    }

    private func errorHandler(error: Error) {
        configuration.fileInputErrorHandler?(error, currentRecordIndex, currentFieldIndex)
    }
    
}

// MARK: - Parse CSV

extension CSVReader {
    
    fileprivate func readRecord() -> [String]? {
        currentFieldIndex = 0

        var c = moveNext()
        if c == nil {
            return nil
        }

        var record = [String]()
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
            record.append(field)
            if end {
                break
            }

            currentFieldIndex += 1

            c = moveNext()
        }

        currentRecordIndex += 1

        currentRecord = record
        return record
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
                        // END RECORD
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
                    // END RECORD
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

extension CSVReader {
    
    public func enumerateRecords(_ block: (([String], [String]?, inout Bool) throws -> Void)) rethrows {
        var stop = false
        while let record = readRecord() {
            try block(record, headerRecord, &stop)
            if stop {
                break
            }
        }
    }
    
}

extension CSVReader: IteratorProtocol {
    
    @discardableResult
    public func next() -> [String]? {
        return readRecord()
    }
    
}

extension CSVReader {

    public subscript(key: String) -> String? {
        guard let header = headerRecord else {
            fatalError("CSVReader.headerRecord must not be nil")
        }
        guard let index = header.index(of: key) else {
            return nil
        }
        guard let record = currentRecord else {
            fatalError("CSVReader.currentRecord must not be nil")
        }
        if index >= record.count {
            return nil
        }
        return record[index]
    }
    
}

// MARK: - deprecated

extension CSVReader {
    
    /// Unavailable.
    @available(*, unavailable, message: "Use init(stream:codecType:config:) instead")
    public convenience init<T: UnicodeCodec>(
        stream: InputStream,
        codecType: T.Type,
        hasHeaderRow: Bool = defaultHasHeaderRecord,
        trimFields: Bool = defaultTrimFields,
        delimiter: UnicodeScalar = defaultDelimiter
        ) throws where T.CodeUnit == UInt8 {

        let reader = try BinaryReader(stream: stream, endian: .unknown, closeOnDeinit: true)
        let iterator = UnicodeIterator(
            input: reader.makeUInt8Iterator(),
            inputEncodingType: codecType
        )
        let config = Configuration(
            hasHeaderRecord: hasHeaderRow,
            trimFields: trimFields,
            delimiter: delimiter
        )
        try self.init(iterator: iterator, configuration: config)
    }

    /// Unavailable.
    @available(*, unavailable, message: "Use init(stream:codecType:endian:config:) instead")
    public convenience init<T: UnicodeCodec>(
        stream: InputStream,
        codecType: T.Type,
        endian: Endian = .big,
        hasHeaderRow: Bool = defaultHasHeaderRecord,
        trimFields: Bool = defaultTrimFields,
        delimiter: UnicodeScalar = defaultDelimiter
        ) throws where T.CodeUnit == UInt16 {

        let reader = try BinaryReader(stream: stream, endian: endian, closeOnDeinit: true)
        let iterator = UnicodeIterator(
            input: reader.makeUInt16Iterator(),
            inputEncodingType: codecType
        )
        let config = Configuration(
            hasHeaderRecord: hasHeaderRow,
            trimFields: trimFields,
            delimiter: delimiter
        )
        try self.init(iterator: iterator, configuration: config)
    }

    /// Unavailable.
    @available(*, unavailable, message: "Use init(stream:codecType:endian:config:) instead")
    public convenience init<T: UnicodeCodec>(
        stream: InputStream,
        codecType: T.Type,
        endian: Endian = .big,
        hasHeaderRow: Bool = defaultHasHeaderRecord,
        trimFields: Bool = defaultTrimFields,
        delimiter: UnicodeScalar = defaultDelimiter
        ) throws where T.CodeUnit == UInt32 {

        let reader = try BinaryReader(stream: stream, endian: endian, closeOnDeinit: true)
        let iterator = UnicodeIterator(
            input: reader.makeUInt32Iterator(),
            inputEncodingType: codecType
        )
        let config = Configuration(
            hasHeaderRecord: hasHeaderRow,
            trimFields: trimFields,
            delimiter: delimiter
        )
        try self.init(iterator: iterator, configuration: config)
    }

    /// Unavailable.
    @available(*, unavailable, message: "Use init(stream:config:) instead")
    public convenience init(
        stream: InputStream,
        hasHeaderRow: Bool = defaultHasHeaderRecord,
        trimFields: Bool = defaultTrimFields,
        delimiter: UnicodeScalar = defaultDelimiter) throws {

        let config = Configuration(
            hasHeaderRecord: hasHeaderRow,
            trimFields: trimFields,
            delimiter: delimiter
        )
        try self.init(stream: stream, codecType: UTF8.self, configuration: config)
    }

    /// Unavailable.
    @available(*, unavailable, message: "Use init(string:config:) instead")
    public convenience init(
        string: String,
        hasHeaderRow: Bool = defaultHasHeaderRecord,
        trimFields: Bool = defaultTrimFields,
        delimiter: UnicodeScalar = defaultDelimiter) throws {

        let iterator = string.unicodeScalars.makeIterator()
        let config = Configuration(
            hasHeaderRecord: hasHeaderRow,
            trimFields: trimFields,
            delimiter: delimiter
        )
        try self.init(iterator: iterator, configuration: config)
    }

    /// Unavailable
//    @available(*, unavailable, message: "Use CSV.Row.subscript(String) instead")
//    public subscript(key: String) -> String? {
//        // FIXME: 
//        return nil
//    }

}
