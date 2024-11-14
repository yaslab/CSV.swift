//
//  CSVError.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/11.
//  Copyright © 2016 yaslab. All rights reserved.
//

public enum CSVError: Error {

    // CSV Format (for Reader)

    case cannotReadHeaderRow
    case invalidCSVFormat

    // File Stream (for Reader)

    case cannotOpenFile
    case cannotReadFile

    // File Stream (for Writer)

    case cannotWriteFile

    // File Stream (for Reader / Writer)

    case streamErrorHasOccurred(error: Error)

}
