//
//  CSV.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/06/11.
//
//

import Foundation

private let LF: UInt32 = 0x0a //'\n'
private let CR: UInt32 = 0x0d //'\r'
private let DQUOTE: UInt32 = 0x22 //'"'

internal let defaultHasHeaderRow = false
internal let defaultEncoding: String.Encoding = .utf8
internal let defaultDelimiter: CChar = 0x2c //','
internal let defaultBufferSize = 8192

internal let utf8BOM: [UInt8] = [0xef, 0xbb, 0xbf]
internal let utf16BigEndianBOM: [UInt8] = [0xfe, 0xff]
internal let utf16LittleEndianBOM: [UInt8] = [0xff, 0xfe]
internal let utf32BigEndianBOM: [UInt8] = [0x00, 0x00, 0xfe, 0xff]
internal let utf32LittleEndianBOM: [UInt8] = [0xff, 0xfe, 0x00, 0x00]

public class CSV: Sequence, IteratorProtocol {

    internal let stream: InputStream
    internal let encoding: String.Encoding
    internal let delimiter: UInt32
    internal let bufferSize: Int

    internal var buffer: UnsafeMutablePointer<UInt8>!
    internal var bufferOffset: Int
    internal var lastReadCount: Int

    internal let charWidth: Int

    internal var fieldBuffer: Data

    internal var closed: Bool = false

    internal var currentRow: [String]? = nil
    
    /**
     CSV header row. To set a value for this property, you set `true` to `hasHeaerRow` in initializer.
     */
    public var headerRow: [String]? { return _headerRow }
    private var _headerRow: [String]? = nil
    
    /** 
     The value is set when an error occurs.
     */
    public private(set) var lastError: CSVError? = nil

    /**
     Create CSV instance with `NSInputStream`.
     
     - parameter stream: An `NSInputStream` object. If the stream is not open, initializer opens automatically.
     - parameter hasHeaderRow: `true` if the CSV has a header row, otherwise `false`. Default: `false`.
     - parameter encoding: The character encoding for `stream`. Default: `NSUTF8StringEncoding`.
     - parameter delimiter: Default: `","`.
     - parameter bufferSize: Size in bytes to be read at a time from the stream. Default: `8192`.
     */
    public init(
        stream: InputStream,
        hasHeaderRow: Bool = defaultHasHeaderRow,
        encoding: String.Encoding = defaultEncoding,
        delimiter: CChar = defaultDelimiter,
        bufferSize: Int = defaultBufferSize)
        throws
    {
        self.stream = stream

        var bs = bufferSize
        if bs < 0 {
            throw CSVError.ParameterError
        }
        if bs < 8 {
            bs = 8
        }
        let mod = bs % 4
        if mod != 0 {
            bs += 4 - mod
        }
        self.bufferSize = bs

        self.delimiter = UInt32(delimiter)

        let b = malloc(bufferSize)
        if b == nil {
            throw CSVError.MemoryAllocationFailed
        }
        self.buffer = UnsafeMutablePointer<UInt8>(b)
        self.bufferOffset = 0

        self.fieldBuffer = Data()

        if stream.streamStatus == .notOpen {
            stream.open()
        }
        if stream.streamStatus != .open {
            throw CSVError.StreamError
        }

        self.lastReadCount = stream.read(self.buffer, maxLength: bufferSize)

        var e = encoding

        switch encoding {
        case String.Encoding.utf16,
             String.Encoding.utf16BigEndian,
             String.Encoding.utf16LittleEndian:

            charWidth = 2
            if encoding == .utf16 {
                let nativeEndian: String.Encoding = IsBigEndian()
                    ? .utf16BigEndian
                    : .utf16LittleEndian
                e = nativeEndian
                if lastReadCount >= charWidth {
                    if memcmp(buffer, utf16BigEndianBOM, charWidth) == 0 {
                        e = .utf16BigEndian
                        self.bufferOffset += charWidth
                    }
                    else if memcmp(buffer, utf16LittleEndianBOM, charWidth) == 0 {
                        e = .utf16LittleEndian
                        self.bufferOffset += charWidth
                    }
                }
            }

        case String.Encoding.utf32,
             String.Encoding.utf32BigEndian,
             String.Encoding.utf32LittleEndian:

            charWidth = 4
            if encoding == .utf32 {
                let nativeEndian: String.Encoding = IsBigEndian()
                    ? .utf32BigEndian
                    : .utf32LittleEndian
                e = nativeEndian
                if lastReadCount >= charWidth {
                    if memcmp(buffer, utf32BigEndianBOM, charWidth) == 0 {
                        e = .utf32BigEndian
                        self.bufferOffset += charWidth
                    }
                    else if memcmp(buffer, utf32LittleEndianBOM, charWidth) == 0 {
                        e = .utf32LittleEndian
                        self.bufferOffset += charWidth
                    }
                }
            }

        default:
            charWidth = 1
            if encoding == .utf8 {
                let bomSize = 3
                if lastReadCount >= bomSize {
                    if memcmp(buffer, utf8BOM, charWidth) == 0 {
                        self.bufferOffset += bomSize
                    }
                }
            }
        }

        self.encoding = e

        if hasHeaderRow {
            guard let nextRow = next() else {
                throw CSVError.HeaderReadError
            }
            _headerRow = nextRow
            currentRow = nil
        }
    }

