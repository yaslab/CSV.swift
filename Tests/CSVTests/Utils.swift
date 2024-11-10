//
//  Utils.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2024/07/20.
//  Copyright © 2024 yaslab. All rights reserved.
//

import Foundation

enum Utils {
    static func random(_ count: Int) -> [UInt8] {
        var array = [UInt8]()
        for _ in 0 ..< count {
            array.append(UInt8.random(in: .min ... .max))
        }
        return array
    }

    @discardableResult
    static func withTempURL<T>(_ block: (URL) throws -> T) throws -> T {
        let fm = FileManager.default

        let directory = URL(filePath: NSTemporaryDirectory())
            .appendingPathComponent("net.yaslab.csv-swift", isDirectory: true)

        if !fm.fileExists(atPath: directory.path()) {
            try fm.createDirectory(at: directory, withIntermediateDirectories: false)
        }

        let file = directory.appendingPathComponent(UUID().uuidString)

        let ret = try block(file)

        if fm.fileExists(atPath: file.path) {
            try? fm.removeItem(atPath: file.path)
        }

        return ret
    }
}
