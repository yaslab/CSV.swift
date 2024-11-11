//
//  CSVReader.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/11.
//  Copyright © 2016 yaslab. All rights reserved.
//

import Foundation

public struct CSVReader<S> where S: Sequence<Result<UTF8.CodeUnit, CSVError>> {
    let sequence: S
    public var configuration: CSVReaderConfiguration

    public init(
        sequence: consuming S,
        hasHeaderRow: Bool = false,
        trimFields: Bool = false,
        delimiter: UTF8.CodeUnit = .comma,
        whitespaces: Set<UTF8.CodeUnit> = [.horizontalTabulation, .space, .noBreakSpace]
    ) {
        self.sequence = sequence
        self.configuration = CSVReaderConfiguration(hasHeaderRow: hasHeaderRow, trimFields: trimFields, delimiter: delimiter, whitespaces: whitespaces)
    }
}

extension CSVReader where S == BinaryReader {
    public init(
        fileAtPath path: String,
        hasHeaderRow: Bool = false,
        trimFields: Bool = false,
        delimiter: UTF8.CodeUnit = .comma,
        whitespaces: Set<UTF8.CodeUnit> = [.horizontalTabulation, .space, .noBreakSpace],
        bufferSize: Int = 4096
    ) {
        let seq = BinaryReader(url: URL(fileURLWithPath: path), bufferSize: bufferSize)
        self.init(sequence: seq, hasHeaderRow: hasHeaderRow, trimFields: trimFields, delimiter: delimiter, whitespaces: whitespaces)
    }

    public init(
        url: URL,
        hasHeaderRow: Bool = false,
        trimFields: Bool = false,
        delimiter: UTF8.CodeUnit = .comma,
        whitespaces: Set<UTF8.CodeUnit> = [.horizontalTabulation, .space, .noBreakSpace],
        bufferSize: Int = 4096
    ) {
        let seq = BinaryReader(url: url, bufferSize: bufferSize)
        self.init(sequence: seq, hasHeaderRow: hasHeaderRow, trimFields: trimFields, delimiter: delimiter, whitespaces: whitespaces)
    }
}

extension CSVReader where S == StringSequence {
    public init(
        data: consuming Data,
        hasHeaderRow: Bool = false,
        trimFields: Bool = false,
        delimiter: UTF8.CodeUnit = .comma,
        whitespaces: Set<UTF8.CodeUnit> = [.horizontalTabulation, .space, .noBreakSpace]
    ) {
        let seq = StringSequence(data: data)
        self.init(sequence: seq, hasHeaderRow: hasHeaderRow, trimFields: trimFields, delimiter: delimiter, whitespaces: whitespaces)
    }

    public init(
        string: consuming String,
        hasHeaderRow: Bool = false,
        trimFields: Bool = false,
        delimiter: UTF8.CodeUnit = .comma,
        whitespaces: Set<UTF8.CodeUnit> = [.horizontalTabulation, .space, .noBreakSpace]
    ) {
        let seq = StringSequence(string: string)
        self.init(sequence: seq, hasHeaderRow: hasHeaderRow, trimFields: trimFields, delimiter: delimiter, whitespaces: whitespaces)
    }
}

extension CSVReader: Sequence {
    public class Iterator: IteratorProtocol {
        var it: S.Iterator
        let configuration: CSVReaderConfiguration
        var parser = CSVParser()
        var header: [String]? = nil
        var isEOF = false
        var row = 0

        init(it: consuming S.Iterator, configuration: consuming CSVReaderConfiguration) {
            self.it = it
            self.configuration = configuration
        }

        public func next() -> Result<CSVRow, CSVError>? {
            if isEOF {
                return nil
            }

            row += 1

            do {
                if row == 1, configuration.hasHeaderRow {
                    if let columns = try parse() {
                        header = columns
                    } else {
                        isEOF = true
                        return .failure(CSVError.cannotReadHeaderRow)
                    }
                }

                if let columns = try parse() {
                    return .success(CSVRow(header: header, columns: columns))
                } else {
                    isEOF = true
                    return nil
                }
            } catch {
                isEOF = true
                return .failure(error)
            }
        }

        func parse() throws(CSVError) -> [String]? {
            var columns = [String]()
            while true {
                switch try parser.parse(&it, configuration: configuration) {
                case .columnByDelimiter(let column):
                    columns.append(column)
                case .columnByNewLine(let column):
                    columns.append(column)
                    return columns
                case .columnByEOF(let column):
                    columns.append(column)
                    return columns
                case .emptyInput:
                    if columns.isEmpty {
                        return nil
                    } else {
                        columns.append("")
                        return columns
                    }
                }
            }
        }
    }

    public func makeIterator() -> Iterator {
        Iterator(it: sequence.makeIterator(), configuration: configuration.copy())
    }
}

extension CSVReader: Sendable where S: Sendable {}
