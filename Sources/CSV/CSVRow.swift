//
//  CSVRow.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2024/07/16.
//  Copyright © 2024 yaslab. All rights reserved.
//

import Foundation

public struct CSVRow: Sendable {
    public let header: [String]?
    public let columns: [String]

    @usableFromInline
    init(header: consuming [String]?, columns: consuming [String]) {
        self.header = header
        self.columns = columns
    }
}

extension CSVRow {
    public subscript(index: Int) -> String {
        columns[index]
    }

    public subscript(name: String) -> String? {
        guard let header else {
            return nil
        }
        guard let index = header.firstIndex(of: name) else {
            return nil
        }
        guard index < columns.count else {
            return ""
        }
        return columns[index]
    }
}
