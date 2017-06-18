//
//  UnicodeIterator.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/20.
//  Copyright © 2016 yaslab. All rights reserved.
//

internal class UnicodeIterator<
    Input: IteratorProtocol,
    InputEncoding: UnicodeCodec>
    : IteratorProtocol
    where InputEncoding.CodeUnit == Input.Element {

    private var input: Input
    private var inputEncoding: InputEncoding
    internal var errorHandler: ((Error) -> Void)?

    internal init(input: Input, inputEncodingType: InputEncoding.Type) {
        self.input = input
        self.inputEncoding = inputEncodingType.init()
    }

    internal func next() -> UnicodeScalar? {
        switch inputEncoding.decode(&input) {
        case .scalarValue(let c):
            return c
        case .emptyInput:
            return nil
        case .error:
            errorHandler?(CSVError.unicodeDecoding)
            return nil
        }
    }

}
