//
//  CSV+subscript.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/13.
//  Copyright © 2016 yaslab. All rights reserved.
//

extension CSV {

    /// Unavailable
    @available(*, unavailable, message: "Use CSV.Row.subscript(String) instead")
    public subscript(key: String) -> String? {
        return nil
    }

}
