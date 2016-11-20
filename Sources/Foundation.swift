//
//  Foundation.swift
//  Bison
//

import Foundation

// Public
extension String : DocumentValueConvertible, SubscriptParameterType {
    
    public init?(value: Document.Value) {
        
        guard case .string(let string) = value else { return nil }
        self = string
    }
    
    public var value: Document.Value {
    
        return .string(self)
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

extension Int32 : DocumentValueConvertible {
    
    public init?(value: Document.Value) {
        
        guard case .int32(let int32) = value else { return nil }
        self = int32
    }
    
    public var value: Document.Value {
        
        return .int32(self)
    }
}

extension Int64 : DocumentValueConvertible {
    
    public init?(value: Document.Value) {
        
        guard case .int64(let int64) = value else { return nil }
        self = int64
    }
    
    public var value: Document.Value {
        
        return .int64(self)
    }
}

extension Bool : DocumentValueConvertible {
    
    public init?(value: Document.Value) {
        
        guard case .bool(let bool) = value else { return nil }
        self = bool
    }
    
    public var value: Document.Value {
        
        return .bool(self)
    }
}

extension Double : DocumentValueConvertible {
    
    public init?(value: Document.Value) {
        
        guard case .double(let double) = value else { return nil }
        self = double
    }
    
    public var value: Document.Value {
        
        return .double(self)
    }
}

extension Date : DocumentValueConvertible {
    
    public init?(value: Document.Value) {
        
        guard case .date(let date) = value else { return nil }
        self = date
    }
    
    public var value: Document.Value {
        
        return .date(self)
    }
}

extension Array where Element == Document.Value {
        
    public func double(at position: Int) -> Double? {
        
        guard self.startIndex <= position && position < self.endIndex else { return nil }
        
        if case .double(let value) = self[position] { return value }
        return nil
    }
    
    public func string(at position: Int) -> String? {
        
        guard self.startIndex <= position && position < self.endIndex else { return nil }
        
        if case .string(let value) = self[position] { return value }
        return nil
    }
    
    public func document(at position: Int) -> Document? {
        
        guard self.startIndex <= position && position < self.endIndex else { return nil }
        
        if case .document(let value) = self[position] { return value }
        return nil
    }
    
    public func array(at position: Int) -> [Document.Value]? {
        
        guard self.startIndex <= position && position < self.endIndex else { return nil }
        
        if case .array(let value) = self[position] { return value }
        return nil
    }
    
    public func binary(at position: Int) -> (subtype: BinarySubtype, data: [Byte])? {
        
        guard self.startIndex <= position && position < self.endIndex else { return nil }
        
        if case .binary(let value) = self[position] { return value }
        return nil
    }
    
    public func objectID(at position: Int) -> ObjectID? {
        
        guard self.startIndex <= position && position < self.endIndex else { return nil }
        
        if case .objectID(let value) = self[position] { return value }
        return nil
    }
    
    public func bool(at position: Int) -> Bool? {
        
        guard self.startIndex <= position && position < self.endIndex else { return nil }
        
        if case .bool(let value) = self[position] { return value }
        return nil
    }
    
    public func date(at position: Int) -> Date? {
        
        guard self.startIndex <= position && position < self.endIndex else { return nil }
        
        if case .date(let value) = self[position] { return value }
        return nil
    }
    
    public func regex(at position: Int) -> (pattern: String, options: String)? {
        
        guard self.startIndex <= position && position < self.endIndex else { return nil }
        
        if case .regex(let value) = self[position] { return value }
        return nil
    }
    
    public func javaScript(at position: Int) -> String? {
        
        guard self.startIndex <= position && position < self.endIndex else { return nil }
        
        if case .javaScript(let value) = self[position] { return value }
        return nil
    }
    
    public func scopedJavaScript(at position: Int) -> (javaScript: String, scope: Document)? {
        
        guard self.startIndex <= position && position < self.endIndex else { return nil }
        
        if case .scopedJavaScript(let value) = self[position] { return value }
        return nil
    }
    
    public func int32(at position: Int) -> Int32? {
        
        guard self.startIndex <= position && position < self.endIndex else { return nil }
        
        if case .int32(let value) = self[position] { return value }
        return nil
    }
    
    public func timestamp(at position: Int) -> Timestamp? {
        
        guard self.startIndex <= position && position < self.endIndex else { return nil }
        
        if case .timestamp(let value) = self[position] { return value }
        return nil
    }
    
    public func int64(at position: Int) -> Int64? {
        
        guard self.startIndex <= position && position < self.endIndex else { return nil }
        
        if case .int64(let value) = self[position] { return value }
        return nil
    }
    
    public func decimal128(at position: Int) -> Decimal128? {
        
        guard self.startIndex <= position && position < self.endIndex else { return nil }
        
        if case .decimal128(let value) = self[position] { return value }
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

extension Array where Element == Document.Value {
    
    var _bytes: [Byte] {

        var bytes = [Byte]()
        
        for position in 0 ..< self.endIndex {
            
            bytes.append(self[position]._kind)
            bytes.append(contentsOf: "\(position)"._cStringBytes)
            
            switch self[position] {
                
            case .null, .minKey, .maxKey:
                break
                
            default:
                bytes.append(contentsOf: self[position]._bytes)
            }
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
