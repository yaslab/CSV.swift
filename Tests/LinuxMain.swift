//
//  LinuxMain.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/11.
//  Copyright © 2016 yaslab. All rights reserved.
//

import XCTest
@testable import CSVTests

XCTMain([
     testCase(CSVTests.allTests),
     testCase(CSVWriterTests.allTests),
     testCase(LineBreakTests.allTests),
     testCase(ReadmeTests.allTests),
     testCase(TrimFieldsTests.allTests),
     testCase(UnicodeTests.allTests),
     testCase(Version1Tests.allTests)
])
