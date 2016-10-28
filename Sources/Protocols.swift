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
        
        let capacity = MemoryLayout<Self>.size
        var mutableValue = self
        return withUnsafePointer(to: &mutableValue) {
            
            return $0.withMemoryRebound(to: Byte.self, capacity: capacity) {
                
                return Array(UnsafeBufferPointer(start: $0, count: capacity))
            }
        }
    }
}
