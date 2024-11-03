//
//  CSVRowDecoder.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2018/11/17.
//  Copyright © 2018 yaslab. All rights reserved.
//

import Foundation

/// `CSVRowDecoder` facilitates the decoding of CSV row into semantic `Decodable` types.
open class CSVRowDecoder {

    /// The strategy to use for decoding `Bool` values.
    public enum BoolDecodingStrategy {
        /// Decode the `Bool` using default initializer.
        case `default`

        /// Decode the `Bool` as a custom value decoded by the given closure.
        case custom((_ value: String) throws -> Bool)
    }

    /// The strategy to use for decoding `String` values.
    @available(*, deprecated, renamed: "NilDecodingStrategy")
    public enum StringDecodingStrategy {
        /// Decode empty String to `nil`
        @available(*, deprecated, renamed: "NilDecodingStrategy.empty")
        case `default`

        /// Decode empty String to `""`
        @available(*, deprecated, renamed: "NilDecodingStrategy.never")
        case allowEmpty

        /// Decode the `Bool` as a custom value decoded by the given closure.
        @available(*, unavailable, renamed: "NilDecodingStrategy.custom")
        case custom((_ value: String) throws -> String)
    }

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
        // TODO: Implement unkeyed decoding container.
        // /// Defer to `Data` for decoding.
        // case deferredToData

        /// Decode the `Data` from a Base64-encoded string. This is the default strategy.
        case base64

        /// Decode the `Data` as a custom value decoded by the given closure.
        case custom((_ value: String) throws -> Data)
    }

    public enum KeyDecodingStrategy {
        case useDefaultKeys
        case convertFromSnakeCase
        case custom((_ codingPath: String) -> String)

        func call(_ key: String) -> String {
            switch self {
            case .useDefaultKeys:
                return key
            case .convertFromSnakeCase:
                return Self._convertFromSnakeCase(key)
            case .custom(let converter):
                return converter(key)
            }
        }

        /// convert snake-case to camelCase
        /// 
        /// `oneTwoThree` -> `oneTwoThree`
        ///
        /// `one_two_three` -> `oneTwoThree`
        /// 
        /// `_one_two_three_` -> `_oneTwoThree_`
        /// 
        /// `__one__two__three__` -> `__oneTwoThree__`
        /// 
        /// `ONE_TWO_THREE` -> `oneTwoThree`
        /// 
        /// `ONE` -> `ONE`
        /// 
        /// - Parameter key: key in snake case format
        /// - Returns: key in camel case format
        private static func _convertFromSnakeCase(_ key: String) -> String {
            // match anything but underscore
            let nonUnderscore = try! NSRegularExpression(pattern: "[^_]+")

            let matches = nonUnderscore.matches(in: key, range: NSRange(key.startIndex..., in: key))

            var keyParts = matches.map {
                String(key[Range($0.range, in: key)!])
            }

            if keyParts.count <= 1 {
                return key
            }

            keyParts[0] = keyParts[0].lowercased()
            for i in 1..<keyParts.count {
                keyParts[i] = keyParts[i].capitalized
            }

            let pre = String(key.prefix(while: { $0 == "_" }))
            let post = String(key.suffix(while: { $0 == "_" }))

            return pre + keyParts.joined() + post
        }
    }

    /// The strategy to use for decoding `nil` values.
    public enum NilDecodingStrategy {
        /// Decode empty String to `nil`. This is the default strategy.
        case empty

        /// Never convert to `nil`.
        case never

        /// Determines if a String is `nil` using the given closure.
        case custom((_ value: String) -> Bool)
    }

    /// The strategy to use in decoding bools. Defaults to `.default`.
    open var boolDecodingStrategy: BoolDecodingStrategy = .default

    /// The strategy to use in decoding strings. Defaults to `.default`.
    @available(*, deprecated, renamed: "nilDecodingStrategy")
    open var stringDecodingStrategy: StringDecodingStrategy {
        get {
            switch nilDecodingStrategy {
            case .empty: return .default
            case .never: return .allowEmpty
            case .custom: fatalError("'StringDecodingStrategy.custom' is deprecated: renamed to 'NilDecodingStrategy.custom'")
            }
        }
        set {
            switch newValue {
            case .default: nilDecodingStrategy = .empty
            case .allowEmpty: nilDecodingStrategy = .never
            }
        }
    }

    /// The strategy to use in decoding dates. Defaults to `.deferredToDate`.
    open var dateDecodingStrategy: DateDecodingStrategy = .deferredToDate

    /// The strategy to use in decoding binary data. Defaults to `.base64`.
    open var dataDecodingStrategy: DataDecodingStrategy = .base64

    /// The strategy to use in decoding keys. Defaults to `.useDefaultKeys`
    open var keyDecodingStrategy: KeyDecodingStrategy = .useDefaultKeys

    /// The strategy to use in decoding nil data. Defaults to `.empty`.
    open var nilDecodingStrategy: NilDecodingStrategy = .empty

    /// Contextual user-provided information for use during decoding.
    open var userInfo: [CodingUserInfoKey: Any] = [:]

    /// Options set on the top-level encoder to pass down the decoding hierarchy.
    fileprivate struct _Options {
        let boolDecodingStrategy: BoolDecodingStrategy
        let dateDecodingStrategy: DateDecodingStrategy
        let dataDecodingStrategy: DataDecodingStrategy
        let keyDecodingStrategy: KeyDecodingStrategy
        let nilDecodingStrategy: NilDecodingStrategy
        let userInfo: [CodingUserInfoKey: Any]
    }

    /// The options set on the top-level decoder.
    fileprivate var options: _Options {
        return _Options(boolDecodingStrategy: boolDecodingStrategy,
                        dateDecodingStrategy: dateDecodingStrategy,
                        dataDecodingStrategy: dataDecodingStrategy,
                        keyDecodingStrategy: keyDecodingStrategy,
                        nilDecodingStrategy: nilDecodingStrategy,
                        userInfo: userInfo)
    }

    /// Initializes `self` with default strategies.
    public init() {}

    /// Decodes a top-level value of the given type from the given CSV row representation.
    open func decode<T: Decodable>(_ type: T.Type, from reader: CSVReader) throws -> T {
        let decoder = _CSVRowDecoder(referencing: reader, options: self.options)
        return try type.init(from: decoder)
    }

}

