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

    final class CSVRowDecoder {

        init() {}

        func decode<T: Decodable>(_ type: T.Type, from reader: CSVReader) throws -> T {
            let decoder = _CSVRowDecoder(referencing: reader, at: [], userInfo: [:])
            return try T(from: decoder)
        }

    }

    // swiftlint:disable type_name
    fileprivate final class _CSVRowDecoder: Decoder {
        fileprivate let reader: CSVReader

        var codingPath: [CodingKey]

        let valuesByColumn: [String: String]

        let userInfo: [CodingUserInfoKey: Any]

        init(referencing reader: CSVReader, at codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any]) {
            self.reader = reader
            self.codingPath = codingPath
            self.valuesByColumn = [:]
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
            return self
        }
    }

    private class CSVKeyedDecodingContainer<K: CodingKey> : KeyedDecodingContainerProtocol {
        typealias Key = K

        let decoder: _CSVRowDecoder

        var codingPath: [CodingKey] {
            return self.decoder.codingPath
        }

        var allKeys: [K] {
            guard let headerRow = decoder.reader.headerRow else {
                return []
            }
            return headerRow.compactMap { K(stringValue: $0) }
        }

        init(referencing decoder: _CSVRowDecoder) {
            self.decoder = decoder
        }

        private func _errorDescription(of key: CodingKey) -> String {
            return "\(key) (\"\(key.stringValue)\")"
        }

        func contains(_ key: K) -> Bool {
            return decoder.reader[key.stringValue] != nil
        }

        func decodeNil(forKey key: K) throws -> Bool {
            guard let field = decoder.reader[key.stringValue] else {
                throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
            }

            return field.isEmpty
        }

        func decode(_ type: Bool.Type, forKey key: K) throws -> Bool {
            guard let field = decoder.reader[key.stringValue] else {
                throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
            }

            self.decoder.codingPath.append(key)
            defer { self.decoder.codingPath.removeLast() }

            guard let result = try decoder.unbox(field, as: Bool.self) else {
                throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
            }
            return result
        }

        func decode(_ type: String.Type, forKey key: K) throws -> String {
            guard let field = decoder.reader[key.stringValue] else {
                throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
            }

            self.decoder.codingPath.append(key)
            defer { self.decoder.codingPath.removeLast() }

            guard let result = try decoder.unbox(field, as: String.self) else {
                throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
            }
            return result
        }

        func decode(_ type: Double.Type, forKey key: K) throws -> Double {
            guard let field = decoder.reader[key.stringValue] else {
                throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
            }

            self.decoder.codingPath.append(key)
            defer { self.decoder.codingPath.removeLast() }

            guard let result = try decoder.unbox(field, as: Double.self) else {
                throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
            }
            return result
        }

        func decode(_ type: Float.Type, forKey key: K) throws -> Float {
            guard let field = decoder.reader[key.stringValue] else {
                throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
            }

            self.decoder.codingPath.append(key)
            defer { self.decoder.codingPath.removeLast() }

            guard let result = try decoder.unbox(field, as: Float.self) else {
                throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
            }
            return result
        }

        func decode(_ type: Int.Type, forKey key: K) throws -> Int {
            guard let field = decoder.reader[key.stringValue] else {
                throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
            }

            self.decoder.codingPath.append(key)
            defer { self.decoder.codingPath.removeLast() }

            guard let result = try decoder.unbox(field, as: Int.self) else {
                throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
            }
            return result
        }

        func decode(_ type: Int8.Type, forKey key: K) throws -> Int8 {
            guard let field = decoder.reader[key.stringValue] else {
                throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
            }

            self.decoder.codingPath.append(key)
            defer { self.decoder.codingPath.removeLast() }

            guard let result = try decoder.unbox(field, as: Int8.self) else {
                throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
            }
            return result
        }

        func decode(_ type: Int16.Type, forKey key: K) throws -> Int16 {
            guard let field = decoder.reader[key.stringValue] else {
                throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
            }

            self.decoder.codingPath.append(key)
            defer { self.decoder.codingPath.removeLast() }

            guard let result = try decoder.unbox(field, as: Int16.self) else {
                throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
            }
            return result
        }

        func decode(_ type: Int32.Type, forKey key: K) throws -> Int32 {
            guard let field = decoder.reader[key.stringValue] else {
                throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
            }

            self.decoder.codingPath.append(key)
            defer { self.decoder.codingPath.removeLast() }

            guard let result = try decoder.unbox(field, as: Int32.self) else {
                throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
            }
            return result
        }

        func decode(_ type: Int64.Type, forKey key: K) throws -> Int64 {
            guard let field = decoder.reader[key.stringValue] else {
                throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
            }

            self.decoder.codingPath.append(key)
            defer { self.decoder.codingPath.removeLast() }

            guard let result = try decoder.unbox(field, as: Int64.self) else {
                throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
            }
            return result
        }

        func decode(_ type: UInt.Type, forKey key: K) throws -> UInt {
            guard let field = decoder.reader[key.stringValue] else {
                throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
            }

            self.decoder.codingPath.append(key)
            defer { self.decoder.codingPath.removeLast() }

            guard let result = try decoder.unbox(field, as: UInt.self) else {
                throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
            }
            return result
        }

        func decode(_ type: UInt8.Type, forKey key: K) throws -> UInt8 {
            guard let field = decoder.reader[key.stringValue] else {
                throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
            }

            self.decoder.codingPath.append(key)
            defer { self.decoder.codingPath.removeLast() }

            guard let result = try decoder.unbox(field, as: UInt8.self) else {
                throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
            }
            return result
        }

        func decode(_ type: UInt16.Type, forKey key: K) throws -> UInt16 {
            guard let field = decoder.reader[key.stringValue] else {
                throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
            }

            self.decoder.codingPath.append(key)
            defer { self.decoder.codingPath.removeLast() }

            guard let result = try decoder.unbox(field, as: UInt16.self) else {
                throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
            }
            return result
        }

        func decode(_ type: UInt32.Type, forKey key: K) throws -> UInt32 {
            guard let field = decoder.reader[key.stringValue] else {
                throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
            }

            self.decoder.codingPath.append(key)
            defer { self.decoder.codingPath.removeLast() }

            guard let result = try decoder.unbox(field, as: UInt32.self) else {
                throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
            }
            return result
        }

        func decode(_ type: UInt64.Type, forKey key: K) throws -> UInt64 {
            guard let field = decoder.reader[key.stringValue] else {
                throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
            }

            self.decoder.codingPath.append(key)
            defer { self.decoder.codingPath.removeLast() }

            guard let result = try decoder.unbox(field, as: UInt64.self) else {
                throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
            }
            return result
        }

        func decode<T>(_ type: T.Type, forKey key: K) throws -> T where T: Decodable {
            guard let field = decoder.reader[key.stringValue] else {
                throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
            }

            self.decoder.codingPath.append(key)
            defer { self.decoder.codingPath.removeLast() }

            guard let result = try decoder.unbox(field, as: type) else {
                throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
            }
            return result
        }

        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: K) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
            // Not supported
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: codingPath,
                                      debugDescription: "nestedContainer(...) CSV does not support nested values")
            )
        }

        func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
            // Not supported
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: codingPath,
                                      debugDescription: "nestedUnkeyedContainer(...) CSV does not support nested values")
            )
        }

        func superDecoder() throws -> Decoder {
            // Not supported
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: codingPath,
                                      debugDescription: "CSV does not support nested values")
            )
        }

        func superDecoder(forKey key: K) throws -> Decoder {
            // Not supported
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: codingPath,
                                      debugDescription: "CSV does not support nested values")
            )
        }

    }
}

