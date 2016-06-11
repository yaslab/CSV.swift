//
//  CSVError.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/11.
//
//

import Foundation

public enum CSVError: ErrorType {
    case ParameterError
    case StreamError
    case HeaderReadError
    case MemoryAllocationFailed
    case StringEncodingMismatch
}
