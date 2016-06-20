//
//  CSV+init.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/13.
//  Copyright © 2016 yaslab. All rights reserved.
//

import Foundation

extension CSV {
    
    public convenience init(
        path: String,
        hasHeaderRow: Bool = defaultHasHeaderRow,
        encoding: String.Encoding = defaultEncoding,
        delimiter: UnicodeScalar = defaultDelimiter,
        bufferSize: Int = defaultBufferSize)
        throws
    {
        guard let stream = InputStream(fileAtPath: path) else {
            throw CSVError.StreamError
        }
        try self.init(
            stream: stream,
            hasHeaderRow: hasHeaderRow,
            encoding: encoding,
            delimiter: delimiter,
            bufferSize: bufferSize)
    }
    
    public convenience init(
        url: URL,
        hasHeaderRow: Bool = defaultHasHeaderRow,
        encoding: String.Encoding = defaultEncoding,
        delimiter: UnicodeScalar = defaultDelimiter,
        bufferSize: Int = defaultBufferSize)
        throws
    {
        guard let stream = InputStream(url: url) else {
            throw CSVError.StreamError
        }
        try self.init(
            stream: stream,
            hasHeaderRow: hasHeaderRow,
            encoding: encoding,
            delimiter: delimiter,
            bufferSize: bufferSize)
    }
    
    public convenience init(
        string: String,
        hasHeaderRow: Bool = defaultHasHeaderRow,
        delimiter: UnicodeScalar = defaultDelimiter,
        bufferSize: Int = defaultBufferSize)
        throws
    {
        let encoding = defaultEncoding
        guard let data = string.data(using: encoding) else {
            throw CSVError.StringEncodingMismatch
        }
        try self.init(
            stream: InputStream(data: data),
            hasHeaderRow: hasHeaderRow,
            encoding: encoding,
            delimiter: delimiter,
            bufferSize: bufferSize)
    }
    
}
