//
//  CSV.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/11.
//  Copyright © 2016 yaslab. All rights reserved.
//

import Foundation

private let LF = "\n".unicodeScalars.first!
private let CR = "\r".unicodeScalars.first!
private let DQUOTE = "\"".unicodeScalars.first!

internal let defaultEncoding: String.Encoding = .utf8
internal let defaultHasHeaderRow = false
internal let defaultDelimiter = ",".unicodeScalars.first!

internal let utf8BOM: [UInt8] = [0xef, 0xbb, 0xbf]
internal let utf16BigEndianBOM: [UInt8] = [0xfe, 0xff]
internal let utf16LittleEndianBOM: [UInt8] = [0xff, 0xfe]
internal let utf32BigEndianBOM: [UInt8] = [0x00, 0x00, 0xfe, 0xff]
internal let utf32LittleEndianBOM: [UInt8] = [0xff, 0xfe, 0x00, 0x00]

public struct CSV: IteratorProtocol, Sequence {

    private var iterator: AnyIterator<UnicodeScalar>
    private var back: UnicodeScalar? = nil
    
    private let delimiter: UnicodeScalar

    internal var currentRow: [String]? = nil
    
    /**
     CSV header row. To set a value for this property, you set `true` to `hasHeaerRow` in initializer.
     */
    public var headerRow: [String]? { return _headerRow }
    private var _headerRow: [String]? = nil
    
    internal init<T: IteratorProtocol where T.Element == UnicodeScalar>(
        iterator: inout T,
        hasHeaderRow: Bool,
        delimiter: UnicodeScalar)
        throws
    {
        self.iterator = AnyIterator(base: &iterator)
        self.delimiter = delimiter

        if hasHeaderRow {
            guard let headerRow = next() else  {
                throw CSVError.HeaderReadError
            }
            _headerRow = headerRow
        }
    }
    
    public init<T: UnicodeCodec where T.CodeUnit == UInt8>(
        stream: InputStream,
        codecType: T.Type,
        hasHeaderRow: Bool = defaultHasHeaderRow,
        delimiter: UnicodeScalar = defaultDelimiter)
        throws
    {
        let reader = BinaryReader(stream: stream, encoding: .utf8, closeOnDeinit: true)
        var iterator = UnicodeIterator(input: reader.makeUInt8Iterator(), inputEncoding: codecType)
        try self.init(iterator: &iterator, hasHeaderRow: hasHeaderRow, delimiter: delimiter)
    }

    /**
     Create CSV instance with `NSInputStream`.
     
     - parameter stream: An `NSInputStream` object. If the stream is not open, initializer opens automatically.
     - parameter encoding: The character encoding for `stream`. Default: `NSUTF8StringEncoding`.
     - parameter hasHeaderRow: `true` if the CSV has a header row, otherwise `false`. Default: `false`.
     - parameter delimiter: Default: `","`.
     */
    public init(
        stream: InputStream,
        encoding: String.Encoding = defaultEncoding,
        hasHeaderRow: Bool = defaultHasHeaderRow,
        delimiter: UnicodeScalar = defaultDelimiter)
        throws
    {
        let reader = BinaryReader(stream: stream, encoding: encoding, closeOnDeinit: true)
        
        switch encoding {
        case String.Encoding.utf32,
             String.Encoding.utf32BigEndian,
             String.Encoding.utf32LittleEndian:
            var iterator = UnicodeIterator(input: reader.makeUInt32Iterator(), inputEncoding: UTF32.self)
            try self.init(iterator: &iterator, hasHeaderRow: hasHeaderRow, delimiter: delimiter)

        case String.Encoding.utf16,
             String.Encoding.utf16BigEndian,
             String.Encoding.utf16LittleEndian:
            var iterator = UnicodeIterator(input: reader.makeUInt16Iterator(), inputEncoding: UTF16.self)
            try self.init(iterator: &iterator, hasHeaderRow: hasHeaderRow, delimiter: delimiter)
        
        case String.Encoding.utf8,
             String.Encoding.ascii:
            var iterator = UnicodeIterator(input: reader.makeUInt8Iterator(), inputEncoding: UTF8.self)
            try self.init(iterator: &iterator, hasHeaderRow: hasHeaderRow, delimiter: delimiter)
            
        default:
            throw CSVError.StringEncodingMismatch
        }
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
                    let cNext = moveNext()
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
                        field.append(DQUOTE)
                    }
                    else {
                        // ERROR??
                        field.append(c)
                    }
                }
                else {
                    field.append(c)
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
                else if c == delimiter {
                    // END FIELD
                    return (field, false)
                }
                else {
                    field.append(c)
                }
            }
            
            next = moveNext()
        }
        
        return (field, true)
    }
    
}
