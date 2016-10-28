//
//  CString.swift
//  Bison
//

import Foundation

// Public
public struct CString {
    
    public let characters: [CChar]
    
    public var string: String {
        
        var characters = self.characters
        return String(cString: &characters)
    }
    
    public init?<Characters : BidirectionalCollection>(characters: Characters)
        where Characters.Iterator.Element == CChar, Characters.Index == Int {

        guard characters.index(of: 0x00) == (characters.endIndex - 1) else { return nil }
        
        self.characters = characters.map { CChar($0) }
    }
    
    public init(string: String) {
        
        self.characters = string.utf8CString.map { CChar($0) }
    }
}

extension CString : ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        
        self.init(string: value)
    }
    
    public init(unicodeScalarLiteral value: String) {
        
        self.init(string: value)
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        
        self.init(string: value)
    }
}

// Internal
extension CString : _ByteConvertible {
    
    var _bytes: [Byte] {
        
        return self.characters.map { Byte($0) }
    }
}
