//
//  CSVError.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/11.
//  Copyright © 2016 yaslab. All rights reserved.
//

// TODO: Documentation
/// No overview available.
public enum CSVError: Error {
    case cannotOpenFile
    case cannotReadFile
    case streamErrorHasOccurred(error: Error)
    case cannotReadHeaderRow
    case stringEncodingMismatch
    case stringEndianMismatch
}
