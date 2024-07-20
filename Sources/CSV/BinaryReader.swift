//
//  BinaryReader.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/20.
//  Copyright © 2016 yaslab. All rights reserved.
//

import Foundation

public struct BinaryReader: Sendable {
    let url: URL
    let bufferSize: Int
}

extension BinaryReader: Sequence {
    public class Iterator: IteratorProtocol {
        let stream: InputStream?
        var isEOF = false
        var isError = false

        let buffer: UnsafeMutablePointer<UTF8.CodeUnit>
        let bufferSize: Int
        var _position = 0
        var _count = 0

        var isFirst = true

        init(url: URL, bufferSize size: Int) {
            stream = InputStream(url: url)
            stream?.open()

            let capacity = Swift.max(8, size)
            buffer = UnsafeMutablePointer.allocate(capacity: capacity)
            bufferSize = capacity
        }

        deinit {
            stream?.close()
            buffer.deallocate()
        }

        public func next() -> Result<UTF8.CodeUnit, CSVError>? {
            guard !isEOF, !isError else {
                return nil
            }

            if _count <= _position {
                guard let stream else {
                    isError = true
                    return .failure(.cannotOpenFile)
                }

                guard case .open = stream.streamStatus else {
                    isError = true
                    return .failure(.cannotOpenFile)
                }

                let result = stream.read(buffer, maxLength: bufferSize)
                if result == 0 {
                    isEOF = true
                    return nil
                } else if result < 0 {
                    isError = true
                    if let error = stream.streamError {
                        return .failure(.streamErrorHasOccurred(error: error))
                    } else {
                        return .failure(.cannotReadFile)
                    }
                }

                _count = result
                _position = 0

                // Skip UTF-8 BOM (0xef, 0xbb, 0xbf)
                if isFirst, _count >= 3, buffer[0] == 0xef, buffer[1] == 0xbb, buffer[2] == 0xbf {
                    _position += 3
                }

                isFirst = false
            }

            defer { _position += 1 }

            return .success(buffer[_position])
        }
    }

    public func makeIterator() -> Iterator {
        Iterator(url: url, bufferSize: bufferSize)
    }
}
