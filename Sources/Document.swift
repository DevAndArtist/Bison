//
//  Document.swift
//  Bison
//

import Foundation

public struct Document {
    
    var storage: Storage
    
    public init() {
        
        self.storage = Storage()
    }
    
    public var keys: Keys {
        
        return Keys(self.storage.keys)
    }
    
    public var values: Values {
        
        return Values(self.storage.values)
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
        
        return self.storage.startIndex
    }
    
    public var endIndex: Int {
        
        return self.storage.endIndex
    }
    
    public func index(after i: Int) -> Int {
        
        return self.storage.index(after: i)
    }
    
    public subscript(position: Int) -> (key: String, value: Value) {
        
        return self.storage[position]
    }
}

extension Document {
    
    public subscript(valueAt position: Int) -> Value {
        
        get { return self.storage.value(at: position) }
        
        set { self.storage.setValue(newValue, at: position) }
    }

    public subscript(key: String) -> Value? {

        get { return self.storage[key] }
        
        set { self.storage[key] = newValue }
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
                    guard case .integer(let position) = parameter else { return nil }
                    currentValue = array[position]
                    
                default:
                    return nil
                }
            }
            return currentValue
        }
        
        set {
            
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
    
    public subscript(double key: String) -> Double? {
        
        get {
            
            return self.storage.value(forKey: key) {
                
                if case .double(let value) = $0 { return value } else { return nil }
            }
        }
        
        set {
            
            self.storage.setValue(newValue?.value, forKey: key) {
                
                if case .double = $0 { return true } else { return false }
            }
        }
    }
    
    public subscript(string key: String) -> String? {
        
        get {
            
            return self.storage.value(forKey: key) {
                
                if case .string(let value) = $0 { return value } else { return nil }
            }
        }
        
        set {
            
            self.storage.setValue(newValue?.value, forKey: key) {
                
                if case .string = $0 { return true } else { return false }
            }
        }
    }
    
    public subscript(document key: String) -> Document? {
        
        get {
            
            return self.storage.value(forKey: key) {
                
                if case .document(let value) = $0 { return value } else { return nil }
            }
        }
        
        set {
            
            self.storage.setValue(newValue?.value, forKey: key) {
                
                if case .document = $0 { return true } else { return false }
            }
        }
    }
    
    public subscript(array key: String) -> [Value]? {
        
        get {
            
            return self.storage.value(forKey: key) {
                
                if case .array(let value) = $0 { return value } else { return nil }
            }
        }
        
        set {
            
            let value: Value?
            
            if let newValue = newValue {
             
                value = .array(newValue)
                
            } else { value = nil }
            
            self.storage.setValue(value, forKey: key) {
                
                if case .array = $0 { return true } else { return false }
            }
        }
    }
    
    public subscript(binary key: String) -> (subtype: BinarySubtype, data: [Byte])? {
        
        get {
            
            return self.storage.value(forKey: key) {
                
                if case .binary(let value) = $0 { return value } else { return nil }
            }
        }
        
        set {
            
            let value: Value?
            
            if let newValue = newValue {
                
                value = .binary(newValue.subtype, data: newValue.data)
                
            } else { value = nil }
            
            self.storage.setValue(value, forKey: key) {
                
                if case .binary = $0 { return true } else { return false }
            }
        }
    }
    
    public subscript(objectID key: String) -> ObjectID? {
        
        get {
            
            return self.storage.value(forKey: key) {
                
                if case .objectID(let value) = $0 { return value } else { return nil }
            }
        }
        
        set {
            
            self.storage.setValue(newValue?.value, forKey: key) {
                
                if case .objectID = $0 { return true } else { return false }
            }
        }
    }
    
    public subscript(bool key: String) -> Bool? {
        
        get {
            
            return self.storage.value(forKey: key) {
                
                if case .bool(let value) = $0 { return value } else { return nil }
            }
        }
        
        set {
            
            self.storage.setValue(newValue?.value, forKey: key) {
                
                if case .bool = $0 { return true } else { return false }
            }
        }
    }
    
    public subscript(date key: String) -> Date? {
        
        get {
            
            return self.storage.value(forKey: key) {
                
                if case .date(let value) = $0 { return value } else { return nil }
            }
        }
        
        set {
            
            self.storage.setValue(newValue?.value, forKey: key) {
                
                if case .date = $0 { return true } else { return false }
            }
        }
    }
    
    public subscript(regex key: String) -> (pattern: String, options: String)? {
        
        get {
            
            return self.storage.value(forKey: key) {
                
                if case .regex(let value) = $0 { return value } else { return nil }
            }
        }
        
        set {
            
            let value: Value?
            
            if let newValue = newValue {
                
                value = .regex(pattern: newValue.pattern, options: newValue.options)
                
            } else { value = nil }
            
            self.storage.setValue(value, forKey: key) {
                
                if case .regex = $0 { return true } else { return false }
            }
        }
    }
    
    public subscript(javaScript key: String) -> String? {
        
        get {
            
            return self.storage.value(forKey: key) {
                
                if case .javaScript(let value) = $0 { return value } else { return nil }
            }
        }
        
        set {
            
            let value: Value?
            
            if let newValue = newValue {
                
                value = .javaScript(newValue)
                
            } else { value = nil }
            
            self.storage.setValue(value, forKey: key) {
                
                if case .javaScript = $0 { return true } else { return false }
            }
        }
    }
    
    public subscript(scopedJavaScript key: String) -> (javaScript: String, scope: Document)? {
        
        get {
            
            return self.storage.value(forKey: key) {
                
                if case .scopedJavaScript(let value) = $0 { return value } else { return nil }
            }
        }
        
        set {
            
            let value: Value?
            
            if let newValue = newValue {
                
                value = .scopedJavaScript(newValue.javaScript, scope: newValue.scope)
                
            } else { value = nil }
            
            self.storage.setValue(value, forKey: key) {
                
                if case .scopedJavaScript = $0 { return true } else { return false }
            }
        }
    }
    
    public subscript(int32 key: String) -> Int32? {
        
        get {
            
            return self.storage.value(forKey: key) {
                
                if case .int32(let value) = $0 { return value } else { return nil }
            }
        }
        
        set {
            
            self.storage.setValue(newValue?.value, forKey: key) {
                
                if case .int32 = $0 { return true } else { return false }
            }
        }
    }
    
    public subscript(timestamp key: String) -> Timestamp? {
        
        get {
            
            return self.storage.value(forKey: key) {
                
                if case .timestamp(let value) = $0 { return value } else { return nil }
            }
        }
        
        set {
        
            let value: Value?
            
            if let newValue = newValue {
                
                value = .timestamp(newValue)
                
            } else { value = nil }
            
            self.storage.setValue(value, forKey: key) {
                
                if case .timestamp = $0 { return true } else { return false }
            }
        }
    }
    
    public subscript(int64 key: String) -> Int64? {
        
        get {
            
            return self.storage.value(forKey: key) {
                
                if case .int64(let value) = $0 { return value } else { return nil }
            }
        }
        
        set {
            
            self.storage.setValue(newValue?.value, forKey: key) {
                
                if case .int64 = $0 { return true } else { return false }
            }
        }
    }
    
    public subscript(decimal128 key: String) -> Decimal128? {
        
        get {
            
            return self.storage.value(forKey: key) {
                
                if case .decimal128(let value) = $0 { return value } else { return nil }
            }
        }
        
        set {
            
            let value: Value?
            
            if let newValue = newValue {
                
                value = .decimal128(newValue)
                
            } else { value = nil }
            
            self.storage.setValue(value, forKey: key) {
                
                if case .decimal128 = $0 { return true } else { return false }
            }
        }
    }
}

extension Document : Equatable {
    
    public static func ==(lhs: Document, rhs: Document) -> Bool {
        
        return lhs.storage == rhs.storage
    }
}

extension Document : ExpressibleByDictionaryLiteral {
    
    init(elements: [(String, Value)]) {
        
        self.init()
        
        elements.forEach {
            
            if self.storage.keys.contains($0.0) {
                
                fatalError("Dictionary literal contains duplicate keys")
            }
            self.storage.append(key: $0.0, value: $0.1)
        }
    }
    
    public init(dictionaryLiteral elements: (String, Value)...) {
        
        self.init(elements: elements)
    }
}

extension Document : _ByteConvertible {
    
    var _bytes: [Byte] {
        
        var bytes = [Byte]()
        
        bytes.append(contentsOf: self.storage._bytes)
        bytes.append(0x00)
        bytes.insert(contentsOf: Int32(bytes.count)._bytes, at: 0)
        return bytes
    }
}
