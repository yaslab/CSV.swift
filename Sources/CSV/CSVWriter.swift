//
//  CSVWriter.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2017/05/28.
//  Copyright © 2017 yaslab. All rights reserved.
//

import Foundation

public class CSVWriter {

    public struct Configuration {

        public var delimiter: String
        public var newline: String

        internal init(delimiter: String, newline: Newline) {
            self.delimiter = delimiter

            switch newline {
            case .lf:   self.newline = String(LF)
            case .crlf: self.newline = String(CR) + String(LF)
            }
        }

    }

    public enum Newline {

        /// "\n"
        case lf
        /// "\r\n"
        case crlf

    }

    public let stream: OutputStream
    public let configuration: Configuration
    fileprivate let writeScalar: ((UnicodeScalar) throws -> Void)

    fileprivate var isFirstRow: Bool = true
    fileprivate var isFirstField: Bool = true

    fileprivate init(
        stream: OutputStream,
        configuration: Configuration,
        writeScalar: @escaping ((UnicodeScalar) throws -> Void)) throws {

        self.stream = stream
        self.configuration = configuration
        self.writeScalar = writeScalar

        if stream.streamStatus == .notOpen {
            stream.open()
        }
        if stream.streamStatus != .open {
            throw CSVError.cannotOpenFile
        }
    }

    deinit {
        if stream.streamStatus == .open {
            stream.close()
        }
    }

}

extension CSVWriter {

    public static let defaultDelimiter: UnicodeScalar = ","

    public convenience init(
        stream: OutputStream,
        delimiter: String = String(defaultDelimiter),
        newline: Newline = .lf
        ) throws {

        try self.init(stream: stream, codecType: UTF8.self, delimiter: delimiter, newline: newline)
    }

    public convenience init<T: UnicodeCodec>(
        stream: OutputStream,
        codecType: T.Type,
        delimiter: String = String(defaultDelimiter),
        newline: Newline = .lf
        ) throws where T.CodeUnit == UInt8 {

        let config = Configuration(delimiter: delimiter, newline: newline)
        try self.init(stream: stream, configuration: config) { (scalar: UnicodeScalar) throws in
            var error: CSVError?
            codecType.encode(scalar) { (code: UInt8) in
                var code = code
                let count = stream.write(&code, maxLength: 1)
                if count != 1 {
                    error = CSVError.cannotWriteStream
                }
            }
            if let error = error {
                throw error
            }
        }
    }

    public convenience init<T: UnicodeCodec>(
        stream: OutputStream,
        codecType: T.Type,
        endian: Endian = .big,
        delimiter: String = String(defaultDelimiter),
        newline: Newline = .lf
        ) throws where T.CodeUnit == UInt16 {

        let config = Configuration(delimiter: delimiter, newline: newline)
        try self.init(stream: stream, configuration: config) { (scalar: UnicodeScalar) throws in
            var error: CSVError?
            codecType.encode(scalar) { (code: UInt16) in
                var code = (endian == .big) ? code.bigEndian : code.littleEndian
                withUnsafeBytes(of: &code) { (buffer) -> Void in
                    let count = stream.write(buffer.baseAddress!.assumingMemoryBound(to: UInt8.self),
                                             maxLength: buffer.count)
                    if count != buffer.count {
                        error = CSVError.cannotWriteStream
                    }
                }
            }
            if let error = error {
                throw error
            }
        }
    }

    public convenience init<T: UnicodeCodec>(
        stream: OutputStream,
        codecType: T.Type,
        endian: Endian = .big,
        delimiter: String = String(defaultDelimiter),
        newline: Newline = .lf
        ) throws where T.CodeUnit == UInt32 {

        let config = Configuration(delimiter: delimiter, newline: newline)
        try self.init(stream: stream, configuration: config) { (scalar: UnicodeScalar) throws in
            var error: CSVError?
            codecType.encode(scalar) { (code: UInt32) in
                var code = (endian == .big) ? code.bigEndian : code.littleEndian
                withUnsafeBytes(of: &code) { (buffer) -> Void in
                    let count = stream.write(buffer.baseAddress!.assumingMemoryBound(to: UInt8.self),
                                             maxLength: buffer.count)
                    if count != buffer.count {
                        error = CSVError.cannotWriteStream
                    }
                }
            }
            if let error = error {
                throw error
            }
        }
    }

}

extension CSVWriter {

    public func beginNewRow() {
        isFirstField = true
    }

    public func write(field value: String, quoted: Bool = false) throws {
        if isFirstRow {
            isFirstRow = false
        } else {
            if isFirstField {
                try configuration.newline.unicodeScalars.forEach(writeScalar)
            }
        }

        if isFirstField {
            isFirstField = false
        } else {
            try configuration.delimiter.unicodeScalars.forEach(writeScalar)
        }

        var value = value

        var quoted = quoted
        if !quoted {
            if value.contains("\"") || value.contains(configuration.delimiter) || value.contains("\r") || value.contains("\n") {
                quoted = true
            }
        }

        if quoted {
            value = value.replacingOccurrences(of: DQUOTE_STR, with: DQUOTE2_STR)
            try writeScalar(DQUOTE)
        }

        try value.unicodeScalars.forEach(writeScalar)

        if quoted {
            try writeScalar(DQUOTE)
        }
    }

    public func write(row values: [String], quotedAtIndex: ((Int) -> Bool) = { _ in false }) throws {
        beginNewRow()
        for (i, value) in values.enumerated() {
            try write(field: value, quoted: quotedAtIndex(i))
        }
    }

}
