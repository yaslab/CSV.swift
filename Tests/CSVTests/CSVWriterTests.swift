//
//  CSVWriterTests.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2017/05/28.
//  Copyright © 2017年 yaslab. All rights reserved.
//

import Foundation
import XCTest

import CSV

class CSVWriterTests: XCTestCase {
    
    static let allTests = [
        ("testSample", testSample)
    ]
    
    func testSample() {
        let stream = OutputStream(toMemory: ())
        let csv = CSVWriter(stream: stream, codecType: UTF8.self)
        
        for i in 0 ..< 10 {
            csv.beginNewRecord()
            csv.write(field: "\(i)")
            csv.write(field: "\(i)-text", quoted: true)
        }

        let _data = stream.property(forKey: .dataWrittenToMemoryStreamKey)
        guard let data = _data as? Data else {
            return
        }
        let str = String(data: data, encoding: .utf8)!
        print(str)
    }
    
}
