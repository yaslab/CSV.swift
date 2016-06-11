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
internal let defaultEncoding = NSUTF8StringEncoding
internal let defaultDelimiter: CChar = 0x2c //','
internal let defaultBufferSize = 8192

internal let utf8BOM: [UInt8] = [0xef, 0xbb, 0xbf]
internal let utf16BigEndianBOM: [UInt8] = [0xfe, 0xff]
internal let utf16LittleEndianBOM: [UInt8] = [0xff, 0xfe]
internal let utf32BigEndianBOM: [UInt8] = [0x00, 0x00, 0xfe, 0xff]
internal let utf32LittleEndianBOM: [UInt8] = [0xff, 0xfe, 0x00, 0x00]

public class CSV: SequenceType, GeneratorType {

    private let stream: NSInputStream
    private let encoding: NSStringEncoding
    private let delimiter: UInt32
    private let bufferSize: Int

    private var buffer: UnsafeMutablePointer<UInt8>!
    private var bufferOffset: Int
    private var lastReadCount: Int

    private let charWidth: Int

    private let fieldBuffer: NSMutableData
    private var _headerRow: [String]? = nil
    private var _currentRow: [String]? = nil

    private var closed: Bool = false
    
    public private(set) var lastError: CSVError? = nil

    public init(
        stream: NSInputStream,
        hasHeaderRow: Bool = defaultHasHeaderRow,
        encoding: NSStringEncoding = defaultEncoding,
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
        self.bufferSize = bs + (4 - (bs % 4))

        self.delimiter = UInt32(delimiter)

        let b = malloc(bufferSize)
        if b == nil {
            throw CSVError.MemoryAllocationFailed
        }
        self.buffer = UnsafeMutablePointer<UInt8>(b)
        self.bufferOffset = 0

        self.fieldBuffer = NSMutableData()

        if stream.streamStatus == .NotOpen {
            stream.open()
        }
        if stream.streamStatus != .Open {
            throw CSVError.StreamError
        }

        self.lastReadCount = stream.read(self.buffer, maxLength: bufferSize)

        var e = encoding

        switch encoding {
        case NSUTF16StringEncoding,
             NSUTF16BigEndianStringEncoding,
             NSUTF16LittleEndianStringEncoding:

            charWidth = 2
            if encoding == NSUTF16StringEncoding {
                let nativeEndian = IsBigEndian()
                    ? NSUTF16BigEndianStringEncoding
                    : NSUTF16LittleEndianStringEncoding
                e = nativeEndian
                if lastReadCount >= charWidth {
                    if memcmp(buffer, utf16BigEndianBOM, charWidth) == 0 {
                        e = NSUTF16BigEndianStringEncoding
                        self.bufferOffset += charWidth
                    }
                    else if memcmp(buffer, utf16LittleEndianBOM, charWidth) == 0 {
                        e = NSUTF16LittleEndianStringEncoding
                        self.bufferOffset += charWidth
                    }
                }
            }

        case NSUTF32StringEncoding,
             NSUTF32BigEndianStringEncoding,
             NSUTF32LittleEndianStringEncoding:

            charWidth = 4
            if encoding == NSUTF32StringEncoding {
                let nativeEndian = IsBigEndian()
                    ? NSUTF32BigEndianStringEncoding
                    : NSUTF32LittleEndianStringEncoding
                e = nativeEndian
                if lastReadCount >= charWidth {
                    if memcmp(buffer, utf32BigEndianBOM, charWidth) == 0 {
                        e = NSUTF32BigEndianStringEncoding
                        self.bufferOffset += charWidth
                    }
                    else if memcmp(buffer, utf32LittleEndianBOM, charWidth) == 0 {
                        e = NSUTF32LittleEndianStringEncoding
                        self.bufferOffset += charWidth
                    }
                }
            }

        default:
            charWidth = 1
            if encoding == NSUTF8StringEncoding {
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
            _currentRow = nil
        }
    }

    deinit {
        close()
    }

    public func close() {
        if !closed {
            stream.close()
            if buffer != nil {
                free(buffer)
                buffer = nil
            }
            _headerRow = nil
            _currentRow = nil
            closed = true
        }
    }

    public var headerRow: [String]? {
        return _headerRow
    }

    public var currentRow: [String]? {
        return _currentRow
    }

    // MARK: GeneratorType
    
    public func next() -> [String]? {
        fieldBuffer.length = 0
        _currentRow = nil
        
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
                    fieldBuffer.appendBytes(buffer + fieldStart, length: charWidth * charLength)
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
            case NSUTF16BigEndianStringEncoding:
                let _c = ReadBigInt16(buffer, byteOffset: bufferOffset)
                c = UInt32(_c)

            case NSUTF16LittleEndianStringEncoding:
                let _c = ReadLittleInt16(buffer, byteOffset: bufferOffset)
                c = UInt32(_c)

            case NSUTF32BigEndianStringEncoding:
                c = ReadBigInt32(buffer, byteOffset: bufferOffset)

            case NSUTF32LittleEndianStringEncoding:
                c = ReadLittleInt32(buffer, byteOffset: bufferOffset)

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

            if c == delimiter && prev == DQUOTE && (quotationCount % 2 == 0) {
                escaping = false
            }
            
            if (c == CR || c == LF) && prev == DQUOTE && (quotationCount % 2 == 0) {
                escaping = false
            }

            // 行の終わり
            if prev == CR && c != LF && !escaping {
                fieldBuffer.appendBytes(buffer + fieldStart, length: charWidth * charLength)
                break
            }

            // 行の終わり
            if c == LF && !escaping {
                fieldBuffer.appendBytes(buffer + fieldStart, length: charWidth * charLength)
                bufferOffset += charWidth
                break
            }

            prev = c

            // 行の終わり
            if c == CR && !escaping {
                bufferOffset += charWidth
                continue
            }

            bufferOffset += charWidth

            // フィールドの終わり
            if c == delimiter && !escaping {
                fieldBuffer.appendBytes(buffer + fieldStart, length: charWidth * charLength)

                guard let field = getField(quotationCount) else {
                    return nil
                }
                fields.append(field)

                // reset
                fieldBuffer.length = 0
                quotationCount = 0
                charLength = 0

                fieldStart = bufferOffset
            }
            else {
                charLength += 1
            }
        }

        guard let field = getField(quotationCount) else {
            return nil
        }

        // 最後の空行
        if isBufferEOF && fields.count == 0 && field.isEmpty {
            return nil
        }

        fields.append(field)
        _currentRow = fields

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
            //let start = field.index(field.startIndex, offsetBy: 1)
            //let end = field.index(field.endIndex, offsetBy: -1)
            let start = field.startIndex.advancedBy(1)
            let end = field.endIndex.advancedBy(-1)
            field = field[start..<end]
        }

