//
//  CSVStringSequence.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2024/07/20.
//  Copyright © 2024 yaslab. All rights reserved.
//

import Foundation

public class CSVStringSequence {
    let _bytes: UnsafePointer<UInt8>
    let _count: Int

    init(data: consuming Data) {
        (_bytes, _count) = data.withUnsafeBytes { raw in
            raw.withMemoryRebound(to: UInt8.self) { buffer in
                let bytes = UnsafeMutablePointer<UInt8>.allocate(capacity: buffer.count)
                bytes.initialize(from: buffer.baseAddress.unsafelyUnwrapped, count: buffer.count)
                return (UnsafePointer(bytes), buffer.count)
            }
        }
    }

    init(string: consuming String) {
        (_bytes, _count) = string.withUTF8 { buffer in
            let bytes = UnsafeMutablePointer<UInt8>.allocate(capacity: buffer.count)
            bytes.initialize(from: buffer.baseAddress.unsafelyUnwrapped, count: buffer.count)
            return (UnsafePointer(bytes), buffer.count)
        }
    }

    deinit {
        _bytes.deallocate()
    }
}

extension CSVStringSequence: Sequence {
    public class Iterator: IteratorProtocol {
        let bytes: UnsafePointer<UInt8>
        let count: Int
        var position = 0

        init(bytes: UnsafePointer<UInt8>, count: Int) {
            self.bytes = bytes
            self.count = count
        }

        public func next() -> Result<UTF8.CodeUnit, CSVError>? {
            if count <= position {
                return nil
            }

            defer { position += 1 }

            return .success(bytes.advanced(by: position).pointee)
        }
    }

    public func makeIterator() -> Iterator {
        Iterator(bytes: _bytes, count: _count)
    }
}
