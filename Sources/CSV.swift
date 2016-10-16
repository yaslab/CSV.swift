//
//  CSV.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/11.
//  Copyright © 2016 yaslab. All rights reserved.
//

import Foundation

private let LF = UnicodeScalar("\n")!
private let CR = UnicodeScalar("\r")!
private let DQUOTE = UnicodeScalar("\"")!

internal let defaultHasHeaderRow = false
internal let defaultTrimFields = false
internal let defaultDelimiter = UnicodeScalar(",")!

public struct CSV: IteratorProtocol, Sequence {

    private var iterator: AnyIterator<UnicodeScalar>
    private let trimFields: Bool
    private let delimiter: UnicodeScalar

    private var back: UnicodeScalar? = nil

    internal var currentRow: [String]? = nil

    /// CSV header row. To set a value for this property, you set `true` to `hasHeaerRow` in initializer.
    public var headerRow: [String]? { return _headerRow }
    private var _headerRow: [String]? = nil
    
    private let whitespaces: CharacterSet

    internal init<T: IteratorProtocol>(
        iterator: T,
        hasHeaderRow: Bool,
        trimFields: Bool,
        delimiter: UnicodeScalar)
        throws where T.Element == UnicodeScalar
    {
        self.iterator = AnyIterator(base: iterator)
        self.trimFields = trimFields
        self.delimiter = delimiter

        var whitespaces = CharacterSet.whitespaces
        whitespaces.remove(delimiter)
        self.whitespaces = whitespaces
        
        if hasHeaderRow {
            guard let headerRow = next() else {
                throw CSVError.cannotReadHeaderRow
            }
            _headerRow = headerRow
        }
    }

    /// Create an instance with `InputStream`.
    ///
    /// - parameter stream: An `InputStream` object. If the stream is not open, initializer opens automatically.
    /// - parameter codecType: A `UnicodeCodec` type for `stream`.
    /// - parameter hasHeaderRow: `true` if the CSV has a header row, otherwise `false`. Default: `false`.
    /// - parameter delimiter: Default: `","`.
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
        try self.init(iterator: iterator, hasHeaderRow: hasHeaderRow, trimFields: trimFields, delimiter: delimiter)
    }

    /// Create an instance with `InputStream`.
    ///
    /// - parameter stream: An `InputStream` object. If the stream is not open, initializer opens automatically.
    /// - parameter codecType: A `UnicodeCodec` type for `stream`.
    /// - parameter endian: Endian to use when reading a stream. Default: `.big`.
    /// - parameter hasHeaderRow: `true` if the CSV has a header row, otherwise `false`. Default: `false`.
    /// - parameter delimiter: Default: `","`.
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
        try self.init(iterator: iterator, hasHeaderRow: hasHeaderRow, trimFields: trimFields, delimiter: delimiter)
    }

    /// Create an instance with `InputStream`.
    ///
    /// - parameter stream: An `InputStream` object. If the stream is not open, initializer opens automatically.
    /// - parameter codecType: A `UnicodeCodec` type for `stream`.
    /// - parameter endian: Endian to use when reading a stream. Default: `.big`.
    /// - parameter hasHeaderRow: `true` if the CSV has a header row, otherwise `false`. Default: `false`.
    /// - parameter delimiter: Default: `","`.
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
        try self.init(iterator: iterator, hasHeaderRow: hasHeaderRow, trimFields: trimFields, delimiter: delimiter)
    }
    
    // MARK: IteratorProtocol

    /// Advances and returns the next element of the underlying sequence, or
    /// `nil` if no next element exists.
    ///
    /// Repeatedly calling this method returns, in order, all the elements of the
    /// underlying sequence. After the sequence has run out of elements, the
    /// `next()` method returns `nil`.
    ///
    /// You must not call this method if it has previously returned `nil` or if
    /// any other copy of this iterator has been advanced with a call to its
    /// `next()` method.
    ///
    /// The following example shows how an iterator can be used explicitly to
    /// emulate a `for`-`in` loop. First, retrieve a sequence's iterator, and
    /// then call the iterator's `next()` method until it returns `nil`.
    ///
    ///     let numbers = [2, 3, 5, 7]
    ///     var numbersIterator = numbers.makeIterator()
    ///
    ///     while let num = numbersIterator.next() {
    ///         print(num)
    ///     }
    ///     // Prints "2"
    ///     // Prints "3"
    ///     // Prints "5"
    ///     // Prints "7"
    ///
    /// - Returns: The next element in the underlying sequence if a next element
    ///   exists; otherwise, `nil`.
    public mutating func next() -> [String]? {
        return readRow()
    }
    
    internal mutating func moveNext() -> UnicodeScalar? {
        if back != nil {
            defer { back = nil }
            return back
        }
        return iterator.next()
    }
    
    internal mutating func readRow() -> [String]? {
        currentRow = nil

        var next = moveNext()
        if next == nil {
            return nil
        }
        
        var row = [String]()
        var field: String
        var end: Bool
        while true {
            if trimFields {
                // Trim the leading spaces
                while next != nil && whitespaces.contains(next!) {
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
            }
            row.append(field)
            if end {
                break
            }
            next = moveNext()
        }

        currentRow = row
        return row
    }
    
    internal mutating func readField(quoted: Bool) -> (String, Bool) {
        var field = ""

        var next = moveNext()
        while let c = next {
            if quoted {
                if c == DQUOTE {
                    var cNext = moveNext()
                    
                    if trimFields {
                        // Trim the trailing spaces
                        while cNext != nil && whitespaces.contains(cNext!) {
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
                    else if cNext == delimiter {
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
                    
                    if trimFields {
                        // Trim the trailing spaces
                        field = field.trimmingCharacters(in: whitespaces)
                    }
                    
                    // END ROW
                    return (field, true)
                }
                else if c == delimiter {
                    if trimFields {
                        // Trim the trailing spaces
                        field = field.trimmingCharacters(in: whitespaces)
                    }
                    
                    // END FIELD
                    return (field, false)
                }
                else {
                    field.append(String(c))
                }
            }
            
            next = moveNext()
        }

        if trimFields {
            // Trim the trailing spaces
            field = field.trimmingCharacters(in: whitespaces)
        }
        
        // END FILE
        return (field, true)
    }
    
}