        if quotationCount >= 4 {
            field = field.stringByReplacingOccurrencesOfString("\"\"", withString: "\"")
        }

        return field
    }

}

extension CSV {
    
    public convenience init(
        path: String,
        hasHeaderRow: Bool = defaultHasHeaderRow,
        encoding: NSStringEncoding = defaultEncoding)
        throws
    {
        guard let stream = NSInputStream(fileAtPath: path) else {
            throw CSVError.StreamError
        }
        try self.init(stream: stream, hasHeaderRow: hasHeaderRow, encoding: encoding)
    }
    
    public convenience init(
        url: NSURL,
        hasHeaderRow: Bool = defaultHasHeaderRow,
        encoding: NSStringEncoding = defaultEncoding)
        throws
    {
        guard let stream = NSInputStream(URL: url) else {
            throw CSVError.StreamError
        }
        try self.init(stream: stream, hasHeaderRow: hasHeaderRow, encoding: encoding)
    }
    
    public convenience init(
        string: String,
        hasHeaderRow: Bool = defaultHasHeaderRow)
        throws
    {
        let encoding = defaultEncoding
        guard let data = string.dataUsingEncoding(encoding) else {
            throw CSVError.StringEncodingMismatch
        }
        let memoryStream = NSInputStream(data: data)
        try self.init(stream: memoryStream, hasHeaderRow: hasHeaderRow, encoding: encoding)
    }
    
}
