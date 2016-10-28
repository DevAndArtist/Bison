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
        
        return _convertToBytes(self)
    }
}

extension Double : _ByteConvertible {
    
    var _bytes: [Byte] {
        
        return _convertToBytes(self)
    }
}

extension Bool {
    
    var _byte: Byte {
        
        return self ? 0x01 : 0x00
    }
}

extension String : _ByteConvertible {
    
    var _bytes: [Byte] {
        
        var bytes = [Byte]()
        let utf8CString = self.utf8CString.map { Byte($0) }
        bytes.append(contentsOf: Int32(utf8CString.count)._bytes)
        bytes.append(contentsOf: utf8CString)
        return bytes
    }
}
