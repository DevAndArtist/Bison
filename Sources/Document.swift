//
//  Document.swift
//  Bison
//

import Foundation

public struct Document {
    
    public var elements: [Element]
    
    public init() {
        
        self.elements = []
    }
    
    public init(elements: [Element]) {
        
        self.elements = elements
    }
    
    public var data: Data {
        
        return Data(bytes: self._bytes)
    }
}

extension Document : _ByteConvertible {
    
    var _bytes: [Byte] {
        
        var bytes = [Byte]()
        
        self.elements.forEach {
            
            bytes.append(contentsOf: $0._bytes)
        }
        
        bytes.insert(contentsOf: Int32(bytes.count)._bytes, at: 0)
        bytes.append(0x00)
        return bytes
    }
}
