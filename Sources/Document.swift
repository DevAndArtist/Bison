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
}

extension Document : DataConvertible {
    
    public var data: Data {
        
        var data = Data()

        self.elements.forEach { data.append($0.data) }
        
        let countBytes = toByteArray(Int32(data.count))
        data.insert(contentsOf: countBytes, at: 0)
        data.append(0x00)
        return data
    }
}
