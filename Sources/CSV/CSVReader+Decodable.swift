//
//  CSVReader+Decodable.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2018/11/17.
//  Copyright © 2018 yaslab. All rights reserved.
//

import Foundation

extension CSVReader {

    static var dateFormatter: DateFormatter {
        let result = DateFormatter()
        result.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return result
    }

    private class CSVRowDecoder: Decoder {
        var codingPath: [CodingKey]

        let valuesByColumn: [String: String]

        let userInfo: [CodingUserInfoKey: Any]

        init(codingPath: [CodingKey], valuesByColumn: [String: String], userInfo: [CodingUserInfoKey: Any] = [:]) {
            self.codingPath = codingPath
            self.valuesByColumn = valuesByColumn
            self.userInfo = userInfo
        }

        func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
            let container = CSVKeyedDecodingContainer<Key>(referencing: self)
            return KeyedDecodingContainer(container)
        }

        func unkeyedContainer() throws -> UnkeyedDecodingContainer {
            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self,
                                              DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Cannot get unkeyed decoding container -- found null value instead."))
        }

        func singleValueContainer() throws -> SingleValueDecodingContainer {
            let key = self.codingPath[0].stringValue
            guard let value = self.valuesByColumn[key] else {
                throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self,
                                                  DecodingError.Context(codingPath: self.codingPath,
                                                                        debugDescription: "Cannot get single value container, value for key \(key) not found."))
            }
            return CSVSingleValueDecodingContainer(codingPath: self.codingPath, value: value) // TODO: test path assumption
        }
    }

    private class CSVKeyedDecodingContainer<K: CodingKey> : KeyedDecodingContainerProtocol {
        typealias Key = K

        let decoder: CSVRowDecoder

        var codingPath: [CodingKey] {
            return self.decoder.codingPath
        }

        var allKeys: [K] {
            return self.decoder.valuesByColumn.keys.compactMap { K(stringValue: $0) }
        }

        var valuesByColumn: [String: String] {
            return self.decoder.valuesByColumn
        }

        func valueFor(column: CodingKey) -> String? {
            return self.valuesByColumn[column.stringValue]
        }

        init(referencing decoder: CSVRowDecoder) {
            self.decoder = decoder
        }

        func contains(_ key: K) -> Bool {
            return self.valueFor(column: key) != nil
        }

        func decodeNil(forKey key: K) throws -> Bool {
            guard let value = self.valueFor(column: key) else {
                return true
            }

            if value.count == 0 {
                return true
            }

            return false
        }

        // TODO: support DecodingError.keyNotFound
        // TODO: support DecodingError.valueNotFound
        func decode(_ type: Bool.Type, forKey key: K) throws -> Bool {
            self.decoder.codingPath.append(key)
            defer { self.decoder.codingPath.removeLast() }

            return try self.decoder.singleValueContainer().decode(type)
        }

        func decode(_ type: String.Type, forKey key: K) throws -> String {
            self.decoder.codingPath.append(key)
            defer { self.decoder.codingPath.removeLast() }

            guard let result = self.valueFor(column: key).flatMap({ String($0) }) else {
                throw DecodingError.typeMismatch(type,
                                                 DecodingError.Context(codingPath: codingPath, debugDescription: "decode(...) value '\(self.valueFor(column: key) ?? "nil")'"))
            }
            return result
        }

        func decode(_ type: Double.Type, forKey key: K) throws -> Double {
            self.decoder.codingPath.append(key)
            defer { self.decoder.codingPath.removeLast() }

            guard let result = self.valueFor(column: key).flatMap({ Double($0) }) else {
                throw DecodingError.typeMismatch(type,
                                                 DecodingError.Context(codingPath: codingPath, debugDescription: "decode(...) value '\(self.valueFor(column: key) ?? "nil")'"))
            }
            return result
        }

        func decode(_ type: Float.Type, forKey key: K) throws -> Float {
            self.decoder.codingPath.append(key)
            defer { self.decoder.codingPath.removeLast() }

            guard let result = self.valueFor(column: key).flatMap({ Float($0) }) else {
                throw DecodingError.typeMismatch(type,
                                                 DecodingError.Context(codingPath: codingPath, debugDescription: "decode(...) value '\(self.valueFor(column: key) ?? "nil")'"))
            }
            return result
        }

        func decode(_ type: Int.Type, forKey key: K) throws -> Int {
            self.decoder.codingPath.append(key)
            defer { self.decoder.codingPath.removeLast() }

            guard let result = self.valueFor(column: key).flatMap({ Int($0) }) else {
                throw DecodingError.typeMismatch(type,
                                                 DecodingError.Context(codingPath: codingPath, debugDescription: "decode(...) value '\(self.valueFor(column: key) ?? "nil")'"))
            }
            return result
        }

        func decode(_ type: Int8.Type, forKey key: K) throws -> Int8 {
            self.decoder.codingPath.append(key)
            defer { self.decoder.codingPath.removeLast() }

            guard let result = self.valueFor(column: key).flatMap({ Int8($0) }) else {
                throw DecodingError.typeMismatch(type,
                                                 DecodingError.Context(codingPath: codingPath, debugDescription: "decode(...) value '\(self.valueFor(column: key) ?? "nil")'"))
            }
            return result
        }

        func decode(_ type: Int16.Type, forKey key: K) throws -> Int16 {
            self.decoder.codingPath.append(key)
            defer { self.decoder.codingPath.removeLast() }

            guard let result = self.valueFor(column: key).flatMap({ Int16($0) }) else {
                throw DecodingError.typeMismatch(type,
                                                 DecodingError.Context(codingPath: codingPath, debugDescription: "decode(...) value '\(self.valueFor(column: key) ?? "nil")'"))
            }
            return result

        }

        func decode(_ type: Int32.Type, forKey key: K) throws -> Int32 {
            self.decoder.codingPath.append(key)
            defer { self.decoder.codingPath.removeLast() }

            guard let result = self.valueFor(column: key).flatMap({ Int32($0) }) else {
                throw DecodingError.typeMismatch(type,
                                                 DecodingError.Context(codingPath: codingPath, debugDescription: "decode(...) value '\(self.valueFor(column: key) ?? "nil")'"))
            }
            return result

        }

        func decode(_ type: Int64.Type, forKey key: K) throws -> Int64 {
            self.decoder.codingPath.append(key)
            defer { self.decoder.codingPath.removeLast() }

            guard let result = self.valueFor(column: key).flatMap({ Int64($0) }) else {
                throw DecodingError.typeMismatch(type,
                                                 DecodingError.Context(codingPath: codingPath, debugDescription: "decode(...) value '\(self.valueFor(column: key) ?? "nil")'"))
            }
            return result

        }

        func decode(_ type: UInt.Type, forKey key: K) throws -> UInt {
            self.decoder.codingPath.append(key)
            defer { self.decoder.codingPath.removeLast() }

            guard let result = self.valueFor(column: key).flatMap({ UInt($0) }) else {
                throw DecodingError.typeMismatch(type,
                                                 DecodingError.Context(codingPath: codingPath, debugDescription: "decode(...) value '\(self.valueFor(column: key) ?? "nil")'"))
            }
            return result

        }

        func decode(_ type: UInt8.Type, forKey key: K) throws -> UInt8 {
            self.decoder.codingPath.append(key)
            defer { self.decoder.codingPath.removeLast() }

            guard let result = self.valueFor(column: key).flatMap({ UInt8($0) }) else {
                throw DecodingError.typeMismatch(type,
                                                 DecodingError.Context(codingPath: codingPath, debugDescription: "decode(...) value '\(self.valueFor(column: key) ?? "nil")'"))
            }
            return result

        }

        func decode(_ type: UInt16.Type, forKey key: K) throws -> UInt16 {
            self.decoder.codingPath.append(key)
            defer { self.decoder.codingPath.removeLast() }

            guard let result = self.valueFor(column: key).flatMap({ UInt16($0) }) else {
                throw DecodingError.typeMismatch(type,
                                                 DecodingError.Context(codingPath: codingPath, debugDescription: "decode(...) value '\(self.valueFor(column: key) ?? "nil")'"))
            }
            return result

        }

        func decode(_ type: UInt32.Type, forKey key: K) throws -> UInt32 {
            self.decoder.codingPath.append(key)
            defer { self.decoder.codingPath.removeLast() }

            guard let result = self.valueFor(column: key).flatMap({ UInt32($0) }) else {
                throw DecodingError.typeMismatch(type,
                                                 DecodingError.Context(codingPath: codingPath, debugDescription: "decode(...) value '\(self.valueFor(column: key) ?? "nil")'"))
            }
            return result

        }

        func decode(_ type: UInt64.Type, forKey key: K) throws -> UInt64 {
            self.decoder.codingPath.append(key)
            defer { self.decoder.codingPath.removeLast() }

            guard let result = self.valueFor(column: key).flatMap({ UInt64($0) }) else {
                throw DecodingError.typeMismatch(type,
                                                 DecodingError.Context(codingPath: codingPath, debugDescription: "decode(...) value '\(self.valueFor(column: key) ?? "nil")'"))
            }
            return result

        }

        func decode<T>(_ type: T.Type, forKey key: K) throws -> T where T: Decodable {
            self.decoder.codingPath.append(key)
            defer { self.decoder.codingPath.removeLast() }

            guard let stringValue = self.valueFor(column: key) else {
                throw DecodingError.valueNotFound(type,
                                                  DecodingError.Context(codingPath: codingPath, debugDescription: "decode(...)"))
            }

            if type == Date.self || type == NSDate.self {
                guard let container = try self.decoder.singleValueContainer() as? CSVSingleValueDecodingContainer else {
                    throw DecodingError.typeMismatch(type,
                                                     DecodingError.Context(codingPath: codingPath, debugDescription: "decode(...) value '\(self.valueFor(column: key) ?? "nil")'"))
                }

                return try container.decode(Date.self) as! T
            } else {
                return try type.init(from: self.decoder)
            }
        }

        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: K) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
            self.decoder.codingPath.append(key)
            defer { self.decoder.codingPath.removeLast() }

            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: codingPath,
                                      debugDescription: "nestedContainer(...) CSV does not support nested values")
            )
        }

        func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
            self.decoder.codingPath.append(key)
            defer { self.decoder.codingPath.removeLast() }

            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: codingPath,
                                      debugDescription: "nestedUnkeyedContainer(...) CSV does not support nested values")
            )
        }

        func superDecoder() throws -> Decoder {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: codingPath,
                                      debugDescription: "CSV does not support nested values")
            )
        }

        func superDecoder(forKey key: K) throws -> Decoder {
            self.decoder.codingPath.append(key)
            defer { self.decoder.codingPath.removeLast() }

            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: codingPath,
                                      debugDescription: "CSV does not support nested values")
            )
        }
    }

    class CSVSingleValueDecodingContainer: SingleValueDecodingContainer {
        var codingPath: [CodingKey]

        let value: Any

        init(codingPath: [CodingKey], value: Any) {
            self.codingPath = codingPath
            self.value = value
        }
        private func expectNonNull<T>(_ type: T.Type) throws {
            guard !self.decodeNil() else {
                throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected \(type) but found null value instead."))
            }
        }

        public func decodeNil() -> Bool {
            if self.value is NSNull {
                return true
            }
            if let stringValue = self.value as? String,
                stringValue.count == 0 {
                return true
            }
            return false
        }

        public func decode(_ expectedType: Bool.Type) throws -> Bool {
            try expectNonNull(Bool.self)

            if let number = self.value as? NSNumber {
                // TODO: Add a flag to coerce non-boolean numbers into Bools?
                if number === kCFBooleanTrue as NSNumber {
                    return true
                } else if number === kCFBooleanFalse as NSNumber {
                    return false
                }

                /* FIXME: If swift-corelibs-foundation doesn't change to use NSNumber, this code path will need to be included and tested:
                 } else if let bool = value as? Bool {
                 return bool
                 */

            }

            throw DecodingError.typeMismatch(expectedType,
                                             DecodingError.Context(codingPath: codingPath, debugDescription: "decode(...) value '\(self.value)'"))
        }

        public func decode(_ expectedType: Int.Type) throws -> Int {
            try expectNonNull(Int.self)

            let attemptNumber: NSNumber?

            let formatter = NumberFormatter()
            formatter.allowsFloats = false
            if let number = self.value as? NSNumber, number !== kCFBooleanTrue, number !== kCFBooleanFalse {
                attemptNumber = number
            } else if let stringValue = self.value as? String,
                let number = formatter.number(from: stringValue), number !== kCFBooleanTrue, number !== kCFBooleanFalse {
                attemptNumber = number
            } else {
                attemptNumber = nil
            }

            guard let number = attemptNumber else {
                throw DecodingError.typeMismatch(expectedType,
                                                 DecodingError.Context(codingPath: codingPath, debugDescription: "decode(...) value '\(self.value)'"))
            }

            let int = number.intValue
            guard NSNumber(value: int) == number else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed CSV number <\(number)> does not fit in \(expectedType)."))
            }

            return int
        }

        public func decode(_ expectedType: Int8.Type) throws -> Int8 {
            try expectNonNull(Int8.self)

            guard let number = value as? NSNumber, number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
                throw DecodingError.typeMismatch(expectedType,
                                                 DecodingError.Context(codingPath: self.codingPath, debugDescription: "Value '\(self.value)' is of type \(type(of: self.value))"))
            }

            let int8 = number.int8Value
            guard NSNumber(value: int8) == number else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed JSON number <\(number)> does not fit in \(expectedType)."))
            }

            return int8
        }

        public func decode(_ expectedType: Int16.Type) throws -> Int16 {
            try expectNonNull(Int16.self)

            guard let number = value as? NSNumber, number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
                throw DecodingError.typeMismatch(expectedType,
                                                 DecodingError.Context(codingPath: self.codingPath, debugDescription: "Value '\(self.value)' is of type \(type(of: self.value))"))
            }

            let int16 = number.int16Value
            guard NSNumber(value: int16) == number else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed JSON number <\(number)> does not fit in \(expectedType)."))
            }

            return int16
        }

        public func decode(_ expectedType: Int32.Type) throws -> Int32 {
            try expectNonNull(Int32.self)
            guard let number = value as? NSNumber, number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
                throw DecodingError.typeMismatch(expectedType,
                                                 DecodingError.Context(codingPath: self.codingPath, debugDescription: "Value '\(self.value)' is of type \(type(of: self.value))"))
            }

            let int32 = number.int32Value
            guard NSNumber(value: int32) == number else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed JSON number <\(number)> does not fit in \(expectedType)."))
            }

            return int32
        }

        public func decode(_ expectedType: Int64.Type) throws -> Int64 {
            try expectNonNull(Int64.self)

            guard let number = value as? NSNumber, number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
                throw DecodingError.typeMismatch(expectedType,
                                                 DecodingError.Context(codingPath: self.codingPath, debugDescription: "Value '\(self.value)' is of type \(type(of: self.value))"))
            }

            let int64 = number.int64Value
            guard NSNumber(value: int64) == number else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed CSV number <\(number)> does not fit in \(expectedType)."))
            }

            return int64
        }

        public func decode(_ expectedType: UInt.Type) throws -> UInt {
            try expectNonNull(UInt.self)

            guard let number = value as? NSNumber, number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
                throw DecodingError.typeMismatch(expectedType,
                                                 DecodingError.Context(codingPath: self.codingPath, debugDescription: "Value '\(self.value)' is of type \(type(of: self.value))"))
            }

            let uint = number.uintValue
            guard NSNumber(value: uint) == number else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed CSV number <\(number)> does not fit in \(expectedType)."))
            }

            return uint
        }

        public func decode(_ expectedType: UInt8.Type) throws -> UInt8 {
            try expectNonNull(UInt8.self)

            guard let number = value as? NSNumber, number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed CSV number <\(value)> does not fit in \(expectedType)."))
            }

            let uint8 = number.uint8Value
            guard NSNumber(value: uint8) == number else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed JSON number <\(number)> does not fit in \(expectedType)."))
            }

            return uint8
        }

        public func decode(_ expectedType: UInt16.Type) throws -> UInt16 {
            try expectNonNull(UInt16.self)

            guard let number = value as? NSNumber, number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
                throw DecodingError.typeMismatch(expectedType,
                                                 DecodingError.Context(codingPath: self.codingPath, debugDescription: "Value '\(self.value)' is of type \(type(of: self.value))"))
            }

            let uint16 = number.uint16Value
            guard NSNumber(value: uint16) == number else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed CSV number <\(number)> does not fit in \(expectedType)."))
            }

            return uint16
        }

        public func decode(_ expectedType: UInt32.Type) throws -> UInt32 {
            try expectNonNull(UInt32.self)
            guard let number = value as? NSNumber, number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
                throw DecodingError.typeMismatch(expectedType,
                                                 DecodingError.Context(codingPath: self.codingPath, debugDescription: "Value '\(self.value)' is of type \(type(of: self.value))"))
            }

            let uint32 = number.uint32Value
            guard NSNumber(value: uint32) == number else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed CSV number <\(number)> does not fit in \(expectedType)."))
            }

            return uint32
        }

        public func decode(_ expectedType: UInt64.Type) throws -> UInt64 {
            try expectNonNull(UInt64.self)
            guard let number = value as? NSNumber, number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
                throw DecodingError.typeMismatch(expectedType,
                                                 DecodingError.Context(codingPath: self.codingPath, debugDescription: "Value '\(self.value)' is of type \(type(of: self.value))"))
            }

            let uint64 = number.uint64Value
            guard NSNumber(value: uint64) == number else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed CSV number <\(number)> does not fit in \(expectedType)."))
            }

            return uint64
        }

        public func decode(_ expectedType: Float.Type) throws -> Float {
            try expectNonNull(Float.self)
            if let number = value as? NSNumber, number !== kCFBooleanTrue, number !== kCFBooleanFalse {
                // We are willing to return a Float by losing precision:
                // * If the original value was integral,
                //   * and the integral value was > Float.greatestFiniteMagnitude, we will fail
                //   * and the integral value was <= Float.greatestFiniteMagnitude, we are willing to lose precision past 2^24
                // * If it was a Float, you will get back the precise value
                // * If it was a Double or Decimal, you will get back the nearest approximation if it will fit
                let double = number.doubleValue
                guard abs(double) <= Double(Float.greatestFiniteMagnitude) else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed CSV number \(number) does not fit in \(expectedType)."))
                }

                return Float(double)

                /* FIXME: If swift-corelibs-foundation doesn't change to use NSNumber, this code path will need to be included and tested:
                 } else if let double = value as? Double {
                 if abs(double) <= Double(Float.max) {
                 return Float(double)
                 }
                 overflow = true
                 } else if let int = value as? Int {
                 if let float = Float(exactly: int) {
                 return float
                 }
                 overflow = true
                 */

//            } else if let string = value as? String,
//                case .convertFromString(let posInfString, let negInfString, let nanString) = self.options.nonConformingFloatDecodingStrategy {
//                if string == posInfString {
//                    return Float.infinity
//                } else if string == negInfString {
//                    return -Float.infinity
//                } else if string == nanString {
//                    return Float.nan
//                }
            }

            throw DecodingError.typeMismatch(expectedType,
                                             DecodingError.Context(codingPath: self.codingPath, debugDescription: "Value '\(self.value)' is of type \(type(of: self.value))"))
        }

        public func decode(_ expectedType: Double.Type) throws -> Double {
            try expectNonNull(Double.self)

            if let number = self.value as? NSNumber, number !== kCFBooleanTrue, number !== kCFBooleanFalse {
                // We are always willing to return the number as a Double:
                // * If the original value was integral, it is guaranteed to fit in a Double; we are willing to lose precision past 2^53 if you encoded a UInt64 but requested a Double
                // * If it was a Float or Double, you will get back the precise value
                // * If it was Decimal, you will get back the nearest approximation
                return number.doubleValue

                /* FIXME: If swift-corelibs-foundation doesn't change to use NSNumber, this code path will need to be included and tested:
                 } else if let double = value as? Double {
                 return double
                 } else if let int = value as? Int {
                 if let double = Double(exactly: int) {
                 return double
                 }
                 overflow = true
                 */

//            } else if let string = value as? String,
//                case .convertFromString(let posInfString, let negInfString, let nanString) = self.options.nonConformingFloatDecodingStrategy {
//                if string == posInfString {
//                    return Double.infinity
//                } else if string == negInfString {
//                    return -Double.infinity
//                } else if string == nanString {
//                    return Double.nan
//                }
            }

            throw DecodingError.typeMismatch(expectedType,
                                             DecodingError.Context(codingPath: self.codingPath, debugDescription: "Value '\(self.value)' is of type \(type(of: self.value))"))
        }

        public func decode(_ expectedType: String.Type) throws -> String {
            try expectNonNull(String.self)
            guard let string = value as? String else {
                throw DecodingError.typeMismatch(expectedType,
                                                 DecodingError.Context(codingPath: self.codingPath, debugDescription: "Value '\(self.value)' is of type \(type(of: self.value))"))
            }

            return string
        }

        public func decode(_ expectedType: Date.Type) throws -> Date {
            try expectNonNull(String.self)
            /*
             switch self.options.dateDecodingStrategy {
             case .deferredToDate:
             self.storage.push(container: value)
             defer { self.storage.popContainer() }
             return try Date(from: self)

             case .secondsSince1970:
             let double = try self.unbox(value, as: Double.self)!
             return Date(timeIntervalSince1970: double)

             case .millisecondsSince1970:
             let double = try self.unbox(value, as: Double.self)!
             return Date(timeIntervalSince1970: double / 1000.0)

             case .iso8601:
             if #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
             let string = try self.unbox(value, as: String.self)!
             guard let date = _iso8601Formatter.date(from: string) else {
             throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected date string to be ISO8601-formatted."))
             }

             return date
             } else {
             fatalError("ISO8601DateFormatter is unavailable on this platform.")
             }

             case .formatted(let formatter):
             let string = try self.unbox(value, as: String.self)!
             guard let date = formatter.date(from: string) else {
             throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Date string does not match format expected by formatter."))
             }

             return date

             case .custom(let closure):
             self.storage.push(container: value)
             defer { self.storage.popContainer() }
             return try closure(self)
             }*/

            let formatter = CSVReader.dateFormatter

            guard let string = value as? String else {
                throw DecodingError.typeMismatch(expectedType,
                                                 DecodingError.Context(codingPath: self.codingPath, debugDescription: "Value '\(self.value)' is of type \(type(of: self.value))"))
            }

            guard let result = formatter.date(from: string) else {
                throw DecodingError.dataCorruptedError(in: self, debugDescription: "decode(...) for type \(expectedType) with value '\(self.value)'")
            }
            return result
        }

        public func decode<T: Decodable>(_ type: T.Type) throws -> T {
            try expectNonNull(type)
            //            return try self.unbox(self.value, as: type)!
            throw DecodingError.typeMismatch(T.self,
                                             DecodingError.Context(codingPath: self.codingPath,
                                                                   debugDescription: "decode(\(type))"))
        }
    }

    public func readRow<T>() throws -> T? where T: Decodable {
        guard let headerRow = self.headerRow else {
            throw DecodingError.typeMismatch(T.self,
                                             DecodingError.Context(codingPath: [],
                                                                   debugDescription: "readRow(): Header row required to map to Decodable")
            )
        }

        guard let valuesRow = self.next() else {
            return nil
        }

        let valuesForColumns = Dictionary(uniqueKeysWithValues: zip(headerRow, valuesRow))

        let decoder = CSVRowDecoder(codingPath: [], valuesByColumn: valuesForColumns)
        return try T(from: decoder)
    }

}
