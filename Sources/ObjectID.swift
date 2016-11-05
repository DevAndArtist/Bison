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
    
    typealias Storage = (
        timestampt: UInt32, // the seconds since the Unix epoch
        machineID: [Byte],  // machine identifier
        processID: UInt16,  // process id
        counter: UInt32     // counter, starting with a random value
    )
    
    fileprivate static let machineIdentifier: [Byte] = {
       
        let stringBuffer = UnsafeMutablePointer<CChar>.allocate(capacity: 1024)
        gethostname(stringBuffer, 1024)
        // extract host name
        let hostName = String(cString: stringBuffer)
        // get rid of the buffer
        stringBuffer.deinitialize()
        stringBuffer.deallocate(capacity: 1024)
        
        return _md5(hostName.utf8.map{ $0 })[0...3].map { $0 }
    }()
    
    fileprivate static let processID = UInt16(getpid())
    
    fileprivate static let queue = DispatchQueue(label: "com.devandartist.bison")

    fileprivate static var counter: UInt32 = {
 
        #if os(Linux)
            srandom(UInt32(time(nil)))
            return UInt32(abs(Int32(rand() % 0x01_000000)))
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
    
    let storage: Storage
    
    public init() {
        
        var counter = UInt32(0)
        ObjectID.queue.sync {
            
            ObjectID.counter += 1
            counter = ObjectID.counter
        }
        
        self.storage = (
            UInt32(Date().timeIntervalSince1970), ObjectID.machineIdentifier,
            ObjectID.processID, counter
        )
    }
}

extension ObjectID : _ByteConvertible {
    
    var _bytes: [Byte] {
        
        var bytes = [Byte]()
        bytes.append(contentsOf: self.storage.timestampt._bytes)
        bytes.append(contentsOf: self.storage.machineID)
        bytes.append(contentsOf: self.storage.processID._bytes)
        bytes.append(contentsOf: self.storage.counter._bytes.dropLast().map { $0 })
        
        precondition(bytes.count == 12, "ObjectID validation failed")
        
        return bytes
    }
}

