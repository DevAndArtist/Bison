//
//  Document.swift
//  Bison
//

import Foundation

public struct Document {
    
    var _storageReference: Storage
    
    public init() {
        
        self._storageReference = Storage()
    }
    
    public var keys: Keys {
        
        return Keys(self)
    }
    
    public var values: Values {
        
        get { return Values(self) }
        
        set { /* implementation artifact */ }
    }
    
    public var data: Data {
        
        return Data(bytes: self._bytes)
    }
}

extension Document : DocumentValueConvertible {
    
    public init?(value: Value) {
        
        guard case .document(let document) = value else { return nil }
        
        self = document
    }
    
    public var value: Value {
        
        return Value.document(self)
    }
}

extension Document : Collection {
    
    public var startIndex: Int {
        
        return self.keys.startIndex
    }
    
    public var endIndex: Int {
        
        return self.keys.endIndex
    }
    
    public func index(after i: Int) -> Int {
        
        precondition(i < self.endIndex, "Can't advance beyond endIndex")
        return i + 1
    }
    
    public subscript(position: Int) -> (key: String, value: Value) {
    
        return (self._storageReference.keys[position], self._storageReference.values[position])
    }
}

extension Document {

    public subscript(key: String) -> Value? {

        get {
            
            if let index = self._storageReference.keys.index(of: key) {

                return self._storageReference.values[index]
            }
            return nil
        }
        
        set {
            
            if !isKnownUniquelyReferenced(&self._storageReference) {
                
                self._storageReference = self._storageReference.cloned()
            }
            
            if let index = self._storageReference.keys.index(of: key) {
                
                if let value = newValue {
                    
                    self._storageReference.values[index] = value
                    
                } else {

                    self._storageReference.keys.remove(at: index)
                    self._storageReference.values.remove(at: index)
                }
                
            } else if let value = newValue {
                
                self._storageReference.keys.append(key)
                self._storageReference.values.append(value)
            }
        }
    }
    
    public enum SubscriptParameter {
        
        case string(String)
        case integer(Int)
    }
    
