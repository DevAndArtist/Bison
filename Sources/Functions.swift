//
//  Functions.swift
//  Bison
//

import Foundation

func _convertToBytes<T>(_ value: T) -> [Byte] {
    
    let capacity = MemoryLayout<T>.size
    var mutableValue = value
    return withUnsafePointer(to: &mutableValue) {
        
        return $0.withMemoryRebound(to: Byte.self, capacity: capacity) {
            
            return Array(UnsafeBufferPointer(start: $0, count: capacity))
        }
    }
}
