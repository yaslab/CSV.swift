//
//  UTF8CodeUnit+ASCII.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2024/09/28.
//  Copyright © 2024 yaslab. All rights reserved.
//

extension UTF8.CodeUnit {
    /// Horizontal Tabulation (HT)
    public static let horizontalTabulation: UTF8.CodeUnit = 0x09
    /// New Line (LF)
    public static let newLine: UTF8.CodeUnit = 0x0a
    /// Carriage Return (CR)
    public static let carriageReturn: UTF8.CodeUnit = 0x0d
    /// Space ' '
    public static let space: UTF8.CodeUnit = 0x20
    /// Quotation Mark '"'
    public static let quotationMark: UTF8.CodeUnit = 0x22
    /// Comma ','
    public static let comma: UTF8.CodeUnit = 0x2c
    /// No-Break Space ' '
    public static let noBreakSpace: UTF8.CodeUnit = 0xa0
}
