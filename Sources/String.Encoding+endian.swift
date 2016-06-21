//
//  String.Encoding+endian.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/21.
//  Copyright © 2016年 yaslab. All rights reserved.
//

import Foundation

enum Endian {
    case big
    case little
    case unknown
}

extension String.Encoding {
    
    var endian: Endian {
        switch self {
        case String.Encoding.utf16: return .big
        case String.Encoding.utf16BigEndian: return .big
        case String.Encoding.utf16LittleEndian: return .little
        case String.Encoding.utf32: return .big
        case String.Encoding.utf32BigEndian: return .big
        case String.Encoding.utf32LittleEndian: return .little
        default: return .unknown
        }
    }
    
}
