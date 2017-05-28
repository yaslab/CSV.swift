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
        
        public init(delimiter: String = String(defaultDelimiter), newline: String = String(LF)) {
            self.delimiter = delimiter
            self.newline = newline
        }
        
    }
    
    public let stream: OutputStream
    public let configuration: Configuration
    fileprivate let writeScalar: ((UnicodeScalar) throws -> Void)

    fileprivate var isFirstRecord: Bool = true
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
            throw CSVError.cannotOpenStream
        }
    }
    
}

extension CSVWriter {

    public convenience init(
        stream: OutputStream,
        configuration: Configuration = Configuration()) throws {

        try self.init(stream: stream, codecType: UTF8.self, configuration: configuration)
    }
    
    public convenience init<T: UnicodeCodec>(
        stream: OutputStream,
        codecType: T.Type,
        configuration: Configuration = Configuration()
        ) throws where T.CodeUnit == UInt8 {
        
        try self.init(stream: stream, configuration: configuration) { (scalar: UnicodeScalar) throws in
            var error: CSVError? = nil
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
        configuration: Configuration = Configuration()
        ) throws where T.CodeUnit == UInt16 {
        
        try self.init(stream: stream, configuration: configuration) { (scalar: UnicodeScalar) throws in
            var error: CSVError? = nil
            codecType.encode(scalar) { (code: UInt16) in
                var code = (endian == .big) ? code.bigEndian : code.littleEndian
                withUnsafeBytes(of: &code) { (buffer) -> Void in
                    let count = stream.write(buffer.baseAddress!.assumingMemoryBound(to: UInt8.self), maxLength: buffer.count)
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
        configuration: Configuration = Configuration()
        ) throws where T.CodeUnit == UInt32 {
        
        try self.init(stream: stream, configuration: configuration) { (scalar: UnicodeScalar) throws in
            var error: CSVError? = nil
            codecType.encode(scalar) { (code: UInt32) in
                var code = (endian == .big) ? code.bigEndian : code.littleEndian
                withUnsafeBytes(of: &code) { (buffer) -> Void in
                    let count = stream.write(buffer.baseAddress!.assumingMemoryBound(to: UInt8.self), maxLength: buffer.count)
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

    public func beginNewRecord() {
        isFirstField = true
    }
    
    public func write(field value: String, quoted: Bool = false) throws {
        if isFirstRecord {
            isFirstRecord = false
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
        
        if quoted {            
            value = value.replacingOccurrences(of: DQUOTE_STR, with: DQUOTE2_STR)
            try writeScalar(DQUOTE)
        }
        
        try value.unicodeScalars.forEach(writeScalar)
        
        if quoted {
            try writeScalar(DQUOTE)
        }
    }
    
    public func write(record values: [String], quotedAtIndex: ((Int) -> Bool) = { _ in false }) throws {
        beginNewRecord()
        for (i, value) in values.enumerated() {
            try write(field: value, quoted: quotedAtIndex(i))
        }
    }
    
}
