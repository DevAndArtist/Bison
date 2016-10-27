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
    
    public init(name: Swift.String, value: Value) {
        
        self.name = CString(string: name)
        self.value = value
    }
}

extension Element : DataConvertible {
    
    public var data: Data {
        
        var data = Data()
        data.append(self.value.kind)
        data.append(self.name.data)
        data.append(self.value.data)
        return data
    }
}

extension Element {
    
    public enum Value {
        
        case double(Double)
        case string(String)
        case document(Document)
        case array(Document)
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
    
    public var kind: UInt8 {
        
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

extension Element.Value : DataConvertible {
    
    public var data: Data {
        
        var data = Data()
        
        switch self {
            
        case .double(let instance):
            data.append(contentsOf: toByteArray(instance))

//        case .string(_):
            
        case .document(let instance):
            data.append(instance.data)
            
        case .array(let instance):
            data.append(instance.data)
            
//        case .binary:
//        case .objectID(_):
//        case .bool(_):
            
        case .utcDate(let instance):
            data.append(instance.data)

        case .regex(let instance_1, let instance_2):
            data.append(instance_1.data)
            data.append(instance_2.data)
            
//        case .javaScript:
//        case .scopedJavaScript:
            
        case .int32(let instance):
            data.append(contentsOf: toByteArray(instance))
            
        case .timestamp(let instance):
            data.append(contentsOf: toByteArray(instance))
            
        case .int64(let instance):
            data.append(contentsOf: toByteArray(instance))
            
        case .decimal128(let instance):
            data.append(contentsOf: toByteArray(instance))
            
        case .null, .minKey, .maxKey:
            break

        default:
            break
        }
        
        return data
    }
}