extension CSVReader._CSVRowDecoder: SingleValueDecodingContainer {

        private var value: String {
            let key = codingPath.last!
            return reader[key.stringValue]!
        }

        private func expectNonNull<T>(_ type: T.Type) throws {
            guard !self.decodeNil() else {
                throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected \(type) but found null value instead."))
            }
        }

        public func decodeNil() -> Bool {
            return value.isEmpty
        }

        public func decode(_ expectedType: Bool.Type) throws -> Bool {
            try expectNonNull(Bool.self)

            return try unbox(value, as: Bool.self)!
        }

        public func decode(_ expectedType: Int.Type) throws -> Int {
            try expectNonNull(Int.self)

            return try unbox(value, as: Int.self)!
        }

        public func decode(_ expectedType: Int8.Type) throws -> Int8 {
            try expectNonNull(Int8.self)

            return try unbox(value, as: Int8.self)!
        }

        public func decode(_ expectedType: Int16.Type) throws -> Int16 {
            try expectNonNull(Int16.self)

            return try unbox(value, as: Int16.self)!
        }

        public func decode(_ expectedType: Int32.Type) throws -> Int32 {
            try expectNonNull(Int32.self)

            return try unbox(value, as: Int32.self)!
        }

        public func decode(_ expectedType: Int64.Type) throws -> Int64 {
            try expectNonNull(Int64.self)

            return try unbox(value, as: Int64.self)!
        }

        public func decode(_ expectedType: UInt.Type) throws -> UInt {
            try expectNonNull(UInt.self)

            return try unbox(value, as: UInt.self)!
        }

