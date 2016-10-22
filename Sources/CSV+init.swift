//
//  CSV+init.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/13.
//  Copyright © 2016 yaslab. All rights reserved.
//

import Foundation

extension CSV {

    /// Create an instance with `InputStream`.
    ///
    /// - parameter stream: An `InputStream` object. If the stream is not open,
    ///                     initializer opens automatically.
    /// - parameter config: CSV configuration.
    public init(
        stream: InputStream,
        config: CSVConfiguration = CSVConfiguration()) throws {

        try self.init(stream: stream, codecType: UTF8.self, config: config)
    }

    // MARK: - deprecated

    /// Unavailable.
    @available(*, unavailable, message: "Use init(stream:config:) instead")
    public init(
        stream: InputStream,
        hasHeaderRow: Bool = defaultHasHeaderRow,
        trimFields: Bool = defaultTrimFields,
        delimiter: UnicodeScalar = defaultDelimiter) throws {

        let config = CSVConfiguration(
            hasHeaderRow: hasHeaderRow,
            trimFields: trimFields,
            delimiter: delimiter
        )
        try self.init(stream: stream, codecType: UTF8.self, config: config)
    }

}

extension CSV {

    /// Create an instance with CSV string.
    ///
    /// - parameter string: An CSV string.
    /// - parameter config: CSV configuration.
    public init(
        string: String,
        config: CSVConfiguration = CSVConfiguration()) throws {

        let iterator = string.unicodeScalars.makeIterator()
        try self.init(iterator: iterator, config: config)
    }

    // MARK: - deprecated

    /// Unavailable.
    @available(*, unavailable, message: "Use init(string:config:) instead")
    public init(
        string: String,
        hasHeaderRow: Bool = defaultHasHeaderRow,
        trimFields: Bool = defaultTrimFields,
        delimiter: UnicodeScalar = defaultDelimiter) throws {

        let iterator = string.unicodeScalars.makeIterator()
        let config = CSVConfiguration(
            hasHeaderRow: hasHeaderRow,
            trimFields: trimFields,
            delimiter: delimiter
        )
        try self.init(iterator: iterator, config: config)
    }

}
