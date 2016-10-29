//
//  Foundation.swift
//  Bison
//

import Foundation

// Public
extension String : ElementValueConvertible {
    
    public init?(value: Element.Value) {
        
        guard case .string(let string) = value else { return nil }
        
        self = string
    }
    
    public var value: Element.Value {
    
        return Element.Value.string(self)
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

// Internal
extension SignedInteger {
    
    var _bytes: [Byte] {
        
        return _convertToBytes(self, capacity: MemoryLayout<Self>.size)
    }
}

extension Double : _ByteConvertible {}

extension Bool {
    
    var _byte: Byte {
        
        return self ? 0x01 : 0x00
    }
}

extension String : _ByteConvertible {
    
    var _bytes: [Byte] {
        
        var bytes = [Byte]()
        let utf8CString = self.utf8CString.map { Byte($0) }
        bytes.append(contentsOf: Int32(utf8CString.count).littleEndian._bytes)
        bytes.append(contentsOf: utf8CString)
        return bytes
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
        bytes.insert(contentsOf: Int32(bytes.count).littleEndian._bytes, at: 0)
        return bytes
    }
}