        public func decode(_ expectedType: UInt8.Type) throws -> UInt8 {
            try expectNonNull(UInt8.self)

            return try unbox(value, as: UInt8.self)!
        }

        public func decode(_ expectedType: UInt16.Type) throws -> UInt16 {
            try expectNonNull(UInt16.self)

            return try unbox(value, as: UInt16.self)!
        }

        public func decode(_ expectedType: UInt32.Type) throws -> UInt32 {
            try expectNonNull(UInt32.self)

            return try unbox(value, as: UInt32.self)!
        }

        public func decode(_ expectedType: UInt64.Type) throws -> UInt64 {
            try expectNonNull(UInt64.self)

            return try unbox(value, as: UInt64.self)!
        }

        public func decode(_ expectedType: Float.Type) throws -> Float {
            try expectNonNull(Float.self)

            return try unbox(value, as: Float.self)!
        }

        public func decode(_ expectedType: Double.Type) throws -> Double {
            try expectNonNull(Double.self)

            return try unbox(value, as: Double.self)!
        }

        public func decode(_ expectedType: String.Type) throws -> String {
            try expectNonNull(String.self)

            return try unbox(value, as: String.self)!
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
            return try unbox(value, as: type)!
        }
    }

extension CSVReader {

    public func readRow<T>() throws -> T? where T: Decodable {
        //
        //

        guard next() != nil else {
            return nil
        }

        let decoder = CSVRowDecoder()
        return try decoder.decode(T.self, from: self)
    }

}

extension CSVReader._CSVRowDecoder {

    func unbox(_ value: String, as type: Bool.Type) throws -> Bool? {
        if value.isEmpty { return nil }

        if let bool = Bool(value) {
            return bool
        }

        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
    }

    func unbox(_ value: String, as type: Int.Type) throws -> Int? {
        if value.isEmpty { return nil }

        if let int = Int(value, radix: 10) {
            return int
        }

        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
    }

    func unbox(_ value: String, as type: Int8.Type) throws -> Int8? {
        if value.isEmpty { return nil }

        if let int8 = Int8(value, radix: 10) {
            return int8
        }

        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
    }

    func unbox(_ value: String, as type: Int16.Type) throws -> Int16? {
        if value.isEmpty { return nil }

        if let int16 = Int16(value, radix: 10) {
            return int16
        }

        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
    }

    func unbox(_ value: String, as type: Int32.Type) throws -> Int32? {
        if value.isEmpty { return nil }

        if let int32 = Int32(value, radix: 10) {
            return int32
        }

        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
    }

    func unbox(_ value: String, as type: Int64.Type) throws -> Int64? {
        if value.isEmpty { return nil }

        if let int64 = Int64(value, radix: 10) {
            return int64
        }

        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
    }

    func unbox(_ value: String, as type: UInt.Type) throws -> UInt? {
        if value.isEmpty { return nil }

        if let uint = UInt(value, radix: 10) {
            return uint
        }

        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
    }

    func unbox(_ value: String, as type: UInt8.Type) throws -> UInt8? {
        if value.isEmpty { return nil }

        if let uint8 = UInt8(value, radix: 10) {
            return uint8
        }

        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
    }

    func unbox(_ value: String, as type: UInt16.Type) throws -> UInt16? {
        if value.isEmpty { return nil }

        if let uint16 = UInt16(value, radix: 10) {
            return uint16
        }

        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
    }

    func unbox(_ value: String, as type: UInt32.Type) throws -> UInt32? {
        if value.isEmpty { return nil }

        if let uint32 = UInt32(value, radix: 10) {
            return uint32
        }

        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
    }

    func unbox(_ value: String, as type: UInt64.Type) throws -> UInt64? {
        if value.isEmpty { return nil }

        if let uint64 = UInt64(value, radix: 10) {
            return uint64
        }

        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
    }

    func unbox(_ value: String, as type: Double.Type) throws -> Double? {
        if value.isEmpty { return nil }

        if let float = Double(value) {
            return float
        }

        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
    }

    func unbox(_ value: String, as type: Float.Type) throws -> Float? {
        if value.isEmpty { return nil }

        if let float = Float(value) {
            return float
        }

        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
    }

    func unbox(_ value: String, as type: String.Type) throws -> String? {
        if value.isEmpty { return nil }

        return value
    }

    // TODO: Specialize the type of `Foundation` (such as Date, Data, ...).

    func unbox<T: Decodable>(_ value: String, as type: T.Type) throws -> T? {
        return try T(from: self)
    }

}

extension DecodingError {

    internal static func _typeMismatch(at path: [CodingKey], expectation: Any.Type, reality: String) -> DecodingError {
        let description = "Expected to decode \(expectation) but found \(reality) instead."
        return .typeMismatch(expectation, Context(codingPath: path, debugDescription: description))
    }

}
