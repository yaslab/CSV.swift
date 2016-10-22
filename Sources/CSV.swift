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

extension CSV: Sequence { }

extension CSV: IteratorProtocol {

    // TODO: Documentation
    /// No overview available.
    public mutating func next() -> Row? {
        guard let row = readRow() else {
            return nil
        }
        currentRow = Row(data: row, headerRow: headerRow)
        return currentRow
    }

}

// TODO: Documentation
/// No overview available.
public struct CSV {

    /// No overview available.
    public typealias HeaderRow = [String]

    /// No overview available.
    public struct Row: RandomAccessCollection {
        
        private let data: [String]
        private let headerRow: HeaderRow?
        
        internal init(data: [String], headerRow: HeaderRow?) {
            self.data = data
            self.headerRow = headerRow
        }
        
        // MARK: - RandomAccessCollection

        /// No overview available.
        public var startIndex: Int {
            return data.startIndex
        }
        
        /// No overview available.
        public var endIndex: Int {
            return data.endIndex
        }
        
        /// No overview available.
        public func index(before i: Int) -> Int {
            return data.index(before: i)
        }
        
        /// No overview available.
        public func index(after i: Int) -> Int {
            return data.index(after: i)
        }
        
        /// No overview available.
        public subscript(index: Int) -> String {
            return data[index]
        }

        // MARK: - Public method
        
        /// No overview available.
        public subscript(key: String) -> String? {
            assert(headerRow != nil, "CSVConfiguration.hasHeaderRow must be true")
            guard let index = headerRow!.index(of: key) else {
                return nil
            }
            return data[index]
        }
        
        /// No overview available.
        public func toArray() -> [String] {
            return data
        }
        
        /// No overview available.
        public func toDictionary() -> [String : String] {
            assert(headerRow != nil, "CSVConfiguration.hasHeaderRow must be true")
            var dictionary: [String : String] = [:]
            for (key, value) in zip(headerRow!, data) {
                dictionary[key] = value
            }
            return dictionary
        }
        
    }
    
    private var iterator: AnyIterator<UnicodeScalar>
    private let config: CSVConfiguration
    
    private var back: UnicodeScalar? = nil
    
    // TODO: deprecated
    internal var currentRow: Row? = nil

    /// CSV header row. To set a value for this property, you set `true` to `hasHeaerRow` in initializer.
    public private(set) var headerRow: HeaderRow? = nil

    internal init<T: IteratorProtocol>(
        iterator: T,
        config: CSVConfiguration)
        throws
        where T.Element == UnicodeScalar
    {
        self.iterator = AnyIterator(iterator)
        self.config = config
        
        if config.hasHeaderRow {
            guard let headerRow = readRow() else {
                throw CSVError.cannotReadHeaderRow
            }
            self.headerRow = headerRow
        }
    }

    /// Unavailable.
    @available(*, unavailable, message: "Use init(stream:codecType:config:) instead")
    public init<T: UnicodeCodec>(
        stream: InputStream,
        codecType: T.Type,
        hasHeaderRow: Bool = defaultHasHeaderRow,
        trimFields: Bool = defaultTrimFields,
        delimiter: UnicodeScalar = defaultDelimiter)
        throws
        where T.CodeUnit == UInt8
    {
        let reader = try BinaryReader(stream: stream, endian: .unknown, closeOnDeinit: true)
        let iterator = UnicodeIterator(input: reader.makeUInt8Iterator(), inputEncodingType: codecType)
        let config = CSVConfiguration(hasHeaderRow: hasHeaderRow, trimFields: trimFields, delimiter: delimiter, whitespaces: defaultWhitespaces)
        try self.init(iterator: iterator, config: config)
    }

    /// Unavailable.
    @available(*, unavailable, message: "Use init(stream:codecType:config:) instead")
    public init<T: UnicodeCodec>(
        stream: InputStream,
        codecType: T.Type,
        endian: Endian = .big,
        hasHeaderRow: Bool = defaultHasHeaderRow,
        trimFields: Bool = defaultTrimFields,
        delimiter: UnicodeScalar = defaultDelimiter)
        throws
        where T.CodeUnit == UInt16
    {
        let reader = try BinaryReader(stream: stream, endian: endian, closeOnDeinit: true)
        let iterator = UnicodeIterator(input: reader.makeUInt16Iterator(), inputEncodingType: codecType)
        let config = CSVConfiguration(hasHeaderRow: hasHeaderRow, trimFields: trimFields, delimiter: delimiter, whitespaces: defaultWhitespaces)
        try self.init(iterator: iterator, config: config)
    }