    subscript(firstKey: String, parameters: [SubscriptParameter]) -> Value? {
        
        get {
    
            var currentValue: Value? = self[firstKey]
            
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
            
            if !isKnownUniquelyReferenced(&self._storageReference) {
                
                self._storageReference = self._storageReference.cloned()
            }
            
//            var value: Value? = self[firstKey]
            
            
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
    
    public subscript(firstKey: String, parameters: SubscriptParameterType...) -> Value? {
        
        get { return self[firstKey, parameters.map { $0.parameter }] }
        
        set { self[firstKey, parameters.map { $0.parameter }] = newValue }
    }
}

extension Document {
    
    private mutating func mutateElement(withKey key: String, newValue: Value?, evaluation: (Value) -> Bool)  {
        
        if !isKnownUniquelyReferenced(&self._storageReference) {
            
            self._storageReference = self._storageReference.cloned()
        }
        
        if let index = self._storageReference.keys.index(of: key), evaluation(self._storageReference.values[index]) {
            
            if let value = newValue {
                
                self._storageReference.values[index] = value
                
            } else {
                
                self._storageReference.keys.remove(at: index)
                self._storageReference.values.remove(at: index)
            }
            
        } else if !self._storageReference.keys.contains(key), let value = newValue {
            
            self._storageReference.keys.append(key)
            self._storageReference.values.append(value)
        }
    }
    
    private func findValue<T>(forKey key: String, evaluation: (Value) -> T? ) -> T? {
        
        if let index = self._storageReference.keys.index(of: key) {
            
            return evaluation(self._storageReference.values[index])
        }
        return nil
    }

    public subscript(double key: String) -> Double? {
        
        get {
            
            return self.findValue(forKey: key) {
                
                if case .double(let value) = $0 { return value } else { return nil }
            }
        }
        
        set {
            
            self.mutateElement(withKey: key, newValue: newValue?.value) {
                
                if case .double = $0 { return true } else { return false }
            }
        }
    }
    
    public subscript(string key: String) -> String? {
        
        get {
            
            return self.findValue(forKey: key) {
                
                if case .string(let value) = $0 { return value } else { return nil }
            }
        }
        
        set {
            
            self.mutateElement(withKey: key, newValue: newValue?.value) {
                
                if case .string = $0 { return true } else { return false }
            }
        }
    }
    
    public subscript(document key: String) -> Document? {
        
        get {
            
            return self.findValue(forKey: key) {
                
                if case .document(let value) = $0 { return value } else { return nil }
            }
        }
        
        set {
            
            self.mutateElement(withKey: key, newValue: newValue?.value) {
                
                if case .document = $0 { return true } else { return false }
            }
        }
    }
    
    public subscript(array key: String) -> [Value]? {
        
        get {
            
            return self.findValue(forKey: key) {
                
                if case .array(let value) = $0 { return value } else { return nil }
            }
        }
        
        set {
            
            let value: Value?
            
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
            
            return self.findValue(forKey: key) {
                
                if case .binary(let value) = $0 { return value } else { return nil }
            }
        }
        
        set {
            
            let value: Value?
            
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
            
            return self.findValue(forKey: key) {
                
                if case .objectID(let value) = $0 { return value } else { return nil }
            }
        }
        
        set {
            
            self.mutateElement(withKey: key, newValue: newValue?.value) {
                
                if case .objectID = $0 { return true } else { return false }
            }
        }
    }
    
    public subscript(bool key: String) -> Bool? {
        
        get {
            
            return self.findValue(forKey: key) {
                
                if case .bool(let value) = $0 { return value } else { return nil }
            }
        }
        
        set {
            
            self.mutateElement(withKey: key, newValue: newValue?.value) {
                
                if case .bool = $0 { return true } else { return false }
            }
        }
    }
    
    public subscript(date key: String) -> Date? {
        
        get {
            
            return self.findValue(forKey: key) {
                
                if case .date(let value) = $0 { return value } else { return nil }
            }
        }
        
        set {
            
            self.mutateElement(withKey: key, newValue: newValue?.value) {
                
                if case .date = $0 { return true } else { return false }
            }
        }
    }
    
    public subscript(regex key: String) -> (pattern: String, options: String)? {
        
        get {
            
            return self.findValue(forKey: key) {
                
                if case .regex(let value) = $0 { return value } else { return nil }
            }
        }
        
        set {
            
            let value: Value?
            
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
            
            return self.findValue(forKey: key) {
                
                if case .javaScript(let value) = $0 { return value } else { return nil }
            }
        }
        
        set {
            
            let value: Value?
            
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
            
            return self.findValue(forKey: key) {
                
                if case .scopedJavaScript(let value) = $0 { return value } else { return nil }
            }
        }
        
        set {
            
            let value: Value?
            
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
            
            return self.findValue(forKey: key) {
                
                if case .int32(let value) = $0 { return value } else { return nil }
            }
        }
        
        set {
            
            self.mutateElement(withKey: key, newValue: newValue?.value) {
                
                if case .int32 = $0 { return true } else { return false }
            }
        }
    }
    
    public subscript(timestamp key: String) -> Timestamp? {
        
        get {
            
            return self.findValue(forKey: key) {
                
                if case .timestamp(let value) = $0 { return value } else { return nil }
            }
        }
        
        set {
        
            let value: Value?
            
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
            
            return self.findValue(forKey: key) {
                
                if case .int64(let value) = $0 { return value } else { return nil }
            }
        }
        
        set {
            
            self.mutateElement(withKey: key, newValue: newValue?.value) {
                
                if case .int64 = $0 { return true } else { return false }
            }
        }
    }
    
    public subscript(decimal128 key: String) -> Decimal128? {
        
        get {
            
            return self.findValue(forKey: key) {
                
                if case .decimal128(let value) = $0 { return value } else { return nil }
            }
        }
        
        set {
            
            let value: Value?
            
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
        
        return lhs._storageReference.keys == rhs._storageReference.keys
            && lhs._storageReference.values == rhs._storageReference.values
    }
}

extension Document : ExpressibleByDictionaryLiteral {
    
    init(elements: [(String, Value)]) {
        
        self.init()
        
        elements.forEach {
            
            if self._storageReference.keys.contains($0.0) {
                
                fatalError("Dictionary literal contains duplicate keys")
            }
            self._storageReference.keys.append($0.0)
            self._storageReference.values.append($0.1)
        }
    }
    
    public init(dictionaryLiteral elements: (String, Value)...) {
        
        self.init(elements: elements)
    }
}

extension Document : _ByteConvertible {
    
    var _bytes: [Byte] {
        
        var bytes = [Byte]()
        bytes.append(contentsOf: self._storageReference._bytes)
        bytes.append(0x00)
        bytes.insert(contentsOf: Int32(bytes.count)._bytes, at: 0)
        return bytes
    }
}
