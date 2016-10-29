//
//  ElementValue.swift
//  Bison
//

import Foundation

extension Element {
    
    public enum Value {
        
        case double(Double)
        case string(String)
        case document(Document)
        case array([Value])
        case binary(BinarySubtype, data: [Byte])
        case objectID(ObjectID)
        case bool(Bool)
        case utcDate(UTCDate)
        case null
        case regex(pattern: CString, options: CString)
        case javaScript(String)
        case scopedJavaScript(String, scope: Document)
        case int32(Int32)
        case timestamp(Timestamp)
        case int64(Int64)
        case decimal128(Decimal128)
        case minKey
        case maxKey
    }
}

extension Element.Value {
    
    var _kind: Byte {
        
        switch self {
            
        case .double:           return 0x01
        case .string:           return 0x02
        case .document:         return 0x03
        case .array:            return 0x04
        case .binary:           return 0x05
        case .objectID:         return 0x07
        case .bool:             return 0x08
        case .utcDate:          return 0x09
        case .null:             return 0x0A
        case .regex:            return 0x0B
        case .javaScript:       return 0x0D
        case .scopedJavaScript: return 0x0F
        case .int32:            return 0x10
        case .timestamp:        return 0x11
        case .int64:            return 0x12
        case .decimal128:       return 0x13
        case .minKey:           return 0xFF
        case .maxKey:           return 0x7F
        }
    }
}

extension Element.Value : _ByteConvertible {
    
    var _bytes: [Byte] {
        
        var bytes = [Byte]()
        
        switch self {
            
        case .double(let value):
            bytes.append(contentsOf: value._bytes)
            
        case .string(let value):
            bytes.append(contentsOf: value._bytes)
            
        case .document(let value):
            bytes.append(contentsOf: value._bytes)
            
        case .array(let values):
            bytes.append(contentsOf: values._bytes)
            
        case .binary(let subtype, data: let data):
            bytes.append(contentsOf: Int32(data.count)._bytes)
            bytes.append(subtype.rawValue)
            bytes.append(contentsOf: data)
            
            //        case .objectID(_):
            
        case .bool(let value):
            bytes.append(value._byte)
            
        case .utcDate(let value):
            bytes.append(contentsOf: value._bytes)
            
        case .regex(pattern: let pattern, options: let options):
            bytes.append(contentsOf: pattern._bytes)
            bytes.append(contentsOf: options._bytes)
            
        case .javaScript(let value):
            bytes.append(contentsOf: value._bytes)
            
        case .scopedJavaScript(let string, let document):
            var tempBytes = [Byte]()
            tempBytes.append(contentsOf: string._bytes)
            tempBytes.append(contentsOf: document._bytes)
            bytes.append(contentsOf: Int32(tempBytes.count)._bytes)
            bytes.append(contentsOf: tempBytes)
            
        case .int32(let value):
            bytes.append(contentsOf: value._bytes)
            
        case .timestamp(let value):
            bytes.append(contentsOf: value._bytes)
            
        case .int64(let value):
            bytes.append(contentsOf: value._bytes)
            
        case .decimal128(let value):
            bytes.append(contentsOf: _convertToBytes(value))
            
        default:
            break
        }
        
        return bytes
    }
}

extension Element.Value : ExpressibleByFloatLiteral {
    
    public init(floatLiteral value: Double) {
        
        self = .double(value)
    }
}

extension Element.Value : ExpressibleByNilLiteral {
    
    public init(nilLiteral: ()) {
        
        self = .null
    }
}

extension Element.Value : ExpressibleByStringLiteral {
    
    public init(string: String) {
        
        self = .string(string)
    }
    
    public init(stringLiteral value: String) {
        
        self.init(string: value)
    }
    
    public init(unicodeScalarLiteral value: String) {
        
        self.init(string: value)
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        
        self.init(string: value)
    }
}

extension Element.Value : ExpressibleByBooleanLiteral {
    
    public init(booleanLiteral value: Bool) {
        
        self = .bool(value)
    }
}

extension Element.Value : ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: Int64) {
        
        self = .int64(value)
    }
}
