import XCTest

import CSVTests

var tests = [XCTestCaseEntry]()
tests += CSVTests.__allTests()

XCTMain(tests)
