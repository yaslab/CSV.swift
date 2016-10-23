//
//  CSV+iterator.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/10/23.
//  Copyright © 2016年 yaslab. All rights reserved.
//

extension CSV: IteratorProtocol, Sequence {

    /// No overview available.
    public func next() -> Row? {
        guard let row = readRow() else {
            return nil
        }
        return Row(data: row, headerRow: headerRow)
    }

}

extension CSV {

    /// No overview available.
    public struct Row: RandomAccessCollection {

        private let data: [String]
        private let headerRow: [String]?

        internal init(data: [String], headerRow: [String]?) {
            self.data = data
            self.headerRow = headerRow
        }

        // MARK: - RandomAccessCollection

        /// No overview available.
        public var startIndex: Int {
            return data.startIndex
        }

        /// No overview available.
        public var endIndex: Int {
            return data.endIndex
        }

        /// No overview available.
        public func index(before i: Int) -> Int {
            return data.index(before: i)
        }

        /// No overview available.
        public func index(after i: Int) -> Int {
            return data.index(after: i)
        }

        /// No overview available.
        public subscript(index: Int) -> String {
            return data[index]
        }

        // MARK: - Public method

        /// No overview available.
        public subscript(key: String) -> String? {
            assert(headerRow != nil, "CSVConfiguration.hasHeaderRow must be true")
            guard let index = headerRow!.index(of: key) else {
                return nil
            }
            return data[index]
        }

        /// No overview available.
        public func toArray() -> [String] {
            return data
        }

        /// No overview available.
        public func toDictionary() -> [String : String] {
            assert(headerRow != nil, "CSVConfiguration.hasHeaderRow must be true")
            var dictionary: [String : String] = [:]
            for (key, value) in zip(headerRow!, data) {
                dictionary[key] = value
            }
            return dictionary
        }

    }

}
