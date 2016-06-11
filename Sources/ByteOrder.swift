//
//  ByteOrder.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/11.
//
//

import CoreFoundation

internal func ReadBigInt16(base: UnsafePointer<Void>, byteOffset: Int) -> UInt16 {
    let bytes = UnsafePointer<UInt8>(base).advancedBy(byteOffset)
    let int16Array = UnsafePointer<UInt16>(bytes)
    return CFSwapInt16BigToHost(int16Array[0])
}

internal func ReadBigInt32(base: UnsafePointer<Void>, byteOffset: Int) -> UInt32 {
    let bytes = UnsafePointer<UInt8>(base).advancedBy(byteOffset)
    let int32Array = UnsafePointer<UInt32>(bytes)
    return CFSwapInt32BigToHost(int32Array[0])
}

internal func ReadLittleInt16(base: UnsafePointer<Void>, byteOffset: Int) -> UInt16 {
    let bytes = UnsafePointer<UInt8>(base).advancedBy(byteOffset)
    let int16Array = UnsafePointer<UInt16>(bytes)
    return CFSwapInt16LittleToHost(int16Array[0])
}

internal func ReadLittleInt32(base: UnsafePointer<Void>, byteOffset: Int) -> UInt32 {
    let bytes = UnsafePointer<UInt8>(base).advancedBy(byteOffset)
    let int32Array = UnsafePointer<UInt32>(bytes)
    return CFSwapInt32LittleToHost(int32Array[0])
}

internal func IsBigEndian() -> Bool {
    return CFByteOrderGetCurrent() == CFByteOrder(CFByteOrderBigEndian.rawValue)
}
