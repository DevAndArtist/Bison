//
//  Element.swift
//  Bison
//

import Foundation

public struct Element {
    
    public let key: String
    public let value: Value
    
    public init(key: String, value: Value) {
        
        self.key = key
        self.value = value
    }
}

extension Element : _ByteConvertible {
    
    var _bytes: [Byte] {

        var bytes = [Byte]()
        bytes.append(self.value._kind)
        bytes.append(contentsOf: self.key._cStringBytes)
        
        switch self.value {
            
        case .null, .minKey, .maxKey:
            break
            
        default:
            bytes.append(contentsOf: self.value._bytes)
        }
        return bytes
    }
}
