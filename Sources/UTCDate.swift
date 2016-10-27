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

extension UTCDate : DataConvertible {
    
    public var data: Data {
        
        return Data(toByteArray(self.timestamp))
    }
}
