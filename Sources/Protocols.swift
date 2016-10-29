//
//  Protocols.swift
//  Bison
//

import Foundation

// Public
public protocol ElementValueConvertible {
 
    init?(value: Element.Value)
    
    var value: Element.Value { get }
}

// Internal
protocol _ByteConvertible {}

extension _ByteConvertible {
    
    var _bytes: [Byte] {
        
        return _convertToBytes(self, capacity: MemoryLayout<Self>.size)
    }
}
