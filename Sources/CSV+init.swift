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
        stream: NSInputStream,
        hasHeaderRow: Bool = defaultHasHeaderRow,
        delimiter: UnicodeScalar = defaultDelimiter)
        throws
    {
        try self.init(stream: stream, codecType: UTF8.self, hasHeaderRow: hasHeaderRow, delimiter: delimiter)
    }

}

extension CSV {
    
    public init(
        string: String,
        hasHeaderRow: Bool = defaultHasHeaderRow,
        delimiter: UnicodeScalar = defaultDelimiter)
        throws
    {
        let iterator = string.unicodeScalars.generate()
        try self.init(iterator: iterator, hasHeaderRow: hasHeaderRow, delimiter: delimiter)
    }
    
}
