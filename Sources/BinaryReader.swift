//
//  BinaryReader.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/20.
//  Copyright © 2016年 yaslab. All rights reserved.
//

import Foundation

class BinaryReader {
    
    enum Endian {
        case big
        case little
    }
    
    let stream: InputStream
    let endian: Endian
    let closeOnDeinit: Bool
    
    init(stream: InputStream, endian: Endian = .big, closeOnDeinit: Bool = true) {
        self.stream = stream
        self.endian = endian
        self.closeOnDeinit = closeOnDeinit

        if stream.streamStatus == .notOpen {
            stream.open()
        }
    }
    
    deinit {
        if closeOnDeinit && stream.streamStatus == .open {
            stream.close()
        }
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
        let length = stream.read(&buffer, maxLength: bufferSize)
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
        let length = stream.read(&buffer, maxLength: bufferSize)
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
        }
    }
    
    func readUInt32() throws -> UInt32 {
        let bufferSize = 4
        var buffer = [UInt8](repeating: 0, count: bufferSize)
        let length = stream.read(&buffer, maxLength: bufferSize)
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
        }
    }
    
}

extension BinaryReader {

    struct UInt8Iterator: Sequence, IteratorProtocol {
        
        let reader: BinaryReader
        
        private init(reader: BinaryReader) {
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
    
    struct UInt16Iterator: IteratorProtocol {
        
        let reader: BinaryReader
        
        private init(reader: BinaryReader) {
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
