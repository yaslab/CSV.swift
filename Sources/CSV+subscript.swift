//
//  CSV+subscript.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/13.
//  Copyright © 2016 yaslab. All rights reserved.
//

import Foundation

extension CSV {
    
    public subscript(key: String) -> String? {
        get {
            guard let headerRow = headerRow else {
                return nil
            }
            guard let index = headerRow.indexOf(key) else {
                return nil
            }
            guard let currentRow = currentRow else {
                return nil
            }
            if index >= currentRow.count {
                return nil
            }
            return currentRow[index]
        }
    }
    
}
