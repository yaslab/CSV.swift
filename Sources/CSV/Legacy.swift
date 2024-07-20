//
//  Legacy.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/11.
//  Copyright © 2016 yaslab. All rights reserved.
//

@available(*, unavailable, renamed: "CSVReader")
public enum CSV {}

extension CSVReader {
    @available(*, unavailable, renamed: "CSVRow")
    var headerRow: [String]? { nil }

    @available(*, unavailable, renamed: "CSVRow")
    var currentRow: [String]? { nil }

    @available(*, unavailable, renamed: "CSVError")
    var error: Error? { nil }

    @available(*, unavailable, renamed: "CSVRow")
    subscript(key: String) -> String? { nil }
}
