//
//  AnyIterator.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/21.
//  Copyright © 2016 yaslab. All rights reserved.
//

internal struct AnyIterator<T>: GeneratorType {
    
    private var _base_next: (() -> T?)
    
    internal init<U: GeneratorType where U.Element == T>(base: U) {
        var base = base
        _base_next = { base.next() }
    }
    
    internal mutating func next() -> T? {
        return _base_next()
    }
    
}
