//
//  Document+Keys.swift
//  Bison
//

import Foundation

extension Document {
    
//    Switch to SE-0142 after it's implemented
//    public protocol Keys : Collection where Iterator.Element == String, Index == Int {}
    
    public struct Keys : Collection {
        
        let keys: [String]
        
        init(_ keys: [String]) {
            
            self.keys = keys
        }
        
        // MARK: < Collection >
        
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
        
        public subscript(position: Int) -> String {
            
            return self.keys[position]
        }
    }
}
