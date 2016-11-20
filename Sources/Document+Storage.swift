//
//  Document+Storage.swift
//  Bison
//

import Foundation

extension Document {

    struct Storage {
        
        fileprivate(set) var keys: [String] = []
        fileprivate(set) var values: [Value] = []
    }
}

extension Document.Storage : MutableCollection {
    
    var startIndex: Int {
        
        return self.keys.startIndex
    }
    
    var endIndex: Int {
        
        return self.keys.endIndex
    }
    
    public func index(after i: Int) -> Int {
        
        precondition(i < self.endIndex, "Can't advance beyond endIndex")
        return i + 1
    }
    
    subscript(position: Int) -> (key: String, value: Document.Value) {
        
        get { return (self.keys[position], self.values[position]) }
        
        set {
            
            precondition(self.keys[position] == newValue.key)
            self.values[position] = newValue.value
        }
    }
}

extension Document.Storage {
    
    subscript(key: String) -> Document.Value? {
        
        get {
            
            if let position = self.keys.index(of: key) {
                
                return self.values[position]
            }
            return nil
        }
        
        set {
            
            if let position = self.keys.index(of: key) {
                
                if let value = newValue {
                    
                    self.values[position] = value
                    
                } else { self.remove(at: position) }
                
            } else if let value = newValue {
                
                self.append(key: key, value: value)
            }
        }
    }
    
    func value(at position: Int) -> Document.Value {
        
        return self.values[position]
    }
    
    func value<T>(forKey key: String, evaluationBlock: (Document.Value) -> T?) -> T? {
        
        if let position = self.keys.index(of: key) {
            
            return evaluationBlock(self.values[position])
        }
        return nil
    }
    
    mutating func setValue(_ newValue: Document.Value, at position: Int) {
        
        self.values[position] = newValue
    }
    
    mutating func setValue(_ newValue: Document.Value?, forKey key: String, evaluationBlock: (Document.Value) -> Bool)  {
        
        if let position = self.keys.index(of: key), evaluationBlock(self.values[position]) {
            
            if let value = newValue {
                
                self.values[position] = value
                
            } else { self.remove(at: position) }
            
        } else if !self.keys.contains(key), let value = newValue {
            
            self.append(key: key, value: value)
        }
    }
    
    mutating func append(key: String, value: Document.Value) {
        
        precondition(self.keys.count == self.values.count)
        precondition(!self.keys.contains(key), "Can't append a new key-value pair, because the key already exists")
        self.keys.append(key)
        self.values.append(value)
    }
    
    mutating func remove(at position: Int) {
        
        precondition(self.keys.count == self.values.count)
        self.keys.remove(at: position)
        self.values.remove(at: position)
    }
    
    mutating func remove(_ key: String) {
        
        precondition(self.keys.count == self.values.count)
        if let position = self.keys.index(of: key) {
            
            self.remove(at: position)
        }
    }
}

extension Document.Storage /* : Keys */ {
    
    subscript(position: Int) -> String {
        
        return self.keys[position]
    }
}

extension Document.Storage /* : Values */ {
    
    subscript(position: Int) -> Document.Value {
        
        return self.values[position]
    }
}

extension Document.Storage : Equatable {
    
    static func ==(lhs: Document.Storage, rhs: Document.Storage) -> Bool {
        
        return lhs.keys == rhs.keys && lhs.values == rhs.values
    }
}

extension Document.Storage : _ByteConvertible {
    
    var _bytes: [Byte] {
        
        var bytes = [Byte]()
        
        precondition(self.keys.count == self.values.count)
        for position in 0 ..< keys.endIndex {
            
            bytes.append(self.values[position]._kind)
            bytes.append(contentsOf: self.keys[position]._cStringBytes)
            
            switch self.values[position] {
                
            case .null, .minKey, .maxKey:
                break
                
            default:
                bytes.append(contentsOf: self.values[position]._bytes)
            }
        }
        return bytes
    }
}
