//
//  Foundation.swift
//  Bison
//

import Foundation

// Public
extension String : ElementValueConvertible, SubscriptParameterType {
    
    public init?(value: Element.Value) {
        
        guard case .string(let string) = value else { return nil }
        
        self = string
    }
    
    public var value: Element.Value {
    
        return Element.Value.string(self)
    }
    
    public var parameter: Document.SubscriptParameter {
        
        return .string(self)
    }
}

extension Int : SubscriptParameterType {
    
    public var parameter: Document.SubscriptParameter {
        
        return .integer(self)
    }
}

extension Int32 : ElementValueConvertible {
    
    public init?(value: Element.Value) {
        
        guard case .int32(let int32) = value else { return nil }
        
        self = int32
    }
    
    public var value: Element.Value {
        
        return Element.Value.int32(self)
    }
}

extension Int64 : ElementValueConvertible {
    
    public init?(value: Element.Value) {
        
        guard case .int64(let int64) = value else { return nil }
        
        self = int64
    }
    
    public var value: Element.Value {
        
        return Element.Value.int64(self)
    }
}

extension Bool : ElementValueConvertible {
    
    public init?(value: Element.Value) {
        
        guard case .bool(let bool) = value else { return nil }
        
        self = bool
    }
    
    public var value: Element.Value {
        
        return Element.Value.bool(self)
    }
}

extension Double : ElementValueConvertible {
    
    public init?(value: Element.Value) {
        
        guard case .double(let double) = value else { return nil }
        
        self = double
    }
    
    public var value: Element.Value {
        
        return Element.Value.double(self)
    }
}

extension Date : ElementValueConvertible {
    
    public init?(value: Element.Value) {
        
        guard case .date(let date) = value else { return nil }
        
        self = date
    }
    
    public var value: Element.Value {
        
        return Element.Value.date(self)
    }
}

extension Array where Element == Bison.Element.Value {
        
    public func double(at index: Int) -> Double? {
        
        guard self.startIndex <= index && index < self.endIndex else { return nil }
        
        if case .double(let double) = self[index] {
            
            return double
        }
        return nil
    }
    
    public func string(at index: Int) -> String? {
        
        guard self.startIndex <= index && index < self.endIndex else { return nil }
        
        if case .string(let string) = self[index] {
            
            return string
        }
        return nil
    }
    
    public func document(at index: Int) -> Document? {
        
        guard self.startIndex <= index && index < self.endIndex else { return nil }
        
        if case .document(let document) = self[index] {
            
            return document
        }
        return nil
    }
    
    public func array(at index: Int) -> [Bison.Element.Value]? {
        
        guard self.startIndex <= index && index < self.endIndex else { return nil }
        
        if case .array(let array) = self[index] {
            
            return array
        }
        return nil
    }
    
    public func binary(at index: Int) -> (subtype: BinarySubtype, data: [Byte])? {
        
        guard self.startIndex <= index && index < self.endIndex else { return nil }
        
        if case .binary(let binary) = self[index] {
            
            return binary
        }
        return nil
    }
    
    public func objectID(at index: Int) -> ObjectID? {
        
        guard self.startIndex <= index && index < self.endIndex else { return nil }
        
        if case .objectID(let objectID) = self[index] {
            
            return objectID
        }
        return nil
    }
    
    public func bool(at index: Int) -> Bool? {
        
        guard self.startIndex <= index && index < self.endIndex else { return nil }
        
        if case .bool(let bool) = self[index] {
            
            return bool
        }
        return nil
    }
    
    public func date(at index: Int) -> Date? {
        
        guard self.startIndex <= index && index < self.endIndex else { return nil }
        
        if case .date(let date) = self[index] {
            
            return date
        }
        return nil
    }
    
    public func regex(at index: Int) -> (pattern: String, options: String)? {
        
        guard self.startIndex <= index && index < self.endIndex else { return nil }
        
        if case .regex(let regex) = self[index] {
            
            return regex
        }
        return nil
    }
    
    public func javaScript(at index: Int) -> String? {
        
        guard self.startIndex <= index && index < self.endIndex else { return nil }
        
        if case .javaScript(let string) = self[index] {
            
            return string
        }
        return nil
    }
    
    public func scopedJavaScript(at index: Int) -> (javaScript: String, scope: Document)? {
        
        guard self.startIndex <= index && index < self.endIndex else { return nil }
        
        if case .scopedJavaScript(let scopedJavaScript) = self[index] {
            
            return scopedJavaScript
        }
        return nil
    }
    
    public func int32(at index: Int) -> Int32? {
        
        guard self.startIndex <= index && index < self.endIndex else { return nil }
        
        if case .int32(let int32) = self[index] {
            
            return int32
        }
        return nil
    }
    
    public func timestamp(at index: Int) -> Timestamp? {
        
        guard self.startIndex <= index && index < self.endIndex else { return nil }
        
        if case .timestamp(let timestamp) = self[index] {
            
            return timestamp
        }
        return nil
    }
    
    public func int64(at index: Int) -> Int64? {
        
        guard self.startIndex <= index && index < self.endIndex else { return nil }
        
        if case .int64(let int64) = self[index] {
            
            return int64
        }
        return nil
    }
    
    public func decimal128(at index: Int) -> Decimal128? {
        
        guard self.startIndex <= index && index < self.endIndex else { return nil }
        
        if case .decimal128(let decimal128) = self[index] {
            
            return decimal128
        }
        return nil
    }
}

// Internal
extension Int : _Integer {}
extension Int16 : _Integer {}
extension Int32 : _Integer {}
extension Int64 : _Integer {}

extension UInt : _Integer {}
extension UInt16 : _Integer {}
extension UInt32 : _Integer {}
extension UInt64 : _Integer {}

extension Double : _ByteConvertible {}

extension Bool {
    
    var _byte: Byte {
        
        return self ? 0x01 : 0x00
    }
}

extension String : _ByteConvertible {
    
    var _bytes: [Byte] {
        
        var bytes = self._cStringBytes
        bytes.insert(contentsOf: Int32(bytes.count)._bytes, at: 0)
        return bytes
    }
    
    var _cStringBytes: [Byte] {
        
        return self.utf8CString.map { Byte($0) }
    }
}

extension Array where Element == Bison.Element.Value {
    
    var _bytes: [Byte] {
        
        let elements = (self.startIndex..<self.endIndex)
            .map { Bison.Element(key: "\($0)", value: self[$0]) }
        
        var bytes = [Byte]()
        
        elements.forEach {
            
            bytes.append(contentsOf: $0._bytes)
        }
        bytes.append(0x00)
        bytes.insert(contentsOf: Int32(bytes.count)._bytes, at: 0)
        return bytes
    }
}

extension Date : _ByteConvertible {
    
    var _bytes: [Byte] {
        // Convert to milliseconds
        let timestamp = Int64(self.timeIntervalSince1970 * 1000)
        return timestamp._bytes
    }
    
    static func _fromUTCDate(_ timestamp: Int64) -> Date {
        // Recreate `Date` format
        let a = timestamp / 1000 // Remove last 3 digits
        // Calculate decimal number
        let b = Double(timestamp - (a * 1000)) / 1000.0
        // Combine both
        let c = Double(a) + b
        return Date(timeIntervalSince1970: c)
    }
}
