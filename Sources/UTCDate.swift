//
//  UTCDate.swift
//  Bison
//

import Foundation

public struct UTCDate {
    
    public let timestamp: Int64
    
    public init(date: Date) {
        // Convert to milliseconds
        self.timestamp = Int64(date.timeIntervalSince1970 * 1000)
    }
}

extension UTCDate : ElementValueConvertible {
    
    public init?(value: Element.Value) {
        
        guard case .utcDate(let utcDate) = value else { return nil }
        
        self = utcDate
    }
    
    public var value: Element.Value {
        
        return Element.Value.utcDate(self)
    }
}

extension UTCDate : _ByteConvertible {
    
    var _bytes: [Byte] {
        
        return self.timestamp._bytes
    }
}
