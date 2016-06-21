//
//  CSVError.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/11.
//  Copyright © 2016 yaslab. All rights reserved.
//

import Foundation

public enum CSVError: ErrorProtocol {
    case ParameterError
    case StreamError
    case HeaderReadError
    case MemoryAllocationFailed
    case StringEncodingMismatch
}
