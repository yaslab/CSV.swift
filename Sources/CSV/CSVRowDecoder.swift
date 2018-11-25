//
//  CSVRowDecoder.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2018/11/17.
//  Copyright © 2018 yaslab. All rights reserved.
//

import Foundation

open class CSVRowDecoder {

    /// The strategy to use for decoding `Date` values.
    public enum DateDecodingStrategy {
        /// Defer to `Date` for decoding. This is the default strategy.
        case deferredToDate

        /// Decode the `Date` as a UNIX timestamp from a JSON number.
        case secondsSince1970

        /// Decode the `Date` as UNIX millisecond timestamp from a JSON number.
        case millisecondsSince1970

        /// Decode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
        @available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
        case iso8601

        /// Decode the `Date` as a string parsed by the given formatter.
        case formatted(DateFormatter)

        /// Decode the `Date` as a custom value decoded by the given closure.
        case custom((_ value: String) throws -> Date)
    }

    /// The strategy to use for decoding `Data` values.
    public enum DataDecodingStrategy {
        /// Defer to `Data` for decoding.
        case deferredToData

        /// Decode the `Data` from a Base64-encoded string. This is the default strategy.
        case base64

        /// Decode the `Data` as a custom value decoded by the given closure.
        case custom((_ value: String) throws -> Data)
    }

    /// The strategy to use in decoding dates. Defaults to `.deferredToDate`.
    open var dateDecodingStrategy: DateDecodingStrategy = .deferredToDate

    /// The strategy to use in decoding binary data. Defaults to `.base64`.
    open var dataDecodingStrategy: DataDecodingStrategy = .base64

    /// Contextual user-provided information for use during decoding.
    open var userInfo: [CodingUserInfoKey: Any] = [:]

    /// Options set on the top-level encoder to pass down the decoding hierarchy.
    fileprivate struct _Options {
        let dateDecodingStrategy: DateDecodingStrategy
        let dataDecodingStrategy: DataDecodingStrategy
        let userInfo: [CodingUserInfoKey: Any]
    }

    /// The options set on the top-level decoder.
    fileprivate var options: _Options {
        return _Options(dateDecodingStrategy: dateDecodingStrategy,
                        dataDecodingStrategy: dataDecodingStrategy,
                        userInfo: userInfo)
    }

    /// Initializes `self` with default strategies.
    public init() {}

    open func decode<T: Decodable>(_ type: T.Type, from reader: CSVReader) throws -> T {
        let decoder = _CSVRowDecoder(referencing: reader, options: self.options)
        return try T(from: decoder)
    }

}

private class _CSVRowDecoder: Decoder {

    fileprivate let reader: CSVReader

    public fileprivate(set) var codingPath: [CodingKey]

    /// Options set on the top-level decoder.
    fileprivate let options: CSVRowDecoder._Options

    /// Contextual user-provided information for use during encoding.
    public var userInfo: [CodingUserInfoKey: Any] {
        return self.options.userInfo
    }

    fileprivate init(referencing reader: CSVReader, at codingPath: [CodingKey] = [], options: CSVRowDecoder._Options) {
        self.reader = reader
        self.codingPath = codingPath
        self.options = options
    }

    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
        let container = CSVKeyedDecodingContainer<Key>(referencing: self)
        return KeyedDecodingContainer(container)
    }

    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self,
                                          DecodingError.Context(codingPath: self.codingPath,
                                                                debugDescription: "Cannot get unkeyed decoding container -- found null value instead."))
    }

    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        return self
    }

}

private class CSVKeyedDecodingContainer<K: CodingKey> : KeyedDecodingContainerProtocol {

    typealias Key = K

    private let decoder: _CSVRowDecoder
        var codingPath: [CodingKey] {
        return self.decoder.codingPath
    }

    public var allKeys: [Key] {
        guard let headerRow = decoder.reader.headerRow else {
            return []
        }
        return headerRow.compactMap { Key(stringValue: $0) }
    }

    init(referencing decoder: _CSVRowDecoder) {
        self.decoder = decoder
    }

    private func value(for codingKey: CodingKey) -> String? {
        var value: String?

        if let index = codingKey.intValue {
            value = decoder.reader[index]
        } else {
            if decoder.reader.headerRow != nil {
                value = decoder.reader[codingKey.stringValue]
            }
        }
        return value
    }

    private func _errorDescription(of key: CodingKey) -> String {
        return "\(key) (\"\(key.stringValue)\")"
    }

    public func contains(_ key: Key) -> Bool {
        guard let index = key.intValue else {
            return decoder.reader[key.stringValue] != nil
        }
        return index < decoder.reader.currentRow!.count
    }

    public func decodeNil(forKey key: Key) throws -> Bool {
        guard let field = self.value(for: key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
        }

        return field.isEmpty
    }

