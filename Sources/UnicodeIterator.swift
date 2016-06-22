//
//  UnicodeIterator.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/20.
//  Copyright © 2016年 yaslab. All rights reserved.
//

import Foundation

/*
internal struct UnicodeIterator<
    Input: IteratorProtocol,
    InputEncoding: UnicodeCodec
    where InputEncoding.CodeUnit == Input.Element>
    : IteratorProtocol {
    
    private var input: Input
    private var inputEncoding: InputEncoding
    
    internal init(input: Input, inputEncoding: InputEncoding.Type) {
        self.input = input
        self.inputEncoding = inputEncoding.init()
    }
    
    internal mutating func next() -> UnicodeScalar? {
        switch inputEncoding.decode(&input) {
        case .scalarValue(let c): return c
        case .emptyInput: return nil
        case .error: return nil
        }
    }
    
}
*/

public struct UTF32Iterator: IteratorProtocol {
    
    private var innerIterator: BinaryReader.UInt32Iterator
    private var codec = UTF32()
    
    internal init(reader: BinaryReader) {
        self.innerIterator = reader.makeUInt32Iterator()
    }
 
    public mutating func next() -> UnicodeScalar? {
        switch codec.decode(&innerIterator) {
        case .scalarValue(let c): return c
        case .emptyInput: return nil
        case .error: return nil
        }
    }
    
}

public struct UTF16Iterator: IteratorProtocol {
    
    private var innerIterator: BinaryReader.UInt16Iterator
    private var codec = UTF16()
    
    internal init(reader: BinaryReader) {
        self.innerIterator = reader.makeUInt16Iterator()
    }
    
    public mutating func next() -> UnicodeScalar? {
        switch codec.decode(&innerIterator) {
        case .scalarValue(let c): return c
        case .emptyInput: return nil
        case .error: return nil
        }
    }
    
}

public struct UTF8Iterator: IteratorProtocol {

    private var innerIterator: BinaryReader.UInt8Iterator
    private var codec = UTF8()
    
    internal init(reader: BinaryReader) {
        self.innerIterator = reader.makeUInt8Iterator()
    }
    
    public mutating func next() -> UnicodeScalar? {
        switch codec.decode(&innerIterator) {
        case .scalarValue(let c): return c
        case .emptyInput: return nil
        case .error: return nil
        }
    }
    
}
