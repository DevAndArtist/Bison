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


// Internal
extension Integer {
    
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
