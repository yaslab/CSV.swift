//
//  Legacy.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/11.
//  Copyright © 2016 yaslab. All rights reserved.
//

import Foundation

@available(*, unavailable, renamed: "CSVReader")
public typealias CSV = CSVReader

public struct _LegacySequence: Sequence, IteratorProtocol {
    public mutating func next() -> Result<UTF8.CodeUnit, CSVError>? {
        fatalError()
    }
}

extension CSVReader where Input == _LegacySequence {
    @available(*, unavailable, renamed: "CSVReader.init(string:configuration:)")
    public convenience init(
        string: String,
        hasHeaderRow: Bool = false,
        trimFields: Bool = false,
        delimiter: UnicodeScalar = ",",
        whitespaces: CharacterSet = .whitespaces
    ) throws {
        fatalError()
    }

    @available(*, unavailable, renamed: "CSVReader.init(fileAtPath:configuration:)")
    public convenience init(
        stream: InputStream,
        hasHeaderRow: Bool = false,
        trimFields: Bool = false,
        delimiter: UnicodeScalar = ",",
        whitespaces: CharacterSet = .whitespaces
    ) throws {
        fatalError()
    }

    @available(*, unavailable, renamed: "CSVReader.init(fileAtPath:configuration:)")
    public convenience init<T>(
        stream: InputStream,
        codecType: T.Type,
        hasHeaderRow: Bool = false,
        trimFields: Bool = false,
        delimiter: UnicodeScalar = ",",
        whitespaces: CharacterSet = .whitespaces
    ) throws where T: UnicodeCodec, T.CodeUnit == UInt8 {
        fatalError()
    }

    @available(*, unavailable)
    public convenience init<T>(
        stream: InputStream,
        codecType: T.Type,
        endian: Endian = .big,
        hasHeaderRow: Bool = false,
        trimFields: Bool = false,
        delimiter: UnicodeScalar = ",",
        whitespaces: CharacterSet = .whitespaces
    ) throws where T: UnicodeCodec, T.CodeUnit == UInt16 {
        fatalError()
    }

    @available(*, unavailable)
    public convenience init<T>(
        stream: InputStream,
        codecType: T.Type,
        endian: Endian = .big,
        hasHeaderRow: Bool = false,
        trimFields: Bool = false,
        delimiter: UnicodeScalar = ",",
        whitespaces: CharacterSet = .whitespaces
    ) throws where T: UnicodeCodec, T.CodeUnit == UInt32 {
        fatalError()
    }
}

extension CSVReader {
    @available(*, unavailable, renamed: "CSVRow.header")
    public var headerRow: [String]? { nil }

    @available(*, unavailable, renamed: "CSVRow.columns")
    public var currentRow: [String]? { nil }

    @available(*, unavailable, renamed: "CSVError")
    public var error: Error? { nil }

    @available(*, unavailable, renamed: "CSVRow.subscript(_:)")
    public subscript(key: String) -> String? { nil }
}
