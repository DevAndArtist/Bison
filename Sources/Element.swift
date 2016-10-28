//
//  Element.swift
//  Bison
//

import Foundation

public struct Element {
    
    public let name: CString
    public let value: Value
    
    public init(name: CString, value: Value) {
        
        self.name = name
        self.value = value
    }
    
    public init(name: String, value: Value) {
        
        self.name = CString(string: name)
        self.value = value
    }
}

extension Element : _ByteConvertible {
    
    var _bytes: [Byte] {

        var bytes = [Byte]()
        bytes.append(self.value._kind)
        bytes.append(contentsOf: self.name._bytes)
        bytes.append(contentsOf: self.value._bytes)
        return bytes
    }
}

extension Element {
    
    public enum Value {
        
        case double(Double)
        case string(String)
        case document(Document)
        case documentArray(Document)
        case binary
        case objectID(ObjectID)
        case bool(Bool)
        case utcDate(UTCDate)
        case null
        case regex(CString, CString)
        case javaScript
        case scopedJavaScript
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
        case .documentArray:    return 0x04
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
            let utf8CString = value.utf8CString.map { Byte($0) }
            bytes.append(contentsOf: Int32(utf8CString.count)._bytes)
            bytes.append(contentsOf: utf8CString)
            
        case .document(let value):
            bytes.append(contentsOf: value._bytes)
            
        case .documentArray(let value):
            bytes.append(contentsOf: value._bytes)
            
//        case .binary:
//        case .objectID(_):
            
        case .bool(let value):
            bytes.append(value._byte)
            
        case .utcDate(let value):
            bytes.append(contentsOf: value._bytes)

        case .regex(let value1, let value2):
            bytes.append(contentsOf: value1._bytes)
            bytes.append(contentsOf: value2._bytes)
            
//        case .javaScript:
//        case .scopedJavaScript:
            
        case .int32(let value):
            bytes.append(contentsOf: value._bytes)
            
        case .timestamp(let value):
            bytes.append(contentsOf: value._bytes)
            
        case .int64(let value):
            bytes.append(contentsOf: value._bytes)
            
        case .decimal128(let value):
            bytes.append(contentsOf: _convertToBytes(value))
            
        case .null, .minKey, .maxKey:
            break

        default:
            break
        }
        
        return bytes
    }
}
