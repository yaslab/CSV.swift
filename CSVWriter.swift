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
    fileprivate let writeScalar: ((Unicode.Scalar) -> Void)

    fileprivate var isFirstRecord: Bool = true
    fileprivate var isFirstField: Bool = true

    fileprivate init(
        stream: OutputStream,
        configuration: Configuration,
        writeScalar: @escaping ((Unicode.Scalar) -> Void)) {
        
        self.stream = stream
        self.configuration = configuration
        self.writeScalar = writeScalar
        
        if stream.streamStatus == .notOpen {
            stream.open()
        }
    }
    
}

extension CSVWriter {

    public convenience init(
        stream: OutputStream,
        configuration: Configuration = Configuration()) {

        self.init(stream: stream, codecType: UTF8.self, configuration: configuration)
    }
    
    public convenience init<T: UnicodeCodec>(
        stream: OutputStream,
        codecType: T.Type,
        configuration: Configuration = Configuration()
        ) where T.CodeUnit == UInt8 {
        
        self.init(stream: stream, configuration: configuration) { (scalar: Unicode.Scalar) in
            codecType.encode(scalar) { (code: UInt8) in
                var code = code
                let count = stream.write(&code, maxLength: 1)
                if count != 1 {
                    // FIXME: Error
                    print("ERROR: count != 1")
                }
            }
        }
    }
    
    public convenience init<T: UnicodeCodec>(
        stream: OutputStream,
        codecType: T.Type,
        endian: Endian = .big,
        configuration: Configuration = Configuration()
        ) where T.CodeUnit == UInt16 {
        
        self.init(stream: stream, configuration: configuration) { (scalar: Unicode.Scalar) in
            codecType.encode(scalar) { (code: UInt16) in
                var code = (endian == .big) ? code.bigEndian : code.littleEndian
                let count = withUnsafeBytes(of: &code) { (buffer) -> Int in
                    return stream.write(buffer.baseAddress!.assumingMemoryBound(to: UInt8.self), maxLength: buffer.count)
                }
                if count != 2 {
                    // FIXME: Error
                    print("ERROR: count != 2")
                }
            }
        }
    }
    
    public convenience init<T: UnicodeCodec>(
        stream: OutputStream,
        codecType: T.Type,
        endian: Endian = .big,
        configuration: Configuration = Configuration()
        ) where T.CodeUnit == UInt32 {
        
        self.init(stream: stream, configuration: configuration) { (scalar: Unicode.Scalar) in
            codecType.encode(scalar) { (code: UInt32) in
                var code = (endian == .big) ? code.bigEndian : code.littleEndian
                let count = withUnsafeBytes(of: &code) { (buffer) -> Int in
                    return stream.write(buffer.baseAddress!.assumingMemoryBound(to: UInt8.self), maxLength: buffer.count)
                }
                if count != 4 {
                    // FIXME: Error
                    print("ERROR: count != 4")
                }
            }
        }
    }
    
}

extension CSVWriter {

    public func beginNewRecord() {
        isFirstField = true
    }
    
    public func write(field value: String, quoted: Bool = false) {
        if isFirstRecord {
            isFirstRecord = false
        } else {
            if isFirstField {
                configuration.newline.unicodeScalars.forEach(writeScalar)
            }
        }
        
        if isFirstField {
            isFirstField = false
        } else {
            configuration.delimiter.unicodeScalars.forEach(writeScalar)
        }
        
        var value = value
        
        if quoted {            
            value = value.replacingOccurrences(of: DQUOTE_STR, with: DQUOTE2_STR)
            writeScalar(DQUOTE)
        }
        
        value.unicodeScalars.forEach(writeScalar)
        
        if quoted {
            writeScalar(DQUOTE)
        }
    }
    
    public func write(row values: [String], quotedAtIndex: ((Int) -> Bool) = { _ in false }) {
        for (i, value) in values.enumerated() {
            write(field: value, quoted: quotedAtIndex(i))
        }
    }
    
}
