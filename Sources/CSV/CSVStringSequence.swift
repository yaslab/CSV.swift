//
//  CSVStringSequence.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2024/07/20.
//  Copyright © 2024 yaslab. All rights reserved.
//

import Foundation

public class CSVStringSequence {
    let bytes: UnsafePointer<UInt8>
    let count: Int
    var position = 0

    private init(bytes: UnsafePointer<UInt8>, count: Int) {
        self.bytes = bytes
        self.count = count
    }

    deinit {
        bytes.deallocate()
    }
}

extension CSVStringSequence {
    convenience init(data: consuming Data) {
        let (_bytes, _count) = data.withUnsafeBytes { raw in
            raw.withMemoryRebound(to: UInt8.self) { buffer in
                let bytes = UnsafeMutablePointer<UInt8>.allocate(capacity: buffer.count)
                bytes.initialize(from: buffer.baseAddress.unsafelyUnwrapped, count: buffer.count)
                return (UnsafePointer(bytes), buffer.count)
            }
        }
        self.init(bytes: _bytes, count: _count)
    }

    convenience init(string: consuming String) {
        let (_bytes, _count) = string.withUTF8 { buffer in
            let bytes = UnsafeMutablePointer<UInt8>.allocate(capacity: buffer.count)
            bytes.initialize(from: buffer.baseAddress.unsafelyUnwrapped, count: buffer.count)
            return (UnsafePointer(bytes), buffer.count)
        }
        self.init(bytes: _bytes, count: _count)
    }
}

extension CSVStringSequence: Sequence, IteratorProtocol {
    public func next() -> Result<UTF8.CodeUnit, CSVError>? {
        if count <= position {
            return nil
        }

        defer { position += 1 }

        return .success(bytes.advanced(by: position).pointee)
    }
}
