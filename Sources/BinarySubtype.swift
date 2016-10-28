//
//  BinarySubtype.swift
//  Bison
//

import Foundation

public enum BinarySubtype : RawRepresentable {
    
    case generic
    case function
    case binaryOld
    case uuidOld
    case uuid
    case md5
    case reserved(UInt8)
    case userDefined(UInt8)
    
    public var rawValue: UInt8  {
        
        switch self {
            
        case .generic:                return 0x00
        case .function:               return 0x01
        case .binaryOld:              return 0x02
        case .uuidOld:                return 0x03
        case .uuid:                   return 0x04
        case .md5:                    return 0x05
        case .reserved(let value):    return value
        case .userDefined(let value): return value
        }
    }
    
    public init(rawValue: UInt8) {
        
        switch rawValue {
            
        case 0x00:        self = .generic
        case 0x01:        self = .function
        case 0x02:        self = .binaryOld
        case 0x03:        self = .uuidOld
        case 0x04:        self = .uuid
        case 0x05:        self = .md5
        case 0x06...0x7F: self = .reserved(rawValue)
        case 0x80...0xFF: self = .userDefined(rawValue)
        default:          fatalError("Impossible UInt8")
        }
    }
}
