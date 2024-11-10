//
//  CSVReaderTests.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2024/07/15.
//  Copyright © 2024 yaslab. All rights reserved.
//

import CSV
import Foundation
import Testing

struct _CSVReaderTests {

    func xxxx(reader: CSVReader<some Sequence>) {
        for result in reader {
            let _ = try? result.get()
        }
    }

    @Test func testSample1() {
        let csv = "aaa,bbb,ccc\r\nddd,eee,fff"
        let reader = CSVReader(data: Data(csv.utf8))

        xxxx(reader: reader)

        let rows1 = Array(reader.compactMap { try? $0.get() })
        #expect(rows1.count == 2)
        #expect(rows1[0].columns == ["aaa", "bbb", "ccc"])
        #expect(rows1[1].columns == ["ddd", "eee", "fff"])

        let rows2 = Array(reader.compactMap { try? $0.get() })
        #expect(rows2.count == 2)
        #expect(rows2[0].columns == ["aaa", "bbb", "ccc"])
        #expect(rows2[1].columns == ["ddd", "eee", "fff"])
    }

    @Test func testSample2() {
        let csv = " aaa ,bbb , ccc\r\n \"ddd\" ,\"eee\" , \"fff\""
        let reader = CSVReader(string: csv, trimFields: true)

        for result in reader {
            do {
                let row = try result.get()
                print(row)
            } catch {
                print(error)
            }
        }
    }

    @Test func testSample3() {
        let csv = " aaa ,bbb , ccc\r\n \"ddd\" ,\"eee\" , \"fff\""
        let reader = CSVReader(string: csv, hasHeaderRow: true, trimFields: true)

        for result in reader {
            do {
                let row = try result.get()
                print(row)
            } catch {
                print(error)
            }
        }
    }
}
