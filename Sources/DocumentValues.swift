//
//  DocumentValues.swift
//  Bison
//

import Foundation

extension Document {
    
    public struct Values : MutableCollection {
        
        let _storageReference: Storage
        
        init(_ document: Document) {
            
            self._storageReference = document._storageReference
        }
        
        // MARK: < MutableCollection >
        
        public var startIndex: Int {
            
            return _storageReference.keys.startIndex
        }
        
        public var endIndex: Int {
            
            return _storageReference.keys.endIndex
        }
        
        public func index(after i: Int) -> Int {
            
            return _storageReference.keys.index(after: i)
        }
        
        public subscript(position: Int) -> Value {
            
            get { return _storageReference.values[position] }
            
            set { _storageReference.values[position] = newValue }
        }
    }
}
