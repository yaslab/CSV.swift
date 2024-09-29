//
//  UTF8CodeUnitSequence.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2024/07/20.
//  Copyright © 2024 yaslab. All rights reserved.
//

public struct UTF8CodeUnitSequence<S> where S: Sequence<UTF8.CodeUnit> {
    let sequence: S
}

extension UTF8CodeUnitSequence: Sendable where S: Sendable {}

extension UTF8CodeUnitSequence: Sequence {
    public struct Iterator: IteratorProtocol {
        var it: S.Iterator

        init(it: consuming S.Iterator) {
            self.it = it
        }

        public mutating func next() -> Result<UTF8.CodeUnit, CSVError>? {
            if let value = it.next() {
                return .success(value)
            } else {
                return nil
            }
        }
    }

    public func makeIterator() -> Iterator {
        Iterator(it: sequence.makeIterator())
    }
}
