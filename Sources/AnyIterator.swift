//
//  AnyIterator.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/21.
//  Copyright © 2016年 yaslab. All rights reserved.
//

import Foundation

struct AnyIterator<T>: IteratorProtocol {
    
    private var _base_next: (() -> T?)
    
    init<U: IteratorProtocol where U.Element == T>(base: inout U) {
        _base_next = { base.next() }
    }
    
    mutating func next() -> T? {
        return _base_next()
    }
    
}
