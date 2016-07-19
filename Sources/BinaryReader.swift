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

private func readBOM(buffer: UnsafePointer<UInt8>, length: Int) -> (Endian, Int)? {
    if length >= 4 {
        if memcmp(buffer, utf32BigEndianBOM, 4) == 0 {
            return (.big, 4)
        }
        if memcmp(buffer, utf32LittleEndianBOM, 4) == 0 {
            return (.little, 4)
        }
    }
    if length >= 3 {
        if memcmp(buffer, utf8BOM, 3) == 0 {
            return (.unknown, 3)
        }
    }
    if length >= 2 {
        if memcmp(buffer, utf16BigEndianBOM, 2) == 0 {
            return (.big, 2)
        }
        if memcmp(buffer, utf16LittleEndianBOM, 2) == 0 {
            return (.little, 2)
        }
    }
    return nil
}

internal class BinaryReader {

    private let stream: InputStream
    private let endian: Endian
    private let closeOnDeinit: Bool

    private var buffer = [UInt8].init(repeating: 0, count: 4)
    private let bufferSize = 4
    private var bufferOffset = 0
    
    internal init(stream: InputStream, endian: Endian = .unknown, closeOnDeinit: Bool = true) {
        var endian = endian

        if stream.streamStatus == .notOpen {
            stream.open()
        }

        let readCount = stream.read(&buffer, maxLength: bufferSize)
        if let (e, l) = readBOM(buffer: &buffer, length: readCount) {
            endian = e
            bufferOffset = l
        }

        self.stream = stream
        self.endian = endian
        self.closeOnDeinit = closeOnDeinit
    }
    
    deinit {
        if closeOnDeinit && stream.streamStatus != .closed {
            stream.close()
        }
    }

    private func readStream(_ buffer: UnsafeMutablePointer<UInt8>, maxLength: Int) -> Int {
        var i = 0
        while bufferOffset < bufferSize {
            buffer[i] = self.buffer[bufferOffset]
            i += 1
            bufferOffset += 1
            if i >= maxLength {
                return i
            }
        }
        return stream.read(buffer + i, maxLength: maxLength - i)
    }
    
    internal func readUInt8() throws -> UInt8 {
//        if stream.streamStatus == .Closed {
//            // ObjectDisposedException
//            throw NSError(domain: "", code: 0, userInfo: nil)
//        }
//        if stream.streamStatus == .AtEnd {
//            // EndOfStreamException
//            throw NSError(domain: "", code: 0, userInfo: nil)
//        }
        let bufferSize = 1
        var buffer = [UInt8](repeating: 0, count: bufferSize)
        let length = readStream(&buffer, maxLength: bufferSize)
        if length < 0 {
            // IOException
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        if length != bufferSize {
            // EndOfStreamException
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        return buffer[0]
    }
    
    internal func readUInt16() throws -> UInt16 {
        let bufferSize = 2
        var buffer = [UInt8](repeating: 0, count: bufferSize)
        let length = readStream(&buffer, maxLength: bufferSize)
        if length < 0 {
            // IOException
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        if length != bufferSize {
            // EndOfStreamException
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        let tmp = UnsafeMutablePointer<UInt16>(buffer)
        switch endian {
        case .big:
            return CFSwapInt16BigToHost(tmp[0])
        case .little:
            return CFSwapInt16LittleToHost(tmp[0])
        default:
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
    }
    
    internal func readUInt32() throws -> UInt32 {
        let bufferSize = 4
        var buffer = [UInt8](repeating: 0, count: bufferSize)
        let length = readStream(&buffer, maxLength: bufferSize)
        if length < 0 {
            // IOException
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        if length != 4 {
            // EndOfStreamException
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        let tmp = UnsafeMutablePointer<UInt32>(buffer)
        switch endian {
        case .big:
            return CFSwapInt32BigToHost(tmp[0])
        case .little:
            return CFSwapInt32LittleToHost(tmp[0])
        default:
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
    }
    
}

extension BinaryReader {

    internal struct UInt8Iterator: Sequence, IteratorProtocol {
        
        private let reader: BinaryReader
        
        private init(reader: BinaryReader) {
            self.reader = reader
        }
        
        internal mutating func next() -> UInt8? {
            return try? reader.readUInt8()
        }
        
    }
    
    internal func makeUInt8Iterator() -> UInt8Iterator {
        return UInt8Iterator(reader: self)
    }

}

extension BinaryReader {
    
    internal struct UInt16Iterator: Sequence, IteratorProtocol {
        
        private let reader: BinaryReader
        
        private init(reader: BinaryReader) {
            self.reader = reader
        }
        
        internal mutating func next() -> UInt16? {
            return try? reader.readUInt16()
        }
        
    }
    
    internal func makeUInt16Iterator() -> UInt16Iterator {
        return UInt16Iterator(reader: self)
    }
    
}

extension BinaryReader {

    internal struct UInt32Iterator: Sequence, IteratorProtocol {

        private let reader: BinaryReader

        private init(reader: BinaryReader) {
            self.reader = reader
        }

        internal mutating func next() -> UInt32? {
            return try? reader.readUInt32()
        }

    }

    internal func makeUInt32Iterator() -> UInt32Iterator {
        return UInt32Iterator(reader: self)
    }

}
