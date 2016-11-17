//
//  DocumentStorage.swift
//  Bison
//

import Foundation

extension Document {

    final class Storage : _ByteConvertible {
        
        var keys: [String]
        var values: [Value]
        
        init(keys: [String] = [], values: [Value] = []) {
            
            self.keys = keys
            self.values = values
        }
        
        var _bytes: [Byte] {
            
            precondition(self.keys.count == self.values.count)
            
            var bytes = [Byte]()
            
            for index in 0 ..< keys.endIndex {
                
                bytes.append(self.values[index]._kind)
                bytes.append(contentsOf: self.keys[index]._cStringBytes)
                
                switch self.values[index] {
                    
                case .null, .minKey, .maxKey:
                    break
                    
                default:
                    bytes.append(contentsOf: self.values[index]._bytes)
                }
            }
            return bytes
        }
        
        func cloned() -> Storage {
            
            return Storage(keys: self.keys, values: self.values)
        }
    }
}
