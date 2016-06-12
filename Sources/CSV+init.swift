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
        encoding: NSStringEncoding = defaultEncoding,
        delimiter: CChar = defaultDelimiter,
        bufferSize: Int = defaultBufferSize)
        throws
    {
        guard let stream = NSInputStream(fileAtPath: path) else {
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
        url: NSURL,
        hasHeaderRow: Bool = defaultHasHeaderRow,
        encoding: NSStringEncoding = defaultEncoding,
        delimiter: CChar = defaultDelimiter,
        bufferSize: Int = defaultBufferSize)
        throws
    {
        guard let stream = NSInputStream(URL: url) else {
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
        delimiter: CChar = defaultDelimiter,
        bufferSize: Int = defaultBufferSize)
        throws
    {
        let encoding = defaultEncoding
        guard let data = string.dataUsingEncoding(encoding) else {
            throw CSVError.StringEncodingMismatch
        }
        try self.init(
            stream: NSInputStream(data: data),
            hasHeaderRow: hasHeaderRow,
            encoding: encoding,
            delimiter: delimiter,
            bufferSize: bufferSize)
    }
    
}
