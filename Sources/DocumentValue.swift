//
//  DocumentValue.swift
//  Bison
//

import Foundation

extension Document {

    public enum Value {
        
        case double(Double)
        case string(String)
        case document(Document)
        case array([Value])
        case binary(BinarySubtype, data: [Byte])
        case objectID(ObjectID)
        case bool(Bool)
        case date(Date)
        case null
        case regex(pattern: String, options: String)
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

extension Document.Value {
    
    var _kind: Byte {
        
        switch self {
            
        case .double:           return 0x01
        case .string:           return 0x02
        case .document:         return 0x03
        case .array:            return 0x04
        case .binary:           return 0x05
        case .objectID:         return 0x07
        case .bool:             return 0x08
        case .date:             return 0x09
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

extension Document.Value : _ByteConvertible {
    
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
            
        case .objectID(let value):
            bytes.append(contentsOf: value._bytes)
            
        case .bool(let value):
            bytes.append(value._byte)
            
        case .date(let value):
            bytes.append(contentsOf: value._bytes)
            
        case .regex(pattern: let pattern, options: let options):
            bytes.append(contentsOf: pattern._cStringBytes)
            bytes.append(contentsOf: options._cStringBytes)
            
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
            bytes.append(contentsOf: _convertToBytes(value, capacity: MemoryLayout.size(ofValue: value)))
            
        default:
            break
        }
        
        return bytes
    }
}

extension Document.Value : ExpressibleByFloatLiteral {
    
    public init(floatLiteral value: Double) {
        
        self = .double(value)
    }
}

extension Document.Value : ExpressibleByStringLiteral {
    
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

extension Document.Value : ExpressibleByBooleanLiteral {
    
    public init(booleanLiteral value: Bool) {
        
        self = .bool(value)
    }
}

extension Document.Value : ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: Int64) {
        
        self = .int64(value)
    }
}

extension Document.Value : ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (String, Document.Value)...) {
        
        self = .document(Document(elements: elements))
    }
}

extension Document.Value : ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: Document.Value...) {
        
        self = .array(elements)
    }
}

extension Document.Value : Equatable {
    
    public static func ==(lhs: Document.Value, rhs: Document.Value) -> Bool {
        
        switch (lhs, rhs) {
            
        case (.double(let value1), .double(let value2)):
            return value1 == value2
            
        case (.string(let value1), .string(let value2)):
            return value1 == value2
            
        case (.document(let value1), .document(let value2)):
            return value1 == value2
            
        case (.array(let value1), .array(let value2)):
            return value1 == value2
            
        case (.binary(let subtype1, data: let data1),
              .binary(let subtype2, data: let data2)):
            return subtype1 == subtype2 && data1 == data2
            
        case (.objectID(let value1), .objectID(let value2)):
            return value1 == value2
            
        case (.bool(let value1), .bool(let value2)):
            return value1 == value2
            
        case (.date(let value1), .date(let value2)):
            return value1 == value2
            
        case (.null, .null):
            return true
            
        case (.regex(pattern: let pattern1, options: let options1),
              .regex(pattern: let pattern2, options: let options2)):
            return pattern1 == pattern2 && options1 == options2
            
        case (.javaScript(let value1), .javaScript(let value2)):
            return value1 == value2
            
        case (.scopedJavaScript(let script1, scope: let document1),
              .scopedJavaScript(let script2, scope: let document2)):
            return script1 == script2 && document1 == document2
            
        case (.int32(let value1), .int32(let value2)):
            return value1 == value2
            
        case (.timestamp(let value1), .timestamp(let value2)):
            return value1 == value2
            
        case (.int64(let value1), .int64(let value2)):
            return value1 == value2
            
        case (.decimal128(let value1), .decimal128(let value2)):
            return value1 == value2
            
        case (.minKey, .minKey):
            return true
            
        case (.maxKey, .maxKey):
            return true
            
        default:
            return false
        }
    }
}
