//
//  CSV+init.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/13.
//  Copyright © 2016 yaslab. All rights reserved.
//

import Foundation

extension CSV {

    public init(
        fileAtPath path: String,
        encoding: String.Encoding = defaultEncoding,
        hasHeaderRow: Bool = defaultHasHeaderRow,
        delimiter: UnicodeScalar = defaultDelimiter)
        throws
    {
        guard let stream = InputStream(fileAtPath: path) else {
            throw CSVError.StreamError
        }
        try self.init(stream: stream, encoding: encoding, hasHeaderRow: hasHeaderRow, delimiter: delimiter)
    }

    public init(
        url: URL,
        encoding: String.Encoding = defaultEncoding,
        hasHeaderRow: Bool = defaultHasHeaderRow,
        delimiter: UnicodeScalar = defaultDelimiter)
        throws
    {
        guard let stream = InputStream(url: url) else {
            throw CSVError.StreamError
        }
        try self.init(stream: stream, encoding: encoding, hasHeaderRow: hasHeaderRow, delimiter: delimiter)
    }

    public init(
        string: String,
        hasHeaderRow: Bool = defaultHasHeaderRow,
        delimiter: UnicodeScalar = defaultDelimiter)
        throws
    {
        var iterator = string.unicodeScalars.makeIterator()
        try self.init(iterator: &iterator, hasHeaderRow: hasHeaderRow, delimiter: delimiter)
    }
    
}