fileprivate extension String {
    func suffix(while predicate: (Element) throws -> Bool) rethrows -> SubSequence {
        var index = self.index(endIndex, offsetBy: -1)
        while index >= startIndex, try predicate(self[index]) {
            index = self.index(before: index)
        }
        return index < startIndex ? self[self.index(after: index)...] : ""
    }
}

fileprivate final class _CSVRowDecoder: Decoder {

    fileprivate let reader: CSVReader

    fileprivate let options: CSVRowDecoder._Options

    fileprivate let headerRow: [String]?

    public var codingPath: [CodingKey] = []

    public var userInfo: [CodingUserInfoKey: Any] {
        return self.options.userInfo
    }

    fileprivate init(referencing reader: CSVReader, options: CSVRowDecoder._Options) {
        self.reader = reader
        self.options = options

        if let headerRow = reader.headerRow {
            self.headerRow = headerRow.map { options.keyDecodingStrategy.call($0) }
        } else {
            self.headerRow = nil
        }
    }

    public func container<Key: CodingKey>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
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

fileprivate final class CSVKeyedDecodingContainer<K: CodingKey>: KeyedDecodingContainerProtocol {

    typealias Key = K

    private let decoder: _CSVRowDecoder

    public var codingPath: [CodingKey] {
        return self.decoder.codingPath
    }

    public var allKeys: [Key] {
        guard let headerRow = self.decoder.headerRow else { return [] }
        return headerRow.compactMap { Key(stringValue: $0) }
    }

    fileprivate init(referencing decoder: _CSVRowDecoder) {
        self.decoder = decoder
    }

    private func value(for key: Key) throws -> String {
        guard self.contains(key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }

        if let index = key.intValue {
            return self.decoder[index]!
        } else {
            return self.decoder[key.stringValue]!
        }
    }

    private func _valueNotFound(_ type: Any.Type) -> DecodingError {
        let description = "Expected \(type) value but found null instead."
        return .valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: description))
    }

    public func contains(_ key: Key) -> Bool {
        guard let row = self.decoder.reader.currentRow else { return false }

        if let index = key.intValue {
            return index < row.count
        } else {
            guard let headerRow = self.decoder.headerRow else {
                return false
            }
            return headerRow.contains(key.stringValue)
        }
    }

    public func decodeNil(forKey key: Key) throws -> Bool {
        try self.decoder._isNil(self.value(for: key))
    }

    public func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        let value = try self.value(for: key)

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let result = try self.decoder.unbox(value, as: Bool.self) else {
            throw _valueNotFound(type)
        }
        return result
    }

    public func decode(_ type: String.Type, forKey key: Key) throws -> String {
        let value = try self.value(for: key)

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let result = try self.decoder.unbox(value, as: String.self) else {
            throw _valueNotFound(type)
        }
        return result
    }

    public func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        let value = try self.value(for: key)

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let result = try self.decoder.unbox(value, as: Double.self) else {
            throw _valueNotFound(type)
        }
        return result
    }

    public func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        let value = try self.value(for: key)

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let result = try self.decoder.unbox(value, as: Float.self) else {
            throw _valueNotFound(type)
        }
        return result
    }

    public func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        let value = try self.value(for: key)

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let result = try self.decoder.unbox(value, as: Int.self) else {
            throw _valueNotFound(type)
        }
        return result
    }

    public func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        let value = try self.value(for: key)

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let result = try self.decoder.unbox(value, as: Int8.self) else {
            throw _valueNotFound(type)
        }
        return result
    }

    public func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        let value = try self.value(for: key)

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let result = try self.decoder.unbox(value, as: Int16.self) else {
            throw _valueNotFound(type)
        }
        return result
    }

    public func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        let value = try self.value(for: key)

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let result = try self.decoder.unbox(value, as: Int32.self) else {
            throw _valueNotFound(type)
        }
        return result
    }

    public func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        let value = try self.value(for: key)

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let result = try self.decoder.unbox(value, as: Int64.self) else {
            throw _valueNotFound(type)
        }
        return result
    }

    public func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        let value = try self.value(for: key)

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let result = try self.decoder.unbox(value, as: UInt.self) else {
            throw _valueNotFound(type)
        }
        return result
    }

    public func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        let value = try self.value(for: key)

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let result = try self.decoder.unbox(value, as: UInt8.self) else {
            throw _valueNotFound(type)
        }
        return result
    }

    public func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        let value = try self.value(for: key)

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let result = try self.decoder.unbox(value, as: UInt16.self) else {
            throw _valueNotFound(type)
        }
        return result
    }

    public func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        let value = try self.value(for: key)

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let result = try self.decoder.unbox(value, as: UInt32.self) else {
            throw _valueNotFound(type)
        }
        return result
    }

    public func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        let value = try self.value(for: key)

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let result = try self.decoder.unbox(value, as: UInt64.self) else {
            throw _valueNotFound(type)
        }
        return result
    }

    public func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
        let value = try self.value(for: key)

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let result = try self.decoder.unbox(value, as: type) else {
            throw _valueNotFound(type)
        }
        return result
    }

    public func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> {
        // Not supported
        throw DecodingError.dataCorrupted(
            DecodingError.Context(codingPath: self.codingPath,
                                  debugDescription: "nestedContainer(...) CSV does not support nested values")
        )
    }

    public func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        // Not supported
        throw DecodingError.dataCorrupted(
            DecodingError.Context(codingPath: self.codingPath,
                                  debugDescription: "nestedUnkeyedContainer(...) CSV does not support nested values")
        )
    }

    public func superDecoder() throws -> Decoder {
        // Not supported
        throw DecodingError.dataCorrupted(
            DecodingError.Context(codingPath: self.codingPath,
                                  debugDescription: "CSV does not support nested values")
        )
    }

    public func superDecoder(forKey key: Key) throws -> Decoder {
        // Not supported
        throw DecodingError.dataCorrupted(
            DecodingError.Context(codingPath: self.codingPath,
                                  debugDescription: "CSV does not support nested values")
        )
    }

}

