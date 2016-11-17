//
//  Protocols.swift
//  Bison
//

import Foundation

// Public

public protocol DocumentValueConvertible {
 
    init?(value: Document.Value)

    var value: Document.Value { get }
}

public protocol SubscriptParameterType {
    
    var parameter: Document.SubscriptParameter { get }
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

