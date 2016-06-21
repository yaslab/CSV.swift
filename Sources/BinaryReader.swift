//
//  BinaryReader.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/20.
//  Copyright © 2016年 yaslab. All rights reserved.
//

import Foundation

internal func readBOM(buffer: UnsafePointer<UInt8>, length: Int) -> (String.Encoding, Int)? {
    if length >= 4 {
        if memcmp(buffer, utf32BigEndianBOM, 4) == 0 {
            return (String.Encoding.utf32BigEndian, 4)
        }
        if memcmp(buffer, utf32LittleEndianBOM, 4) == 0 {
            return (String.Encoding.utf32LittleEndian, 4)
        }
    }
    if length >= 3 {
        if memcmp(buffer, utf8BOM, 3) == 0 {
            return (String.Encoding.utf8, 3)
        }
    }
    if length >= 2 {
        if memcmp(buffer, utf16BigEndianBOM, 2) == 0 {
            return (String.Encoding.utf16BigEndian, 2)
        }
        if memcmp(buffer, utf16LittleEndianBOM, 2) == 0 {
            return (String.Encoding.utf16LittleEndian, 2)
        }
    }
    return nil
}

internal class BinaryReader {

    private let stream: InputStream
    private let encoding: String.Encoding
    private let closeOnDeinit: Bool

    private var buffer = [UInt8].init(repeating: 0, count: 4)
    private let bufferSize = 4
    private var bufferOffset = 0
    
    init(stream: InputStream, encoding: String.Encoding = .utf8, closeOnDeinit: Bool = true) {
        var encoding = encoding

        if stream.streamStatus == .notOpen {
            stream.open()
        }

        let readCount = stream.read(&buffer, maxLength: bufferSize)
        if let (e, l) = readBOM(buffer: &buffer, length: readCount) {
            encoding = e
            bufferOffset = l
        }

        self.stream = stream
        self.encoding = encoding
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
    
    func readUInt8() throws -> UInt8 {
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
    
    func readUInt16() throws -> UInt16 {
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
        switch encoding.endian {
        case .big:
            return CFSwapInt16BigToHost(tmp[0])
        case .little:
            return CFSwapInt16LittleToHost(tmp[0])
        default:
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
    }
    
    func readUInt32() throws -> UInt32 {
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
        switch encoding.endian {
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

    struct UInt8Iterator: Sequence, IteratorProtocol {
        
        let reader: BinaryReader
        
        init(reader: BinaryReader) {
            self.reader = reader
        }
        
        mutating func next() -> UInt8? {
            return try? reader.readUInt8()
        }
        
    }
    
    func makeUInt8Iterator() -> UInt8Iterator {
        return UInt8Iterator(reader: self)
    }

}

extension BinaryReader {
    
    struct UInt16Iterator: Sequence, IteratorProtocol {
        
        let reader: BinaryReader
        
        init(reader: BinaryReader) {
            self.reader = reader
        }
        
        mutating func next() -> UInt16? {
            return try? reader.readUInt16()
        }
        
    }
    
    func makeUInt16Iterator() -> UInt16Iterator {
        return UInt16Iterator(reader: self)
    }
    
}

extension BinaryReader {

    struct UInt32Iterator: Sequence, IteratorProtocol {

        let reader: BinaryReader

        init(reader: BinaryReader) {
            self.reader = reader
        }

        mutating func next() -> UInt32? {
            return try? reader.readUInt32()
        }

    }

    func makeUInt32Iterator() -> UInt32Iterator {
        return UInt32Iterator(reader: self)
    }

}
