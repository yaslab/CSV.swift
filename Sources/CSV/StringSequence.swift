//
//  StringSequence.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2024/07/20.
//  Copyright © 2024 yaslab. All rights reserved.
//

import Foundation

public class StringSequence {
    let _buffer: UnsafeMutableBufferPointer<UInt8>

    init(data: consuming Data) {
        _buffer = data.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) in
            let mem = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: buffer.count)
            _ = mem.initialize(fromContentsOf: buffer)
            return mem
        }
    }

    init(string: consuming String) {
        _buffer = string.withUTF8 { buffer in
            let mem = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: buffer.count)
            _ = mem.initialize(fromContentsOf: buffer)
            return mem
        }
    }

    deinit {
        _buffer.deallocate()
    }
}

extension StringSequence: Sequence {
    public class Iterator: IteratorProtocol {
        let buffer: UnsafeBufferPointer<UInt8>
        var position = 0

        init(buffer: UnsafeBufferPointer<UInt8>) {
            self.buffer = buffer
        }

        public func next() -> Result<UTF8.CodeUnit, CSVError>? {
            if buffer.count <= position {
                return nil
            }

            defer { position += 1 }

            return .success(buffer[position])
        }
    }

    public func makeIterator() -> Iterator {
        Iterator(buffer: UnsafeBufferPointer(_buffer))
    }
}
