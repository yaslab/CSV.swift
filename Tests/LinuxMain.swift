//
//  LinuxMain.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/11.
//
//

import XCTest
@testable import CSVTests

XCTMain([
     testCase(CSVTests.allTests),
     testCase(LineBreakTests.allTests),
     testCase(ReadmeTests.allTests),
     testCase(TrimFieldsTests.allTests),
     testCase(UnicodeTests.allTests)
])