    deinit {
        close()
    }

    /**
     Close stream.
     */
    public func close() {
        if !closed {
            stream.close()
            if buffer != nil {
                free(buffer)
                buffer = nil
            }
            closed = true
        }
    }

    // MARK: GeneratorType
    
    public func next() -> [String]? {
        fieldBuffer.count = 0
        currentRow = nil
        
        if closed {
            return nil
        }
        if lastReadCount <= 0 {
            return nil
        }

        var fields = [String]()

        var fieldStart = bufferOffset
        var charLength = 0
        var escaping = false
        var quotationCount = 0

        var prev: UInt32 = 0

        while true {
            if bufferOffset >= lastReadCount {
                if charLength > 0 {
                    fieldBuffer.append(buffer + fieldStart, count: charWidth * charLength)
                }
                bufferOffset = 0
                fieldStart = 0
                charLength = 0

                lastReadCount = stream.read(buffer, maxLength: bufferSize)
                if lastReadCount < 0 {
                    // bad end
                    lastError = CSVError.StreamError
                    return nil
                }
                if lastReadCount == 0 {
                    // true end
                    break
                }
            }

            var c: UInt32 = 0

            switch encoding {
            case String.Encoding.utf16BigEndian:
                let _c = ReadBigInt16(base: buffer, byteOffset: bufferOffset)
                c = UInt32(_c)

            case String.Encoding.utf16LittleEndian:
                let _c = ReadLittleInt16(base: buffer, byteOffset: bufferOffset)
                c = UInt32(_c)

            case String.Encoding.utf32BigEndian:
                c = ReadBigInt32(base: buffer, byteOffset: bufferOffset)

            case String.Encoding.utf32LittleEndian:
                c = ReadLittleInt32(base: buffer, byteOffset: bufferOffset)

            default: // multi-byte character encodings
                let _c = (buffer + bufferOffset)[0]
                c = UInt32(_c)
            }

            if c == DQUOTE {
                quotationCount += 1
            }

            if c == DQUOTE && charLength == 0 {
                escaping = true
            }

            if escaping && prev == DQUOTE && (c == delimiter || c == CR || c == LF) && (quotationCount % 2 == 0) {
                escaping = false
            }
            
            if !escaping && prev == CR && c != LF {
                fieldBuffer.append(buffer + fieldStart, count: charWidth * charLength)
                break
            }

            prev = c
            bufferOffset += charWidth

            if !escaping {
                if c == CR {
                    continue
                }
                if c == LF {
                    fieldBuffer.append(buffer + fieldStart, count: charWidth * charLength)
                    break
                }
            }

            // フィールドの終わり
            if !escaping && c == delimiter {
                fieldBuffer.append(buffer + fieldStart, count: charWidth * charLength)

                guard let field = getField(quotationCount: quotationCount) else {
                    return nil
                }
                fields.append(field)

                // reset
                fieldBuffer.count = 0
                quotationCount = 0
                charLength = 0

                fieldStart = bufferOffset
            }
            else {
                charLength += 1
            }
        }

        guard let field = getField(quotationCount: quotationCount) else {
            return nil
        }

        // 最後の空行
        if isBufferEOF && fields.count == 0 && field.isEmpty {
            return nil
        }

        fields.append(field)
        currentRow = fields

        return fields
    }
    
    // MARK: Utility

    private var isBufferEOF: Bool {
        if stream.hasBytesAvailable {
            return false
        }
        return bufferOffset >= (lastReadCount - 1)
    }

    private func getField(quotationCount: Int) -> String? {
        guard var field = String(data: fieldBuffer, encoding: encoding) else {
            lastError = CSVError.StringEncodingMismatch
            return nil
        }

        if quotationCount >= 2
            && field.hasPrefix("\"")
            && field.hasSuffix("\"")
        {
            let start = field.index(field.startIndex, offsetBy: 1)
            let end = field.index(field.endIndex, offsetBy: -1)
            field = field[start..<end]
        }

        if quotationCount >= 4 {
            field = field.replacingOccurrences(of: "\"\"", with: "\"")
        }

        return field
    }

}
