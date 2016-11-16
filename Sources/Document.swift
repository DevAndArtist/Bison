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
    
    public enum SubscriptParameter {
        
        case string(String)
        case integer(Int)
    }
    
    subscript(firstKey: String, parameters: [SubscriptParameter]) -> Element.Value? {
        
        get {
    
            var currentValue: Element.Value? = self[firstKey]
            
            for parameter in parameters {
                
                guard let value = currentValue else { return nil }
                
                switch value {
                    
                case .document(let document):
                    guard case .string(let key) = parameter else { return nil }
                    currentValue = document[key]
                    
                case .array(let array):
                    guard case .integer(let index) = parameter else { return nil }
                    currentValue = array[index]
                    
                default:
                    return nil
                }
            }
            
            return currentValue
        }
        
        set {
            
            var value: Element.Value? = self[firstKey]
            
            
            
            
//            if let innerDocument = self.document(key) {
//                
//                document = innerDocument
//                
//            } else {
//                
//                document = Document()
//            }
//            
//            let restKeys = keys.dropFirst().map { $0 }
//            
//            if restKeys.count == 1 {
//                
//                guard case .string
//                
//                document[restKeys[0]] = newValue
//                
//            } else {
//                
//                document[restKeys] = newValue
//            }
//            
//            self[keys[0]] = .document(document)
        }
    }
    
    public subscript(firstKey: String, parameters: SubscriptParameterType...) -> Element.Value? {
        
        get { return self[firstKey, parameters.map { $0.parameter }] }
        
        set { self[firstKey, parameters.map { $0.parameter }] = newValue }
    }
}

extension Document {
    
    private mutating func mutateElement(withKey key: String, newValue: Element.Value?, evaluation: (Element.Value) -> Bool)  {
        
        if let index = self.elements.index(where: { $0.key == key }), evaluation(self.elements[index].value) {
            
            if let newValue = newValue {
                
                self.elements[index] = Element(key: key, value: newValue)
                
            } else {
                
                self.elements.remove(at: index)
            }
            
        } else if !self.elements.contains(where: { $0.key == key }), let newValue = newValue {
            
            self.elements.append(Element(key: key, value: newValue))
        }
    }

    public subscript(double key: String) -> Double? {
        
        get {
            
            if let element = self.elements.first(where: { $0.key == key }),
                case .double(let double) = element.value {
                
                return double
            }
            return nil
        }
        
        set {
            
            self.mutateElement(withKey: key, newValue: newValue?.value) {
                
                if case .double = $0 { return true } else { return false }
            }
        }
    }
    
    public subscript(string key: String) -> String? {
        
        get {
            
            if let element = self.elements.first(where: { $0.key == key }),
                case .string(let string) = element.value {
                
                return string
            }
            return nil
        }
        
        set {
            
            self.mutateElement(withKey: key, newValue: newValue?.value) {
                
                if case .string = $0 { return true } else { return false }
            }
        }
    }
    
    public subscript(document key: String) -> Document? {
        
        get {
            
            if let element = self.elements.first(where: { $0.key == key }),
                case .document(let document) = element.value {
                
                return document
            }
            return nil
        }
        
        set {
            
            self.mutateElement(withKey: key, newValue: newValue?.value) {
                
                if case .document = $0 { return true } else { return false }
            }
        }
    }
    
    public subscript(array key: String) -> [Element.Value]? {
        
        get {
            
            if let element = self.elements.first(where: { $0.key == key }),
                case .array(let array) = element.value {
                
                return array
            }
            return nil
        }
        
        set {
            
            let value: Element.Value?
            
            if let newValue = newValue {
             
                value = .array(newValue)
                
            } else { value = nil }
            
            self.mutateElement(withKey: key, newValue: value) {
                
                if case .array = $0 { return true } else { return false }
            }
        }
    }
    
    public subscript(binary key: String) -> (subtype: BinarySubtype, data: [Byte])? {
        
        get {
            
            if let element = self.elements.first(where: { $0.key == key }),
                case .binary(let binary) = element.value {
                
                return binary
            }
            return nil
        }
        
        set {
            
            let value: Element.Value?
            
            if let newValue = newValue {
                
                value = .binary(newValue.subtype, data: newValue.data)
                
            } else { value = nil }
            
            self.mutateElement(withKey: key, newValue: value) {
                
                if case .binary = $0 { return true } else { return false }
            }
        }
    }
    
    public subscript(objectID key: String) -> ObjectID? {
        
        get {
            
            if let element = self.elements.first(where: { $0.key == key }),
                case .objectID(let objectID) = element.value {
                
                return objectID
            }
            return nil
        }
        
        set {
            
            self.mutateElement(withKey: key, newValue: newValue?.value) {
                
                if case .objectID = $0 { return true } else { return false }
            }
        }
    }
    
