//
//  CSV+init.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/13.
//  Copyright © 2016 yaslab. All rights reserved.
//

import Foundation

extension CSV {
    
    // TODO: Documentation
    /// No overview available.
    public init(
        stream: InputStream,
        hasHeaderRow: Bool = defaultHasHeaderRow,
        trimFields: Bool = defaultTrimFields,
        delimiter: UnicodeScalar = defaultDelimiter)
        throws
    {
        try self.init(stream: stream, codecType: UTF8.self, hasHeaderRow: hasHeaderRow, trimFields: trimFields, delimiter: delimiter)
    }
    
}

extension CSV {
    
    // TODO: Documentation
    /// No overview available.
    public init(
        string: String,
        hasHeaderRow: Bool = defaultHasHeaderRow,
        trimFields: Bool = defaultTrimFields,
        delimiter: UnicodeScalar = defaultDelimiter)
        throws
    {
        let iterator = string.unicodeScalars.makeIterator()
        try self.init(iterator: iterator, hasHeaderRow: hasHeaderRow, trimFields: trimFields, delimiter: delimiter)
    }
    
}
