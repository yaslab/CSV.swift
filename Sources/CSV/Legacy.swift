//
//  Legacy.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/11.
//  Copyright © 2016 yaslab. All rights reserved.
//

import Foundation

@available(*, unavailable, renamed: "CSVReader")
public enum CSV {}

extension CSVReader {
    @available(*, unavailable, renamed: "CSVReader.init(string:)")
    public init(
        string: String,
        hasHeaderRow: Bool = false,
        trimFields: Bool = false,
        delimiter: UnicodeScalar = ",",
        whitespaces: CharacterSet = .whitespaces
    ) throws {
        fatalError()
    }

    @available(*, unavailable, renamed: "CSVReader.init(fileAtPath:)")
    public init(
        stream: InputStream,
        hasHeaderRow: Bool = false,
        trimFields: Bool = false,
        delimiter: UnicodeScalar = ",",
        whitespaces: CharacterSet = .whitespaces
    ) throws {
        fatalError()
    }

    @available(*, unavailable, renamed: "CSVReader.init(fileAtPath:)")
    public init<T>(
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
    public init<T>(
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
    public init<T>(
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

    @available(*, unavailable, renamed: "CSVRow")
    public var headerRow: [String]? { nil }

    @available(*, unavailable, renamed: "CSVRow")
    public var currentRow: [String]? { nil }

    @available(*, unavailable, renamed: "CSVError")
    public var error: Error? { nil }

    @available(*, unavailable, renamed: "CSVRow")
    public subscript(key: String) -> String? { nil }
}