    public subscript(bool key: String) -> Bool? {
        
        get {
            
            if let element = self.elements.first(where: { $0.key == key }),
                case .bool(let bool) = element.value {
                
                return bool
            }
            return nil
        }
        
        set {
            
            self.mutateElement(withKey: key, newValue: newValue?.value) {
                
                if case .bool = $0 { return true } else { return false }
            }
        }
    }
    
    public subscript(date key: String) -> Date? {
        
        get {
            
            if let element = self.elements.first(where: { $0.key == key }),
                case .date(let date) = element.value {
                
                return date
            }
            return nil
        }
        
        set {
            
            self.mutateElement(withKey: key, newValue: newValue?.value) {
                
                if case .date = $0 { return true } else { return false }
            }
        }
    }
    
    public subscript(regex key: String) -> (pattern: String, options: String)? {
        
        get {
            
            if let element = self.elements.first(where: { $0.key == key }),
                case .regex(let regex) = element.value {
                
                return regex
            }
            return nil
        }
        
        set {
            
            let value: Element.Value?
            
            if let newValue = newValue {
                
                value = .regex(pattern: newValue.pattern, options: newValue.options)
                
            } else { value = nil }
            
            self.mutateElement(withKey: key, newValue: value) {
                
                if case .regex = $0 { return true } else { return false }
            }
        }
    }
    
    public subscript(javaScript key: String) -> String? {
        
        get {
            
            if let element = self.elements.first(where: { $0.key == key }),
                case .javaScript(let string) = element.value {
                
                return string
            }
            return nil
        }
        
        set {
            
            let value: Element.Value?
            
            if let newValue = newValue {
                
                value = .javaScript(newValue)
                
            } else { value = nil }
            
            self.mutateElement(withKey: key, newValue: value) {
                
                if case .javaScript = $0 { return true } else { return false }
            }
        }
    }
    
    public subscript(scopedJavaScript key: String) -> (javaScript: String, scope: Document)? {
        
        get {
            
            if let element = self.elements.first(where: { $0.key == key }),
                case .scopedJavaScript(let scopedJavaScript) = element.value {
                
                return scopedJavaScript
            }
            return nil
        }
        
        set {
            
            let value: Element.Value?
            
            if let newValue = newValue {
                
                value = .scopedJavaScript(newValue.javaScript, scope: newValue.scope)
                
            } else { value = nil }
            
            self.mutateElement(withKey: key, newValue: value) {
                
                if case .scopedJavaScript = $0 { return true } else { return false }
            }
        }
    }
    
    public subscript(int32 key: String) -> Int32? {
        
        get {
            
            if let element = self.elements.first(where: { $0.key == key }),
                case .int32(let int32) = element.value {
                
                return int32
            }
            return nil
        }
        
        set {
            
            self.mutateElement(withKey: key, newValue: newValue?.value) {
                
                if case .int32 = $0 { return true } else { return false }
            }
        }
    }
    
    public subscript(timestamp key: String) -> Timestamp? {
        
        get {
            
            if let element = self.elements.first(where: { $0.key == key }),
                case .timestamp(let timestamp) = element.value {
                
                return timestamp
            }
            return nil
        }
        
        set {
        
            let value: Element.Value?
            
            if let newValue = newValue {
                
                value = .timestamp(newValue)
                
            } else { value = nil }
            
            self.mutateElement(withKey: key, newValue: value) {
                
                if case .timestamp = $0 { return true } else { return false }
            }
        }
    }
    
    public subscript(int64 key: String) -> Int64? {
        
        get {
            
            if let element = self.elements.first(where: { $0.key == key }),
                case .int64(let int64) = element.value {
                
                return int64
            }
            return nil
        }
        
        set {
            
            self.mutateElement(withKey: key, newValue: newValue?.value) {
                
                if case .int64 = $0 { return true } else { return false }
            }
        }
    }
    
    public subscript(decimal128 key: String) -> Decimal128? {
        
        get {
            
            if let element = self.elements.first(where: { $0.key == key }),
                case .decimal128(let decimal128) = element.value {
                
                return decimal128
            }
            return nil
        }
        
        set {
            
            let value: Element.Value?
            
            if let newValue = newValue {
                
                value = .decimal128(newValue)
                
            } else { value = nil }
            
            self.mutateElement(withKey: key, newValue: value) {
                
                if case .decimal128 = $0 { return true } else { return false }
            }
        }
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
