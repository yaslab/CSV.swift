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

    private var buffer = malloc(4).assumingMemoryBound(to: UInt8.self)

    private var tempBuffer = malloc(4).assumingMemoryBound(to: UInt8.self)
    private let tempBufferSize = 4
    private var tempBufferOffset = 0

    internal init(
        stream: InputStream,
        endian: Endian,
        closeOnDeinit: Bool) throws {

        var endian = endian

        if stream.streamStatus == .notOpen {
            stream.open()
        }
        if stream.streamStatus != .open {
            throw CSVError.cannotOpenFile
        }

        let readCount = stream.read(tempBuffer, maxLength: tempBufferSize)
        if let (e, l) = readBOM(buffer: tempBuffer, length: readCount) {
            if endian != .unknown && endian != e {
                throw CSVError.stringEndianMismatch
            }
            endian = e
            tempBufferOffset = l
        }

        self.stream = stream
        self.endian = endian
        self.closeOnDeinit = closeOnDeinit
    }

    deinit {
        if closeOnDeinit && stream.streamStatus != .closed {
            stream.close()
        }
        free(buffer)
        free(tempBuffer)
    }

    internal var hasBytesAvailable: Bool {
        return stream.hasBytesAvailable
    }

    private func readStream(_ buffer: UnsafeMutablePointer<UInt8>, maxLength: Int) throws -> Int {
        if stream.streamStatus != .open {
            throw CSVError.cannotReadFile
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
        let length = try readStream(buffer, maxLength: bufferSize)
        if length < 0 {
            throw CSVError.streamErrorHasOccurred(error: stream.streamError!)
        }
        if length != bufferSize {
            throw CSVError.cannotReadFile
        }
        return buffer[0]
    }

    internal func readUInt16() throws -> UInt16 {
        let bufferSize = 2
        let length = try readStream(buffer, maxLength: bufferSize)
        if length < 0 {
            throw CSVError.streamErrorHasOccurred(error: stream.streamError!)
        }
        if length != bufferSize {
            throw CSVError.stringEncodingMismatch
        }
        return try buffer.withMemoryRebound(to: UInt16.self, capacity: 1) {
            switch endian {
            case .big:
                return UInt16(bigEndian: $0[0])
            case .little:
                return UInt16(littleEndian: $0[0])
            default:
                throw CSVError.stringEndianMismatch
            }
        }
    }

    internal func readUInt32() throws -> UInt32 {
        let bufferSize = 4
        let length = try readStream(buffer, maxLength: bufferSize)
        if length < 0 {
            throw CSVError.streamErrorHasOccurred(error: stream.streamError!)
        }
        if length != bufferSize {
            throw CSVError.stringEncodingMismatch
        }
        return try buffer.withMemoryRebound(to: UInt32.self, capacity: 1) {
            switch endian {
            case .big:
                return UInt32(bigEndian: $0[0])
            case .little:
                return UInt32(littleEndian: $0[0])
            default:
                throw CSVError.stringEndianMismatch
            }
        }
    }

}

extension BinaryReader {

    internal class UInt8Iterator: Sequence, IteratorProtocol {

        private let reader: BinaryReader
        internal var errorHandler: ((Error) -> Void)?

        fileprivate init(reader: BinaryReader) {
            self.reader = reader
        }

        internal func next() -> UInt8? {
            if !reader.hasBytesAvailable {
                return nil
            }
            do {
                return try reader.readUInt8()
            } catch {
                errorHandler?(error)
                return nil
            }
        }

    }

    internal func makeUInt8Iterator() -> UInt8Iterator {
        return UInt8Iterator(reader: self)
    }

}

extension BinaryReader {

    internal class UInt16Iterator: Sequence, IteratorProtocol {

        private let reader: BinaryReader
        internal var errorHandler: ((Error) -> Void)?

        fileprivate init(reader: BinaryReader) {
            self.reader = reader
        }

        internal func next() -> UInt16? {
            if !reader.hasBytesAvailable {
                return nil
            }
            do {
                return try reader.readUInt16()
            } catch {
                errorHandler?(error)
                return nil
            }
        }

    }

    internal func makeUInt16Iterator() -> UInt16Iterator {
        return UInt16Iterator(reader: self)
    }

}

extension BinaryReader {

    internal class UInt32Iterator: Sequence, IteratorProtocol {

        private let reader: BinaryReader
        internal var errorHandler: ((Error) -> Void)?

        fileprivate init(reader: BinaryReader) {
            self.reader = reader
        }

        internal func next() -> UInt32? {
            if !reader.hasBytesAvailable {
                return nil
            }
            do {
                return try reader.readUInt32()
            } catch {
                errorHandler?(error)
                return nil
            }
        }

    }

    internal func makeUInt32Iterator() -> UInt32Iterator {
        return UInt32Iterator(reader: self)
    }

}
