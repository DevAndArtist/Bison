//
//  Document.swift
//  Bison
//

import Foundation

public struct Document {
    
    public internal(set) var elements: [Element]
    
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

extension Document : ElementValueConvertible {
    
    public init?(value: Element.Value) {
        
        guard case .document(let document) = value else { return nil }
        
        self = document
    }
    
    public var value: Element.Value {
        
        return Element.Value.document(self)
    }
}

extension Document : MutableCollection {
    
    public var startIndex: Int {
        
        return self.elements.startIndex
    }
    
    public var endIndex: Int {
        
        return self.elements.endIndex
    }
    
    public subscript(position: Int) -> Element {
    
        get { return self.elements[position] }
        
        set { self.elements[position] = newValue }
    }
    
    public func index(after i: Int) -> Int {
        
        precondition(i < self.endIndex, "Can't advance beyond endIndex")
        return i + 1
    }
}

extension Document : _ByteConvertible {
    
    var _bytes: [Byte] {
        
        var bytes = [Byte]()
        
        self.elements.forEach {
            
            bytes.append(contentsOf: $0._bytes)
        }
        bytes.append(0x00)
        bytes.insert(contentsOf: Int32(bytes.count)._bytes, at: 0)
        return bytes
    }
}