    public func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        guard let field = self.value(for: key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let result = try decoder.unbox(field, as: Bool.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        return result
    }

    public func decode(_ type: String.Type, forKey key: Key) throws -> String {
        guard let field = self.value(for: key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let result = try decoder.unbox(field, as: String.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        return result
    }

    public func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        guard let field = self.value(for: key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let result = try decoder.unbox(field, as: Double.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        return result
    }

    public func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        guard let field = self.value(for: key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let result = try decoder.unbox(field, as: Float.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        return result
    }

    public func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        guard let field = self.value(for: key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let result = try decoder.unbox(field, as: Int.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        return result
    }

    public func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        guard let field = self.value(for: key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let result = try decoder.unbox(field, as: Int8.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        return result
    }

    public func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        guard let field = self.value(for: key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let result = try decoder.unbox(field, as: Int16.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        return result
    }

    public func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        guard let field = self.value(for: key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let result = try decoder.unbox(field, as: Int32.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        return result
    }

    public func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        guard let field = self.value(for: key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let result = try decoder.unbox(field, as: Int64.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        return result
    }

    public func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        guard let field = self.value(for: key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let result = try decoder.unbox(field, as: UInt.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        return result
    }

    public func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        guard let field = self.value(for: key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let result = try decoder.unbox(field, as: UInt8.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        return result
    }

    public func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        guard let field = self.value(for: key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let result = try decoder.unbox(field, as: UInt16.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        return result
    }

    public func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        guard let field = self.value(for: key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let result = try decoder.unbox(field, as: UInt32.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        return result
    }

    public func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        guard let field = self.value(for: key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let result = try decoder.unbox(field, as: UInt64.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        return result
    }

    public func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {
        guard let field = self.value(for: key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let result = try decoder.unbox(field, as: type) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        return result
    }

    public func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        // Not supported
        throw DecodingError.dataCorrupted(
            DecodingError.Context(codingPath: codingPath,
                                  debugDescription: "nestedContainer(...) CSV does not support nested values")
        )
    }

    public func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        // Not supported
        throw DecodingError.dataCorrupted(
            DecodingError.Context(codingPath: codingPath,
                                  debugDescription: "nestedUnkeyedContainer(...) CSV does not support nested values")
        )
    }

    public func superDecoder() throws -> Decoder {
        // Not supported
        throw DecodingError.dataCorrupted(
            DecodingError.Context(codingPath: codingPath,
                                  debugDescription: "CSV does not support nested values")
        )
    }

    public func superDecoder(forKey key: Key) throws -> Decoder {
        // Not supported
        throw DecodingError.dataCorrupted(
            DecodingError.Context(codingPath: codingPath,
                                  debugDescription: "CSV does not support nested values")
        )
    }

}

extension _CSVRowDecoder: SingleValueDecodingContainer {

    private var value: String {
        let key = codingPath.last!
        guard let index = key.intValue else {
            return reader[key.stringValue]!
        }
        return reader[index]!
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

    public func decode<T: Decodable>(_ type: T.Type) throws -> T {
        try expectNonNull(type)
        return try unbox(value, as: type)!
    }

}

extension CSVReader {

    public func readRow<T>() throws -> T? where T: Decodable {
        guard next() != nil else {
            return nil
        }

        let decoder = CSVRowDecoder()
        return try decoder.decode(T.self, from: self)
    }

}

extension _CSVRowDecoder {

    fileprivate func unbox(_ value: String, as type: Bool.Type) throws -> Bool? {
        if value.isEmpty { return nil }

        if let bool = Bool(value) {
            return bool
        }

        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
    }

    fileprivate func unbox(_ value: String, as type: Int.Type) throws -> Int? {
        if value.isEmpty { return nil }

        if let int = Int(value, radix: 10) {
            return int
        }

        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
    }

    fileprivate func unbox(_ value: String, as type: Int8.Type) throws -> Int8? {
        if value.isEmpty { return nil }

        if let int8 = Int8(value, radix: 10) {
            return int8
        }

        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
    }

    fileprivate func unbox(_ value: String, as type: Int16.Type) throws -> Int16? {
        if value.isEmpty { return nil }

        if let int16 = Int16(value, radix: 10) {
            return int16
        }

        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
    }

    fileprivate func unbox(_ value: String, as type: Int32.Type) throws -> Int32? {
        if value.isEmpty { return nil }

        if let int32 = Int32(value, radix: 10) {
            return int32
        }

        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
    }

    fileprivate func unbox(_ value: String, as type: Int64.Type) throws -> Int64? {
        if value.isEmpty { return nil }

        if let int64 = Int64(value, radix: 10) {
            return int64
        }

        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
    }

    fileprivate func unbox(_ value: String, as type: UInt.Type) throws -> UInt? {
        if value.isEmpty { return nil }

        if let uint = UInt(value, radix: 10) {
            return uint
        }

        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
    }

    fileprivate func unbox(_ value: String, as type: UInt8.Type) throws -> UInt8? {
        if value.isEmpty { return nil }

        if let uint8 = UInt8(value, radix: 10) {
            return uint8
        }

        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
    }

    fileprivate func unbox(_ value: String, as type: UInt16.Type) throws -> UInt16? {
        if value.isEmpty { return nil }

        if let uint16 = UInt16(value, radix: 10) {
            return uint16
        }

        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
    }

    fileprivate func unbox(_ value: String, as type: UInt32.Type) throws -> UInt32? {
        if value.isEmpty { return nil }

        if let uint32 = UInt32(value, radix: 10) {
            return uint32
        }

        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
    }

    fileprivate func unbox(_ value: String, as type: UInt64.Type) throws -> UInt64? {
        if value.isEmpty { return nil }

        if let uint64 = UInt64(value, radix: 10) {
            return uint64
        }

        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
    }

    fileprivate func unbox(_ value: String, as type: Double.Type) throws -> Double? {
        if value.isEmpty { return nil }

        if let float = Double(value) {
            return float
        }

        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
    }

    fileprivate func unbox(_ value: String, as type: Float.Type) throws -> Float? {
        if value.isEmpty { return nil }

        if let float = Float(value) {
            return float
        }

        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
    }

    fileprivate func unbox(_ value: String, as type: String.Type) throws -> String? {
        if value.isEmpty { return nil }

        return value
    }

    fileprivate func unbox(_ value: String, as type: Date.Type) throws -> Date? {
        if value.isEmpty { return nil }

        switch self.options.dateDecodingStrategy {
        case .deferredToDate:
            return try Date(from: self)

        case .secondsSince1970:
            let double = try self.unbox(value, as: Double.self)!
            return Date(timeIntervalSince1970: double)

        case .millisecondsSince1970:
            let double = try self.unbox(value, as: Double.self)!
            return Date(timeIntervalSince1970: double / 1000.0)

        case .iso8601:
            if #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
                guard let date = _iso8601Formatter.date(from: value) else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected date string to be ISO8601-formatted."))
                }

                return date
            } else {
                fatalError("ISO8601DateFormatter is unavailable on this platform.")
            }

        case .formatted(let formatter):
            guard let date = formatter.date(from: value) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Date string does not match format expected by formatter."))
            }

            return date

        case .custom(let closure):
            return try closure(value)
        }
    }

    fileprivate func unbox(_ value: String, as type: Data.Type) throws -> Data? {
        if value.isEmpty { return nil }

        switch self.options.dataDecodingStrategy {
        case .deferredToData:
            return try Data(from: self)

        case .base64:
            guard let data = Data(base64Encoded: value) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Encountered Data is not valid Base64."))
            }
            return data

        case .custom(let closure):
            return try closure(value)
        }
    }

    fileprivate func unbox(_ value: String, as type: Decimal.Type) throws -> Decimal? {
        if value.isEmpty { return nil }

        let doubleValue = try self.unbox(value, as: Double.self)!
        return Decimal(doubleValue)
    }

    fileprivate func unbox<T: Decodable>(_ value: String, as type: T.Type) throws -> T? {
        if value.isEmpty { return nil }

        let decoded: T
        if T.self == Date.self {
            guard let date = try unbox(value, as: Date.self) else { return nil }
            decoded = date as! T
        } else if type == Data.self {
            guard let data = try unbox(value, as: Data.self) else { return nil }
            decoded = data as! T
        } else if type == URL.self {
            guard let url = URL(string: value) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath,
                                                                        debugDescription: "Invalid URL string."))
            }
            decoded = (url as! T)
        } else if type == Decimal.self {
            guard let decimal = try self.unbox(value, as: Decimal.self) else { return nil }
            decoded = decimal as! T
        } else {
            return try type.init(from: self)
        }
        return decoded
    }

}

extension DecodingError {

    internal static func _typeMismatch(at path: [CodingKey], expectation: Any.Type, reality: String) -> DecodingError {
        let description = "Expected to decode \(expectation) but found \(reality) instead."
        return .typeMismatch(expectation, Context(codingPath: path, debugDescription: description))
    }

}

//===----------------------------------------------------------------------===//
// Shared ISO8601 Date Formatter
//===----------------------------------------------------------------------===//
// NOTE: This value is implicitly lazy and _must_ be lazy.
// We're compiled against the latest SDK (w/ ISO8601DateFormatter), but linked against whichever Foundation the user has.
// ISO8601DateFormatter might not exist, so we better not hit this code path on an older OS.
@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
fileprivate var _iso8601Formatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = .withInternetDateTime
    return formatter
}()
