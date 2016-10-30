//
//  Protocols.swift
//  Bison
//

import Foundation

// Public

/// Do not use this protocol from your own module!!!
/// This protocol is meant to be `public`, but in a way where
/// `open protocol` exists and means that you should be able
/// to conform to the `open protocol`, but not to a `public protocol`
/// from your own module.
public protocol ElementValueType {
    
    var value: Element.Value { get }
}

public protocol ElementValueConvertible : ElementValueType {
 
    init?(value: Element.Value)
}

// Internal
protocol _ByteConvertible {}

extension _ByteConvertible {
    
    var _bytes: [Byte] {
        
        return _convertToBytes(self, capacity: MemoryLayout<Self>.size)
    }
}
