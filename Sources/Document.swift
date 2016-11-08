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
        
        self.init()
        
        elements.forEach {
            
            element in
            
            if self.elements.contains(where: { $0.key == element.key }) {
                
                fatalError("Array contains elemtns with duplicate keys")
            }
            
            self.elements.append(element)
        }
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
    
    public func index(after i: Int) -> Int {
        
        precondition(i < self.endIndex, "Can't advance beyond endIndex")
        return i + 1
    }
    
    public subscript(position: Int) -> Element {
    
        get { return self.elements[position] }
        
        set { self.elements[position] = newValue }
    }
    
    public subscript(key: String) -> Element.Value? {

        get { return self.elements.first(where: { $0.key == key })?.value }
        
        set {
            
            if let index = self.elements.index(where: { $0.key == key }) {
                
                if let value = newValue {
                    
                    self.elements[index] = Element(key: key, value: value)
                    
                } else {

                    self.elements.remove(at: index)
                }
                
            } else if let value = newValue {
                    
                self.elements.append(Element(key: key, value: value))
            }
        }
    }
    
    public func document(_ key: String) -> Document? {
            
        if let element = self.elements.first(where: { $0.key == key }),
            case .document(let document) = element.value {
            
            return document
        }
        
        return nil
    }
    
    public func array(_ key: String) -> [Element.Value]? {
        
        if let element = self.elements.first(where: { $0.key == key }),
            case .array(let array) = element.value {
            
            return array
        }
        
        return nil
    }
}

extension Document : Equatable {
    
    public static func ==(lhs: Document, rhs: Document) -> Bool {
        
        return lhs.elements == rhs.elements
    }
}

extension Document : ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: Element...) {
        
        self.init()
        
        elements.forEach {
            
            element in
            
            if self.elements.contains(where: { $0.key == element.key }) {
                
                fatalError("Array literal contains elements with duplicate keys")
            }
            
            self.elements.append(element)
        }
    }
}

extension Document : ExpressibleByDictionaryLiteral {
    
    init(elements: [(String, Element.Value)]) {
        
        self.init()
        
        elements.forEach {
            
            element in
            
            if self.elements.contains(where: { $0.key == element.0 }) {
                
                fatalError("Dictionary literal contains duplicate keys")
            }
            
            self.elements.append(Element(key: element.0, value: element.1))
        }
    }
    
    public init(dictionaryLiteral elements: (String, Element.Value)...) {
        
        self.init(elements: elements)
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
