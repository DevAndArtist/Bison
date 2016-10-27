//
//  CString.swift
//  Bison
//

import Foundation

public struct CString {
    
    public let ut8CString: ContiguousArray<CChar>
    
    public init(string: Swift.String) {
        
        self.ut8CString = string.utf8CString
    }
    
    public init(cString: ContiguousArray<CChar>) {
        
        self.ut8CString = cString
    }
}

extension CString : DataConvertible {
    
    public var data: Data {
        
        return Data(bytes: self.ut8CString.map { UInt8($0) })
    }
}
