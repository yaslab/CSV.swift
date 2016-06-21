//
//  UnicodeIterator.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/20.
//  Copyright © 2016年 yaslab. All rights reserved.
//

import Foundation

struct UnicodeIterator<
    Input: IteratorProtocol,
    InputEncoding: UnicodeCodec
    where InputEncoding.CodeUnit == Input.Element>
    : IteratorProtocol {
    
    var input: Input
    var inputEncoding: InputEncoding
    
    init(input: Input, inputEncoding: InputEncoding.Type) {
        self.input = input
        self.inputEncoding = inputEncoding.init()
    }
    
    mutating func next() -> UnicodeScalar? {
        switch inputEncoding.decode(&input) {
        case .scalarValue(let c): return c
        case .emptyInput: return nil
        case .error: return nil
        }
    }
    
}
