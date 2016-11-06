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

protocol _Integer : Integer, _ByteConvertible {
    
    /// Creates an integer from its big-endian representation, changing the
    /// byte order if necessary.
    init(bigEndian value: Self)
    
    /// Creates an integer from its little-endian representation, changing the
    /// byte order if necessary.
    init(littleEndian value: Self)
    
    /// Returns the big-endian representation of the integer, changing the
    /// byte order if necessary.
    var bigEndian: Self { get }
    
    /// Returns the little-endian representation of the integer, changing the
    /// byte order if necessary.
    var littleEndian: Self { get }
    
    /// Returns the current integer with the byte order swapped.
    var byteSwapped: Self { get }
}

extension _Integer {
    
    var _bytes: [Byte] {
            
        return _convertToBytes(self.littleEndian, capacity: MemoryLayout<Self>.size)
    }
    
    init?(_ bytes: [Byte]) {
        
        guard bytes.count == MemoryLayout<Self>.size else { return nil }
        
        self = bytes.withUnsafeBytes {
            
            return $0.load(as: Self.self)
        }
    }
}

