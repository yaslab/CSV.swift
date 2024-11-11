//
//  CSVParser.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2024/07/16.
//  Copyright © 2024 yaslab. All rights reserved.
//

import Foundation

struct UTF8Array: ~Copyable {
    private(set) var bytes: UnsafeMutablePointer<UInt8>
    private var capacity = 8
    private(set) var count = 0

    init() {
        bytes = UnsafeMutablePointer<UInt8>.allocate(capacity: capacity)
        bytes.initialize(repeating: 0, count: capacity)
    }

    deinit {
        bytes.deallocate()
    }

    mutating func append(_ value: consuming UInt8) {
        if capacity <= count {
            let newCapacity = capacity * 2
            let newBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: newCapacity)
            newBytes.moveInitialize(from: bytes, count: count)
            newBytes.advanced(by: count).initialize(repeating: 0, count: newCapacity - count)
            bytes.deallocate()
            bytes = newBytes
            capacity = newCapacity
        }
        bytes[count] = value
        count += 1
    }

    mutating func removeAll() {
        count = 0
    }

    func string(maxLength: consuming Int = .max) -> String {
        let length = min(count, maxLength)
        return String(unsafeUninitializedCapacity: length) {
            $0.baseAddress.unsafelyUnwrapped.initialize(from: bytes, count: length)
            return length
        }
    }
}

struct CSVParser: ~Copyable {
    var state: UTF8.CodeUnit?
    var array = UTF8Array()

    enum ParseResult {
        case columnByDelimiter(String)
        case columnByNewLine(String)
        case columnByEOF(String)
        case emptyInput
    }

    mutating func parse(
        _ input: inout some IteratorProtocol<Result<UTF8.CodeUnit, CSVError>>,
        configuration: borrowing CSVReaderConfiguration
    ) throws(CSVError) -> ParseResult {
        guard var char = try _next(&input) else {
            return .emptyInput
        }

        if configuration.trimFields {
            while configuration.whitespaces.contains(char) {  // ' '
                guard let next = try _next(&input) else {
                    return .columnByEOF("")
                }
                char = next
            }
        }

        if char == .quotationMark {  // '"'
            return try columnWithQuotationMark(&input, configuration: configuration)
        } else {
            _prev(char)
            return try column(&input, configuration: configuration)
        }
    }

    private mutating func columnWithQuotationMark(
        _ input: inout some IteratorProtocol<Result<UTF8.CodeUnit, CSVError>>,
        configuration: borrowing CSVReaderConfiguration
    ) throws(CSVError) -> ParseResult {
        array.removeAll()

        while let char = try _next(&input) {
            if char == .quotationMark {  // '"'
                guard var next = try _next(&input) else {
                    return .columnByEOF(array.string())
                }

                if next == .quotationMark {  // '"' (ESC)
                    array.append(next)
                    continue
                }

                if configuration.trimFields {
                    while configuration.whitespaces.contains(next) {  // ' '
                        guard let next2 = try _next(&input) else {
                            return .columnByEOF(array.string())
                        }
                        next = next2
                    }
                }

                if next == configuration.delimiter {  // ','
                    return .columnByDelimiter(array.string())
                } else if next == .newLine || next == .carriageReturn {  // LF or CR
                    if next == .carriageReturn {  // CR
                        if let nextNext = try _next(&input) {
                            if nextNext != .newLine {  // LF
                                _prev(nextNext)
                            }
                        }
                    }
                    return .columnByNewLine(array.string())
                } else {
                    throw CSVError.invalidCSVFormat
                }
            } else {
                array.append(char)
            }
        }

        return .columnByEOF(array.string())
    }

    private mutating func column(
        _ input: inout some IteratorProtocol<Result<UTF8.CodeUnit, CSVError>>,
        configuration: borrowing CSVReaderConfiguration
    ) throws(CSVError) -> ParseResult {
        var count = 0

        array.removeAll()

        func string() -> String {
            array.string(maxLength: configuration.trimFields ? count : .max)
        }

        while let char = try _next(&input) {
            if char == configuration.delimiter {  // ','
                return .columnByDelimiter(string())
            } else if char == .newLine || char == .carriageReturn {  // LF or CR
                if char == .carriageReturn {  // CR
                    if let next = try _next(&input) {
                        if next != .newLine {  // LF
                            _prev(next)
                        }
                    }
                }
                return .columnByNewLine(string())
            } else {
                array.append(char)
                if configuration.trimFields, !configuration.whitespaces.contains(char) {  // ' '
                    count = array.count
                }
            }
        }

        return .columnByEOF(string())
    }

    private mutating func _next(
        _ input: inout some IteratorProtocol<Result<UTF8.CodeUnit, CSVError>>
    ) throws(CSVError) -> UTF8.CodeUnit? {
        if let char = state {
            state = nil
            return char
        } else if let next = input.next() {
            return try next.get()
        } else {
            return nil
        }
    }

    private mutating func _prev(_ char: consuming UTF8.CodeUnit) {
        state = char
    }
}