extension _CSVRowDecoder {

    public subscript(index: Int) -> String? {
        return reader.currentRow![index]
    }

    public subscript(key: String) -> String? {
        guard let header = headerRow else {
            fatalError("CSVReader.headerRow must not be nil")
        }
        guard let index = header.firstIndex(of: key) else {
            return nil
        }
        guard let row = reader.currentRow else {
            fatalError("CSVReader.currentRow must not be nil")
        }
        guard index < row.count else {
            return ""
        }
        return row[index]
    }

}

extension _CSVRowDecoder: SingleValueDecodingContainer {

    private var value: String {
        let key = self.codingPath.last!
        if let index = key.intValue {
            return self.reader.currentRow![index]
        } else {
            return self[key.stringValue]!
        }
    }

    private func expectNonNull(_ type: Any.Type) throws {
        guard !self.decodeNil() else {
            let description = "Expected \(type) but found null value instead."
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.codingPath, debugDescription: description))
        }
    }

    public func decodeNil() -> Bool {
        self._isNil(self.value)
    }

    public func decode(_ type: Bool.Type) throws -> Bool {
        try self.expectNonNull(type)
        return try self.unbox(self.value, as: Bool.self)!
    }

    public func decode(_ type: Int.Type) throws -> Int {
        try self.expectNonNull(type)
        return try self.unbox(self.value, as: Int.self)!
    }

    public func decode(_ type: Int8.Type) throws -> Int8 {
        try self.expectNonNull(type)
        return try self.unbox(self.value, as: Int8.self)!
    }

    public func decode(_ type: Int16.Type) throws -> Int16 {
        try self.expectNonNull(type)
        return try self.unbox(self.value, as: Int16.self)!
    }

    public func decode(_ type: Int32.Type) throws -> Int32 {
        try self.expectNonNull(type)
        return try self.unbox(self.value, as: Int32.self)!
    }

    public func decode(_ type: Int64.Type) throws -> Int64 {
        try self.expectNonNull(type)
        return try self.unbox(self.value, as: Int64.self)!
    }

    public func decode(_ type: UInt.Type) throws -> UInt {
        try self.expectNonNull(type)
        return try self.unbox(self.value, as: UInt.self)!
    }

    public func decode(_ type: UInt8.Type) throws -> UInt8 {
        try self.expectNonNull(type)
        return try self.unbox(self.value, as: UInt8.self)!
    }

    public func decode(_ type: UInt16.Type) throws -> UInt16 {
        try self.expectNonNull(type)
        return try self.unbox(self.value, as: UInt16.self)!
    }

    public func decode(_ type: UInt32.Type) throws -> UInt32 {
        try self.expectNonNull(type)
        return try self.unbox(self.value, as: UInt32.self)!
    }

    public func decode(_ type: UInt64.Type) throws -> UInt64 {
        try self.expectNonNull(type)
        return try self.unbox(self.value, as: UInt64.self)!
    }

    public func decode(_ type: Float.Type) throws -> Float {
        try self.expectNonNull(type)
        return try self.unbox(self.value, as: Float.self)!
    }

    public func decode(_ type: Double.Type) throws -> Double {
        try self.expectNonNull(type)
        return try self.unbox(self.value, as: Double.self)!
    }

    public func decode(_ type: String.Type) throws -> String {
        try self.expectNonNull(type)
        return try self.unbox(self.value, as: String.self)!
    }

    public func decode<T: Decodable>(_ type: T.Type) throws -> T {
        try self.expectNonNull(type)
        return try self.unbox(self.value, as: type)!
    }

}

