//
//  Document+Values.swift
//  Bison
//

import Foundation

extension Document {
    
//    Switch to SE-0142 after it's implemented
//    public protocol Values : Collection where Iterator.Element == Value, Index == Int {}
    
    public struct Values : Collection {
        
        let values: [Value]
        
        init(_ values: [Value]) {
            
            self.values = values
        }
        
        // MARK: < Collection >
        
        public var startIndex: Int {
            
            return self.values.startIndex
        }
        
        public var endIndex: Int {
            
            return self.values.endIndex
        }
        
        public func index(after i: Int) -> Int {
            
            precondition(i < self.endIndex, "Can't advance beyond endIndex")
            return i + 1
        }
        
        public subscript(position: Int) -> Value {
            
            return self.values[position]
        }
    }
}
