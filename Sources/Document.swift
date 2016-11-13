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
                
                fatalError("Array contains elements with duplicate keys")
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
    
    public subscript(position: Int) -> Element.Value {
    
        get { return self.elements[position].value }
        
        set {
            
            let key = self.elements[position].key
            self.elements[position] = Element(key: key, value: newValue)
        }
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
    
    subscript(keys: [String]) -> Element.Value? {
        
        get {
            
            precondition(keys.count > 1)
            
            var currentValue: Element.Value? = self[keys[0]]
            
            for key in keys.dropFirst() {
                
                guard case .some(.document(let document)) = currentValue else { return nil }
                
                currentValue = document[key]
            }
            
            return currentValue
        }
        
        set {
            
            precondition(keys.count > 1)
            
            var document: Document
            
            if let innerDocument = self.document(keys[0]) {
                
                document = innerDocument
                
            } else {
                
                document = Document()
            }
            
            let restKeys = keys.dropFirst().map { $0 }
            
            if restKeys.count == 1 {
                
                document[restKeys[0]] = newValue
                
            } else {
                
                document[restKeys] = newValue
            }
            
            self[keys[0]] = .document(document)
        }
    }
    
    public subscript(keys: String...) -> Element.Value? {
        
        get { return self[keys] }
        
        set { self[keys] = newValue }
    }
}

extension Document {

    public func double(_ key: String) -> Double? {
        
        if let element = self.elements.first(where: { $0.key == key }),
            case .double(let double) = element.value {
            
            return double
        }
        return nil
    }
    
    public func string(_ key: String) -> String? {
        
        if let element = self.elements.first(where: { $0.key == key }),
            case .string(let string) = element.value {
            
            return string
        }
        return nil
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
    
    public func binary(_ key: String) -> (subtype: BinarySubtype, data: [Byte])? {
        
        if let element = self.elements.first(where: { $0.key == key }),
            case .binary(let binary) = element.value {
            
            return binary
        }
        return nil
    }
    
    public func objectID(_ key: String) -> ObjectID? {
        
        if let element = self.elements.first(where: { $0.key == key }),
            case .objectID(let objectID) = element.value {
            
            return objectID
        }
        return nil
    }
    
    public func bool(_ key: String) -> Bool? {
        
        if let element = self.elements.first(where: { $0.key == key }),
            case .bool(let bool) = element.value {
            
            return bool
        }
        return nil
    }
    
    public func date(_ key: String) -> Date? {
        
        if let element = self.elements.first(where: { $0.key == key }),
            case .date(let date) = element.value {
            
            return date
        }
        return nil
    }
    
    public func regex(_ key: String) -> (pattern: String, options: String)? {
        
        if let element = self.elements.first(where: { $0.key == key }),
            case .regex(let regex) = element.value {
            
            return regex
        }
        return nil
    }
    
    public func javaScript(_ key: String) -> String? {
        
        if let element = self.elements.first(where: { $0.key == key }),
            case .javaScript(let string) = element.value {
            
            return string
        }
        return nil
    }
    
    public func scopedJavaScript(_ key: String) -> (javaScript: String, scope: Document)? {
        
        if let element = self.elements.first(where: { $0.key == key }),
            case .scopedJavaScript(let scopedJavaScript) = element.value {
            
            return scopedJavaScript
        }
        return nil
    }
    
    public func int32(_ key: String) -> Int32? {
        
        if let element = self.elements.first(where: { $0.key == key }),
            case .int32(let int32) = element.value {
            
            return int32
        }
        return nil
    }
    
    public func timestamp(_ key: String) -> Timestamp? {
        
        if let element = self.elements.first(where: { $0.key == key }),
            case .timestamp(let timestamp) = element.value {
            
            return timestamp
        }
        return nil
    }
    
    public func int64(_ key: String) -> Int64? {
        
        if let element = self.elements.first(where: { $0.key == key }),
            case .int64(let int64) = element.value {
            
            return int64
        }
        return nil
    }
    
    public func decimal128(_ key: String) -> Decimal128? {
        
        if let element = self.elements.first(where: { $0.key == key }),
            case .decimal128(let decimal128) = element.value {
            
            return decimal128
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