extension _CSVRowDecoder {

    private func _typeMismatch(at path: [CodingKey], expectation: Any.Type, reality: String) -> DecodingError {
        let description = "Expected to decode \(expectation) but found \(reality) instead."
        return .typeMismatch(expectation, DecodingError.Context(codingPath: path, debugDescription: description))
    }

    fileprivate func _isNil(_ value: String) -> Bool {
        switch self.options.nilDecodingStrategy {
        case .empty:
            return value.isEmpty

        case .never:
            return false

        case .custom(let closure):
            return closure(value)
        }
    }

    fileprivate func unbox(_ value: String, as type: Bool.Type) throws -> Bool? {
        if _isNil(value) { return nil }

        switch self.options.boolDecodingStrategy {
        case .default:
            guard let bool = Bool(value) else {
                throw self._typeMismatch(at: self.codingPath, expectation: type, reality: value)
            }
            return bool

        case .custom(let closure):
            return try closure(value)
        }
    }

    fileprivate func unbox(_ value: String, as type: Int.Type) throws -> Int? {
        if _isNil(value) { return nil }

        guard let int = Int(value, radix: 10) else {
            throw self._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }
        return int
    }

    fileprivate func unbox(_ value: String, as type: Int8.Type) throws -> Int8? {
        if _isNil(value) { return nil }

        guard let int8 = Int8(value, radix: 10) else {
            throw self._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }
        return int8
    }

    fileprivate func unbox(_ value: String, as type: Int16.Type) throws -> Int16? {
        if _isNil(value) { return nil }

        guard let int16 = Int16(value, radix: 10) else {
            throw self._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }
        return int16
    }

