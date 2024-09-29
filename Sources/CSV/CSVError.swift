//
//  CSVError.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/11.
//  Copyright © 2016 yaslab. All rights reserved.
//

public enum CSVError: Error {

    // Reader: common

    case cannotReadHeaderRow
    case invalidCSVFormat

    // Reader: file

    case cannotOpenFile
    case cannotReadFile

    // Writer: file

    case cannotWriteStream

    // Reader / Writer: file

    case streamErrorHasOccurred(error: Error)

}
