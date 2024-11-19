//
//  CSVReader.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/11.
//  Copyright © 2016 yaslab. All rights reserved.
//

// build command:
// swift build -Xswiftc "-swift-version" -Xswiftc "5" -Xswiftc "-strict-concurrency=complete"
// swift build -Xswiftc "-swift-version" -Xswiftc "6"

import Foundation

public class CSVReader<Input> where Input: IteratorProtocol<Result<UTF8.CodeUnit, CSVError>> {
    var input: Input
    public let configuration: CSVReaderConfiguration

    var parser = CSVParser()
    var header: [String]? = nil
    var isEOF = false
    var row = 0

    public init(
        input: consuming Input,
        configuration: CSVReaderConfiguration = .csv()
    ) {
        self.input = input
        self.configuration = configuration.copy()
    }
}

extension CSVReader where Input == CSVFileSequence {
    public convenience init(
        fileAtPath path: String,
        configuration: CSVReaderConfiguration = .csv(),
        bufferSize: Int = 4096
    ) {
        let seq = CSVFileSequence(fileAtPath: path, bufferSize: bufferSize)
        self.init(input: seq, configuration: configuration)
    }

    public convenience init(
        url: URL,
        configuration: CSVReaderConfiguration = .csv(),
        bufferSize: Int = 4096
    ) {
        let seq = CSVFileSequence(url: url, bufferSize: bufferSize)
        self.init(input: seq, configuration: configuration)
    }
}

extension CSVReader where Input == CSVStringSequence {
    public convenience init(
        data: consuming Data,
        configuration: CSVReaderConfiguration = .csv()
    ) {
        let seq = CSVStringSequence(data: data)
        self.init(input: seq, configuration: configuration)
    }

    public convenience init(
        string: consuming String,
        configuration: CSVReaderConfiguration = .csv()
    ) {
        let seq = CSVStringSequence(string: string)
        self.init(input: seq, configuration: configuration)
    }
}

extension CSVReader: Sequence, IteratorProtocol {
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
            switch try parser.parse(&input, configuration: configuration) {
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
