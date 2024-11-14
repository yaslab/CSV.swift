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
        configuration: CSVReaderConfiguration = .default()
    ) {
        self.sequence = sequence
        self.configuration = configuration
    }
}

extension CSVReader where S == CSVFileSequence {
    public init(
        fileAtPath path: String,
        configuration: CSVReaderConfiguration = .default(),
        bufferSize: Int = 4096
    ) {
        let seq = CSVFileSequence(url: URL(fileURLWithPath: path), bufferSize: bufferSize)
        self.init(sequence: seq, configuration: configuration)
    }

    public init(
        url: URL,
        configuration: CSVReaderConfiguration = .default(),
        bufferSize: Int = 4096
    ) {
        let seq = CSVFileSequence(url: url, bufferSize: bufferSize)
        self.init(sequence: seq, configuration: configuration)
    }
}

extension CSVReader where S == CSVStringSequence {
    public init(
        data: consuming Data,
        configuration: CSVReaderConfiguration = .default()
    ) {
        let seq = CSVStringSequence(data: data)
        self.init(sequence: seq, configuration: configuration)
    }

    public init(
        string: consuming String,
        configuration: CSVReaderConfiguration = .default()
    ) {
        let seq = CSVStringSequence(string: string)
        self.init(sequence: seq, configuration: configuration)
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
