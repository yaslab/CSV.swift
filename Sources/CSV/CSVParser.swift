//
//  CSVParser.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2024/07/16.
//  Copyright © 2024 yaslab. All rights reserved.
//

import Foundation

enum CSVParser {
    enum ParseResult {
        case columnByDelimiter(String)
        case columnByNewLine(String)
        case columnByEOF(String)
        case emptyInput
    }

    case state(UTF8.CodeUnit?)

    init() {
        self = .state(nil)
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
        var string = [UTF8.CodeUnit]()

        func get() -> String {
            String(decoding: string, as: UTF8.self)
        }

        while let char = try _next(&input) {
            if char == .quotationMark {  // '"'
                guard var next = try _next(&input) else {
                    return .columnByEOF(get())
                }

                if next == .quotationMark {  // '"' (ESC)
                    string.append(next)
                    continue
                }

                if configuration.trimFields {
                    while configuration.whitespaces.contains(next) {  // ' '
                        guard let next2 = try _next(&input) else {
                            return .columnByEOF(get())
                        }
                        next = next2
                    }
                }

                if next == configuration.delimiter {  // ','
                    return .columnByDelimiter(get())
                } else if next == .newLine || next == .carriageReturn {  // LF or CR
                    if next == .carriageReturn {  // CR
                        if let nextNext = try _next(&input) {
                            if nextNext != .newLine {  // LF
                                _prev(nextNext)
                            }
                        }
                    }
                    return .columnByNewLine(get())
                } else {
                    throw CSVError.invalidCSVFormat
                }
            } else {
                string.append(char)
            }
        }

        return .columnByEOF(get())
    }

    private mutating func column(
        _ input: inout some IteratorProtocol<Result<UTF8.CodeUnit, CSVError>>,
        configuration: borrowing CSVReaderConfiguration
    ) throws(CSVError) -> ParseResult {
        var string = [UTF8.CodeUnit]()
        var count = 0

        func get() -> String {
            if configuration.trimFields {
                return String(decoding: string[0 ..< count], as: UTF8.self)
            } else {
                return String(decoding: string, as: UTF8.self)
            }
        }

        while let char = try _next(&input) {
            if char == configuration.delimiter {  // ','
                return .columnByDelimiter(get())
            } else if char == .newLine || char == .carriageReturn {  // LF or CR
                if char == .carriageReturn {  // CR
                    if let next = try _next(&input) {
                        if next != .newLine {  // LF
                            _prev(next)
                        }
                    }
                }
                return .columnByNewLine(get())
            } else {
                string.append(char)
                if configuration.trimFields, !configuration.whitespaces.contains(char) {  // ' '
                    count = string.count
                }
            }
        }

        return .columnByEOF(get())
    }

    private mutating func _next(
        _ input: inout some IteratorProtocol<Result<UTF8.CodeUnit, CSVError>>
    ) throws(CSVError) -> UTF8.CodeUnit? {
        if case .state(let char) = self, let char {
            self = .state(nil)
            return char
        } else if let next = input.next() {
            return try next.get()
        } else {
            return nil
        }
    }

    private mutating func _prev(_ char: UTF8.CodeUnit) {
        self = .state(char)
    }
}