    fileprivate func unbox(_ value: String, as type: Int32.Type) throws -> Int32? {
        if _isNil(value) { return nil }

        guard let int32 = Int32(value, radix: 10) else {
            throw self._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }
        return int32
    }

    fileprivate func unbox(_ value: String, as type: Int64.Type) throws -> Int64? {
        if _isNil(value) { return nil }

        guard let int64 = Int64(value, radix: 10) else {
            throw self._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }
        return int64
    }

    fileprivate func unbox(_ value: String, as type: UInt.Type) throws -> UInt? {
        if _isNil(value) { return nil }

        guard let uint = UInt(value, radix: 10) else {
            throw self._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }
        return uint
    }

    fileprivate func unbox(_ value: String, as type: UInt8.Type) throws -> UInt8? {
        if _isNil(value) { return nil }

        guard let uint8 = UInt8(value, radix: 10) else {
            throw self._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }
        return uint8
    }

    fileprivate func unbox(_ value: String, as type: UInt16.Type) throws -> UInt16? {
        if _isNil(value) { return nil }

        guard let uint16 = UInt16(value, radix: 10) else {
            throw self._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }
        return uint16
    }

    fileprivate func unbox(_ value: String, as type: UInt32.Type) throws -> UInt32? {
        if _isNil(value) { return nil }

        guard let uint32 = UInt32(value, radix: 10) else {
            throw self._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }
        return uint32
    }

    fileprivate func unbox(_ value: String, as type: UInt64.Type) throws -> UInt64? {
        if _isNil(value) { return nil }

        guard let uint64 = UInt64(value, radix: 10) else {
            throw self._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }
        return uint64
    }

    fileprivate func unbox(_ value: String, as type: Float.Type) throws -> Float? {
        if _isNil(value) { return nil }

        guard let float = Float(value) else {
            throw self._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }
        return float
    }

    fileprivate func unbox(_ value: String, as type: Double.Type) throws -> Double? {
        if _isNil(value) { return nil }

        guard let double = Double(value) else {
            throw self._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }
        return double
    }

    fileprivate func unbox(_ value: String, as type: String.Type) throws -> String? {
        if _isNil(value) { return nil }

        return value
    }

    private func unbox(_ value: String, as type: Date.Type) throws -> Date? {
        if _isNil(value) { return nil }

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
                guard let date = _ISO8601DateFormatterWrapper.shared.date(from: value) else {
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

    private func unbox(_ value: String, as type: Data.Type) throws -> Data? {
        if _isNil(value) { return nil }

        switch self.options.dataDecodingStrategy {
        // TODO: Implement unkeyed decoding container.
        // case .deferredToData:
        //     return try Data(from: self)

        case .base64:
            guard let data = Data(base64Encoded: value) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Encountered Data is not valid Base64."))
            }
            return data

        case .custom(let closure):
            return try closure(value)
        }
    }

    fileprivate func unbox<T: Decodable>(_ value: String, as type: T.Type) throws -> T? {
        if _isNil(value) { return nil }

        if type == Date.self {
            guard let date = try self.unbox(value, as: Date.self) else { return nil }
            return (date as! T)
        } else if type == Data.self {
            guard let data = try self.unbox(value, as: Data.self) else { return nil }
            return (data as! T)
        } else if type == URL.self {
            guard let url = URL(string: value) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath,
                                                                        debugDescription: "Invalid URL string."))
            }
            return (url as! T)
        } else if type == Decimal.self {
            guard let decimal = Decimal(string: value) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath,
                                                                        debugDescription: "Invalid Decimal string."))
            }
            return (decimal as! T)
        } else {
            return try type.init(from: self)
        }
    }

}

//===----------------------------------------------------------------------===//
// Shared ISO8601 Date Formatter
//===----------------------------------------------------------------------===//
// NOTE: This value is implicitly lazy and _must_ be lazy.
// We're compiled against the latest SDK (w/ ISO8601DateFormatter), but linked against whichever Foundation the user has.
// ISO8601DateFormatter might not exist, so we better not hit this code path on an older OS.
@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
struct _ISO8601DateFormatterWrapper: @unchecked Sendable {
  private let formatter: ISO8601DateFormatter
  init() {
    self.formatter = ISO8601DateFormatter()
    self.formatter.formatOptions = .withInternetDateTime
  }
  func date(from string: String) -> Date? {
    return formatter.date(from: string)
  }

  static let shared: _ISO8601DateFormatterWrapper = .init()
}
