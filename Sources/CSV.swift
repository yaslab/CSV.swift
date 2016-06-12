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

    internal let stream: NSInputStream
    internal let encoding: NSStringEncoding
    internal let delimiter: UInt32
    internal let bufferSize: Int

    internal var buffer: UnsafeMutablePointer<UInt8>!
    internal var bufferOffset: Int
    internal var lastReadCount: Int

    internal let charWidth: Int

    internal let fieldBuffer: NSMutableData

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
        fieldBuffer.length = 0
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

            if escaping && prev == DQUOTE && (c == delimiter || c == CR || c == LF) && (quotationCount % 2 == 0) {
                escaping = false
            }
            
            if !escaping && prev == CR && c != LF {
                fieldBuffer.appendBytes(buffer + fieldStart, length: charWidth * charLength)
                break
            }

            prev = c
            bufferOffset += charWidth

            if !escaping {
                if c == CR {
                    continue
                }
                if c == LF {
                    fieldBuffer.appendBytes(buffer + fieldStart, length: charWidth * charLength)
                    break
                }
            }

            // フィールドの終わり
            if !escaping && c == delimiter {
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
