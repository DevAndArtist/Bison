//
//  ObjectID.swift
//  Bison
//

import Foundation
import Dispatch

#if os(Linux)
    import Glibc
#endif

public struct ObjectID {
    
    fileprivate typealias Storage = (
        timestamp: UInt32,  // the seconds since the Unix epoch
        machineID: [Byte],  // machine identifier
        processID: UInt16,  // process id
        counter: UInt32     // counter, starting with a random value
    )
    
    fileprivate static let machineID: [Byte] = {
       
        let stringBuffer = UnsafeMutablePointer<CChar>.allocate(capacity: 1024)
        gethostname(stringBuffer, 1024)
        // extract host name
        let hostName = String(cString: stringBuffer)
        // get rid of the buffer
        stringBuffer.deinitialize()
        stringBuffer.deallocate(capacity: 1024)
        
        return _md5(hostName.utf8.map{ $0 })[0...2].map { $0 }
    }()
    
    fileprivate static let processID = UInt16(getpid())
    
    fileprivate static let queue = DispatchQueue(label: "com.devandartist.bison")

    fileprivate static var counter: UInt32 = {
 
        #if os(Linux)
            srandom(UInt32(Date().timeIntervalSince1970))
            return UInt32(abs(random() % 0x01_000000))
        #else
            return arc4random_uniform(0x01_000000)
        #endif
        }() {
        
        didSet {
            // Catch overflow
            if ObjectID.counter > 0x00_FFFFFF {
                
                ObjectID.counter = 1
            }
        }
    }
    
    fileprivate let storage: Storage
    
    public init() {
        
        var counter = UInt32(0)
        ObjectID.queue.sync {
            
            ObjectID.counter += 1
            counter = ObjectID.counter
        }
        
        self.storage = (
            UInt32(Date().timeIntervalSince1970),
            ObjectID.machineID, ObjectID.processID, counter
        )
    }
    
    public init?(_ bytes: [Byte]) {
        
        guard bytes.count == 12 else { return nil }
        
        let pointers = [0, 4, 7].flatMap {
            
            offset in
            bytes.withUnsafeBufferPointer { $0.baseAddress?.advanced(by: offset) }
        }
        
        guard pointers.count == 3 else { return nil }
        
        let timestamp = pointers[0].withMemoryRebound(to: UInt32.self, capacity: 1) {
            
            UInt32(littleEndian: $0.pointee)
        }
        
        let machineID = (0 ... 2).map { pointers[1].advanced(by: $0).pointee }
        
        let processID = pointers[2].withMemoryRebound(to: UInt16.self, capacity: 1) {
        
            UInt16(littleEndian: $0.pointee)
        }
        
        let counterBytes = (bytes.dropFirst(9) + [0x00]).map { $0 }
        guard let counter = UInt32(counterBytes) else { return nil }
        
        self.storage = (
            timestamp, machineID, processID,
            UInt32(littleEndian: counter)
        )
    }
    
    public init?(_ hexString: String) {
        
        var bytes = [UInt8]()
        
        var iterator = hexString.characters.makeIterator()
        
        while let char1 = iterator.next(), let char2 = iterator.next() {
            
            let substring = String([char1, char2])
            
            guard let byte = UInt8(substring, radix: 16) else { break }
            
            bytes.append(byte)
        }
        self.init(bytes)
    }
    
    public var timestamp: UInt32 {
        
        return UInt32(littleEndian: self.storage.timestamp)
    }
    
    public var date: Date {
        
        return Date(timeIntervalSince1970: Double(self.timestamp))
    }
    
    public var hexString: String {
        
        return self._bytes.map { String(format: "%02x", $0) }.joined()
    }
}

extension ObjectID : ElementValueConvertible {
    
    public init?(value: Element.Value) {
        
        guard case .objectID(let id) = value else { return nil }
        
        self = id
    }
    
    public var value: Element.Value {
        
        return Element.Value.objectID(self)
    }
}

extension ObjectID : Hashable {
    
    public static func ==(lhs: ObjectID, rhs: ObjectID) -> Bool {
        
        return lhs.hashValue == rhs.hashValue
    }
    
    public var hashValue: Int {
    
        return self.hexString.hashValue
    }
}

extension ObjectID : _ByteConvertible {
    
    var _bytes: [Byte] {
        
        var bytes = [Byte]()
        bytes.append(contentsOf: self.storage.timestamp._bytes)
        bytes.append(contentsOf: self.storage.machineID)
        bytes.append(contentsOf: self.storage.processID._bytes)
        bytes.append(contentsOf: self.storage.counter._bytes.dropLast().map { $0 })
        
        precondition(bytes.count == 12, "ObjectID validation failed")
        
        return bytes
    }
}
