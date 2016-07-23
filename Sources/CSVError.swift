//
//  CSVError.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/11.
//  Copyright © 2016 yaslab. All rights reserved.
//

import Foundation

public enum CSVError: ErrorType {
    case cannotOpenFile
    case cannotReadFile
    case streamErrorHasOccurred(error: NSError)
    case cannotReadHeaderRow
    case stringEncodingMismatch
    case stringEndianMismatch
}
