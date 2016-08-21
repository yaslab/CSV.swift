//
//  BinaryReader.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/20.
//  Copyright © 2016 yaslab. All rights reserved.
//

import Foundation

internal let utf8BOM: [UInt8] = [0xef, 0xbb, 0xbf]
internal let utf16BigEndianBOM: [UInt8] = [0xfe, 0xff]
internal let utf16LittleEndianBOM: [UInt8] = [0xff, 0xfe]
internal let utf32BigEndianBOM: [UInt8] = [0x00, 0x00, 0xfe, 0xff]
internal let utf32LittleEndianBOM: [UInt8] = [0xff, 0xfe, 0x00, 0x00]

private func readBOM(buffer buffer: UnsafePointer<UInt8>, length: Int) -> (Endian, Int)? {
    if length >= 4 {
        if memcmp(buffer, utf32BigEndianBOM, 4) == 0 {
            return (.Big, 4)
        }
        if memcmp(buffer, utf32LittleEndianBOM, 4) == 0 {
            return (.Little, 4)
        }
    }
    if length >= 3 {
        if memcmp(buffer, utf8BOM, 3) == 0 {
            return (.Unknown, 3)
        }
    }
    if length >= 2 {
        if memcmp(buffer, utf16BigEndianBOM, 2) == 0 {
            return (.Big, 2)
        }
        if memcmp(buffer, utf16LittleEndianBOM, 2) == 0 {
            return (.Little, 2)
        }
    }
    return nil
}

internal class BinaryReader {

    private let stream: NSInputStream
    private let endian: Endian
    private let closeOnDeinit: Bool

    private var buffer = [UInt8](count: 4, repeatedValue: 0)

    private var tempBuffer = [UInt8](count: 4, repeatedValue: 0)
    private let tempBufferSize = 4
    private var tempBufferOffset = 0
    
    internal init(stream: NSInputStream, endian: Endian = .Unknown, closeOnDeinit: Bool = true) throws {
        var endian = endian

        if stream.streamStatus == .NotOpen {
            stream.open()
        }
        if stream.streamStatus != .Open {
            throw CSVError.CannotOpenFile
        }

        let readCount = stream.read(&tempBuffer, maxLength: tempBufferSize)
        if let (e, l) = readBOM(buffer: &tempBuffer, length: readCount) {
            if endian != .Unknown && endian != e {
                throw CSVError.StringEndianMismatch
            }
            endian = e
            tempBufferOffset = l
        }

        self.stream = stream
        self.endian = endian
        self.closeOnDeinit = closeOnDeinit
    }
    
    deinit {
        if closeOnDeinit && stream.streamStatus != .Closed {
            stream.close()
        }
    }

    internal var hasBytesAvailable: Bool {
        return stream.hasBytesAvailable
    }

    private func readStream(buffer: UnsafeMutablePointer<UInt8>, maxLength: Int) throws -> Int {
        if stream.streamStatus != .Open {
            throw CSVError.CannotReadFile
        }

        var i = 0
        while tempBufferOffset < tempBufferSize {
            buffer[i] = tempBuffer[tempBufferOffset]
            i += 1
            tempBufferOffset += 1
            if i >= maxLength {
                return i
            }
        }
        return stream.read(buffer + i, maxLength: maxLength - i)
    }
    
    internal func readUInt8() throws -> UInt8 {
        let bufferSize = 1
        let length = try readStream(&buffer, maxLength: bufferSize)
        if length < 0 {
            throw CSVError.StreamErrorHasOccurred(error: stream.streamError!)
        }
        if length != bufferSize {
            throw CSVError.CannotReadFile
        }
        return buffer[0]
    }
    
    internal func readUInt16() throws -> UInt16 {
        let bufferSize = 2
        let length = try readStream(&buffer, maxLength: bufferSize)
        if length < 0 {
            throw CSVError.StreamErrorHasOccurred(error: stream.streamError!)
        }
        if length != bufferSize {
            throw CSVError.StringEncodingMismatch
        }
        let tmp = UnsafeMutablePointer<UInt16>(buffer)
        switch endian {
        case .Big:
            return CFSwapInt16BigToHost(tmp[0])
        case .Little:
            return CFSwapInt16LittleToHost(tmp[0])
        default:
            throw CSVError.StringEndianMismatch
        }
    }
    
    internal func readUInt32() throws -> UInt32 {
        let bufferSize = 4
        let length = try readStream(&buffer, maxLength: bufferSize)
        if length < 0 {
            throw CSVError.StreamErrorHasOccurred(error: stream.streamError!)
        }
        if length != 4 {
            throw CSVError.StringEncodingMismatch
        }
        let tmp = UnsafeMutablePointer<UInt32>(buffer)
        switch endian {
        case .Big:
            return CFSwapInt32BigToHost(tmp[0])
        case .Little:
            return CFSwapInt32LittleToHost(tmp[0])
        default:
            throw CSVError.StringEndianMismatch
        }
    }
    
}

extension BinaryReader {

    internal struct UInt8Iterator: SequenceType, GeneratorType {
        
        private let reader: BinaryReader
        
        private init(reader: BinaryReader) {
            self.reader = reader
        }
        
        internal mutating func next() -> UInt8? {
            if !reader.hasBytesAvailable {
                return nil
            }
            do {
                return try reader.readUInt8()
            }
            catch /*let error*/ {
                return nil
            }
        }
        
    }
    
    internal func makeUInt8Iterator() -> UInt8Iterator {
        return UInt8Iterator(reader: self)
    }

}

extension BinaryReader {
    
    internal struct UInt16Iterator: SequenceType, GeneratorType {
        
        private let reader: BinaryReader
        
        private init(reader: BinaryReader) {
            self.reader = reader
        }
        
        internal mutating func next() -> UInt16? {
            if !reader.hasBytesAvailable {
                return nil
            }
            do {
                return try reader.readUInt16()
            }
            catch /*let error*/ {
                return nil
            }
        }

    }
    
    internal func makeUInt16Iterator() -> UInt16Iterator {
        return UInt16Iterator(reader: self)
    }
    
}

extension BinaryReader {

    internal struct UInt32Iterator: SequenceType, GeneratorType {

        private let reader: BinaryReader

        private init(reader: BinaryReader) {
            self.reader = reader
        }

        internal mutating func next() -> UInt32? {
            if !reader.hasBytesAvailable {
                return nil
            }
            do {
                return try reader.readUInt32()
            }
            catch /*let error*/ {
                return nil
            }
        }

    }

    internal func makeUInt32Iterator() -> UInt32Iterator {
        return UInt32Iterator(reader: self)
    }

}
