//
//  UnicodeIterator.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/20.
//  Copyright © 2016 yaslab. All rights reserved.
//

internal struct UnicodeIterator<
    Input: GeneratorType,
    InputEncoding: UnicodeCodecType
    where InputEncoding.CodeUnit == Input.Element>
    : GeneratorType {
    
    private var input: Input
    private var inputEncoding: InputEncoding
    
    internal init(input: Input, inputEncodingType: InputEncoding.Type) {
        self.input = input
        self.inputEncoding = inputEncodingType.init()
    }
    
    internal mutating func next() -> UnicodeScalar? {
        switch inputEncoding.decode(&input) {
        case .Result(let c): return c
        case .EmptyInput: return nil
        case .Error: return nil
        }
    }
    
}
