//
//  CSVError.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/11.
//  Copyright © 2016 yaslab. All rights reserved.
//

/// No overview available.
public enum CSVError: Error {

    /// No overview available.
    case cannotOpenStream
    /// No overview available.
    case cannotReadStream
    /// No overview available.
    case cannotWriteStream
    /// No overview available.
    case streamErrorHasOccurred(error: Error)
    /// No overview available.
    case unicodeDecoding
    /// No overview available.
    case cannotReadHeaderRecord
    /// No overview available.
    case stringEncodingMismatch
    /// No overview available.
    case stringEndianMismatch

}
