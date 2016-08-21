//
//  CSVError.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/11.
//  Copyright © 2016 yaslab. All rights reserved.
//

import Foundation

public enum CSVError: ErrorType {
    case CannotOpenFile
    case CannotReadFile
    case StreamErrorHasOccurred(error: NSError)
    case CannotReadHeaderRow
    case StringEncodingMismatch
    case StringEndianMismatch
}