    /// Unavailable.
    @available(*, unavailable, message: "Use init(stream:codecType:config:) instead")
    public init<T: UnicodeCodec>(
        stream: InputStream,
        codecType: T.Type,
        endian: Endian = .big,
        hasHeaderRow: Bool = defaultHasHeaderRow,
        trimFields: Bool = defaultTrimFields,
        delimiter: UnicodeScalar = defaultDelimiter)
        throws
        where T.CodeUnit == UInt32
    {
        let reader = try BinaryReader(stream: stream, endian: endian, closeOnDeinit: true)
        let iterator = UnicodeIterator(input: reader.makeUInt32Iterator(), inputEncodingType: codecType)
        let config = CSVConfiguration(hasHeaderRow: hasHeaderRow, trimFields: trimFields, delimiter: delimiter, whitespaces: defaultWhitespaces)
        try self.init(iterator: iterator, config: config)
    }
    
    /// Create an instance with `InputStream`.
    ///
    /// - parameter stream: An `InputStream` object. If the stream is not open, initializer opens automatically.
    /// - parameter codecType: A `UnicodeCodec` type for `stream`.
    /// - parameter endian: Endian to use when reading a stream. Default: `.big`.
    /// - parameter config: CSV configuration.
    public init<T: UnicodeCodec>(
        stream: InputStream,
        codecType: T.Type,
        config: CSVConfiguration = CSVConfiguration())
        throws
        where T.CodeUnit == UInt8
    {
        let reader = try BinaryReader(stream: stream, endian: .unknown, closeOnDeinit: true)
        let iterator = UnicodeIterator(input: reader.makeUInt8Iterator(), inputEncodingType: codecType)
        try self.init(iterator: iterator, config: config)
    }
    
    /// Create an instance with `InputStream`.
    ///
    /// - parameter stream: An `InputStream` object. If the stream is not open, initializer opens automatically.
    /// - parameter codecType: A `UnicodeCodec` type for `stream`.
    /// - parameter endian: Endian to use when reading a stream. Default: `.big`.
    /// - parameter config: CSV configuration.
    public init<T: UnicodeCodec>(
        stream: InputStream,
        codecType: T.Type,
        endian: Endian = .big,
        config: CSVConfiguration = CSVConfiguration())
        throws
        where T.CodeUnit == UInt16
    {
        let reader = try BinaryReader(stream: stream, endian: endian, closeOnDeinit: true)
        let iterator = UnicodeIterator(input: reader.makeUInt16Iterator(), inputEncodingType: codecType)
        try self.init(iterator: iterator, config: config)
    }
    
    /// Create an instance with `InputStream`.
    ///
    /// - parameter stream: An `InputStream` object. If the stream is not open, initializer opens automatically.
    /// - parameter codecType: A `UnicodeCodec` type for `stream`.
    /// - parameter endian: Endian to use when reading a stream. Default: `.big`.
    /// - parameter config: CSV configuration.
    public init<T: UnicodeCodec>(
        stream: InputStream,
        codecType: T.Type,
        endian: Endian = .big,
        config: CSVConfiguration = CSVConfiguration())
        throws
        where T.CodeUnit == UInt32
    {
        let reader = try BinaryReader(stream: stream, endian: endian, closeOnDeinit: true)
        let iterator = UnicodeIterator(input: reader.makeUInt32Iterator(), inputEncodingType: codecType)
        try self.init(iterator: iterator, config: config)
    }
    
    // MARK: - Parse CSV
    
    fileprivate mutating func readRow() -> [String]? {
        var next = moveNext()
        if next == nil {
            return nil
        }
        
        var row = [String]()
        var field: String
        var end: Bool
        while true {
            if config.trimFields {
                // Trim the leading spaces
                while next != nil && config.whitespaces.contains(next!) {
                    next = moveNext()
                }
            }
            
            if next == nil {
                (field, end) = ("", true)
            }
            else if next == DQUOTE {
                (field, end) = readField(quoted: true)
            }
            else {
                back = next
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
            next = moveNext()
        }

        return row
    }
    
    private mutating func readField(quoted: Bool) -> (String, Bool) {
        var field = ""

        var next = moveNext()
        while let c = next {
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
                    }
                    else if cNext == config.delimiter {
                        // END FIELD
                        return (field, false)
                    }
                    else if cNext == DQUOTE {
                        // ESC
                        field.append(String(DQUOTE))
                    }
                    else {
                        // ERROR?
                        field.append(String(c))
                    }
                }
                else {
                    field.append(String(c))
                }
            }
            else {
                if c == CR || c == LF {
                    if c == CR {
                        let cNext = moveNext()
                        if cNext != LF {
                            back = cNext
                        }
                    }
                    // END ROW
                    return (field, true)
                }
                else if c == config.delimiter {
                    // END FIELD
                    return (field, false)
                }
                else {
                    field.append(String(c))
                }
            }
            
            next = moveNext()
        }
        
        // END FILE
        return (field, true)
    }
    
    private mutating func moveNext() -> UnicodeScalar? {
        if back != nil {
            defer { back = nil }
            return back
        }
        return iterator.next()
    }

}
